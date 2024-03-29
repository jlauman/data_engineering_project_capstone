println("\n\nload_s_storm: start")

# number of files to load as sample (0 disables)
# FILE_LIMIT = 2
FILE_LIMIT = 0

using Distributed
if FILE_LIMIT == 0 && nprocs() < length(Sys.cpu_info())
    n = length(Sys.cpu_info()) - nprocs()
    addprocs(n, restrict=true)
end
println("load_s_storm: nprocs=$(nprocs())")

@everywhere prepend!(LOAD_PATH, ["Project.toml"])
@everywhere import CSV, LibPQ
@everywhere using Dates, DataFrames, Glob

@everywhere DISASTER_PASSWORD = read("./etc/disaster-pass", String)

FILE_PATHS = glob("StormEvents_details-*.csv", "./data/noaa_storm")
if FILE_LIMIT > 0
    FILE_PATHS = FILE_PATHS[1:FILE_LIMIT]
end
println("load_s_storm: FILE_PATHS=$(FILE_PATHS)")

postgres = LibPQ.Connection("host=127.0.0.1 port=5432 dbname=disaster user=disaster password=$DISASTER_PASSWORD")

# create empty storm staging table
sql =
"""
drop table if exists public.s_storm;
create table if not exists public.s_storm (
    id                   integer primary key,
    state                text,
    state_fips           text,
    begin_yearmonth      integer,
    begin_day            integer,
    begin_location       text,
    begin_latitude       decimal,
    begin_longitude      decimal,
    end_yearmonth        integer,
    end_day              integer,
    end_location         text,
    end_latitude         decimal,
    end_longitude        decimal,
    event_type           text,
    source               text,
    magnitude            decimal,
    magnitude_type       text,
    tor_f_scale          text,
    category             text,
    ogc_fid              integer,
    datestamp            date,
    severity             integer
);

create or replace function public.trigger_s_storm_udf()
returns trigger as \$body\$
declare
    _ogc_fid  integer;
begin
    select ogc_fid into _ogc_fid
        from public.tl_2015_us_county
        where st_contains(
            tl_2015_us_county.wkb_geometry,
            ST_SetSRID(ST_MakePoint(new.begin_longitude, new.begin_latitude), 4326));

    -- raise notice 'update_s_storm_ogc_fid: id=%, ogc_fid=%', new.id, _ogc_fid;
    new.ogc_fid = _ogc_fid;
    new.datestamp = (left(new.begin_yearmonth::text, 4) || '-' || right(new.begin_yearmonth::text, 2) || '-' || new.begin_day::text)::date;

    -- use hail size, wind speed or tor scale to create 1-10 severity value
    if new.event_type = 'Hail' then
        -- magnitude is hail size (in inches)
        if new.magnitude < 0.25 then new.severity = 1;
        elsif new.magnitude < 0.5 then new.severity = 2;
        elsif new.magnitude < 0.75 then new.severity = 3;
        elsif new.magnitude < 1.0 then new.severity = 4;
        elsif new.magnitude < 1.5 then new.severity = 5;
        elsif new.magnitude < 2.0 then new.severity = 6;
        elsif new.magnitude < 2.5 then new.severity = 7;
        elsif new.magnitude < 3.0 then new.severity = 8;
        elsif new.magnitude < 3.5 then new.severity = 9;
        else new.severity = 10;
        end if;
    elsif new.event_type = 'Tornado' then
        -- tornado uses tor scale
        if new.tor_f_scale = 'F0' then new.severity = 1;
        elsif new.tor_f_scale = 'F1' then new.severity = 2;
        elsif new.tor_f_scale = 'F2' then new.severity = 4;
        elsif new.tor_f_scale = 'F3' then new.severity = 6;
        elsif new.tor_f_scale = 'F4' then new.severity = 8;
        elsif new.tor_f_scale = 'F5' then new.severity = 10;
        else new.severity = 1;
        end if;
    elsif new.event_type = 'Thunderstorm Wind' or new.event_type = 'Winter Storm' then
        -- wind speed
        if new.magnitude < 12 then new.severity = 1;
        elsif new.magnitude < 25 then new.severity = 2;
        elsif new.magnitude < 50 then new.severity = 3;
        elsif new.magnitude < 100 then new.severity = 4;
        elsif new.magnitude < 150 then new.severity = 5;
        elsif new.magnitude < 200 then new.severity = 6;
        elsif new.magnitude < 250 then new.severity = 7;
        elsif new.magnitude < 300 then new.severity = 8;
        elsif new.magnitude < 350 then new.severity = 9;
        else new.severity = 10;
        end if;
    else
        new.severity = 1;
    end if;

    return new;
end; \$body\$ language plpgsql;


drop trigger if exists trigger_s_storm on public.s_storm;
create trigger trigger_s_storm
  before insert on public.s_storm
  for each row execute function public.trigger_s_storm_udf();
"""
LibPQ.execute(postgres, sql)
LibPQ.close(postgres)


# BEGIN_YEARMONTH,BEGIN_DAY,BEGIN_TIME,END_YEARMONTH,END_DAY,END_TIME,EPISODE_ID,EVENT_ID,STATE,STATE_FIPS,YEAR,
# MONTH_NAME,EVENT_TYPE,CZ_TYPE,CZ_FIPS,CZ_NAME,WFO,BEGIN_DATE_TIME,CZ_TIMEZONE,END_DATE_TIME,INJURIES_DIRECT,
# INJURIES_INDIRECT,DEATHS_DIRECT,DEATHS_INDIRECT,DAMAGE_PROPERTY,DAMAGE_CROPS,SOURCE,MAGNITUDE,MAGNITUDE_TYPE,
# FLOOD_CAUSE,CATEGORY,TOR_F_SCALE,TOR_LENGTH,TOR_WIDTH,TOR_OTHER_WFO,TOR_OTHER_CZ_STATE,TOR_OTHER_CZ_FIPS,
# TOR_OTHER_CZ_NAME,BEGIN_RANGE,BEGIN_AZIMUTH,BEGIN_LOCATION,END_RANGE,END_AZIMUTH,END_LOCATION,BEGIN_LAT,
# BEGIN_LON,END_LAT,END_LON,EPISODE_NARRATIVE,EVENT_NARRATIVE,DATA_SOURCE

@everywhere function load_s_storm(filepath)
    println("\tfilepath=$filepath")
    postgres = LibPQ.Connection("host=127.0.0.1 port=5432 dbname=disaster user=disaster password=$DISASTER_PASSWORD")

    df = CSV.read(filepath)
    select!(df, [
        :EVENT_ID, :STATE, :STATE_FIPS,
        :BEGIN_YEARMONTH, :BEGIN_DAY, :BEGIN_LOCATION, :BEGIN_LAT, :BEGIN_LON,
        :END_YEARMONTH, :END_DAY, :END_LOCATION, :END_LAT, :END_LON,
        :EVENT_TYPE, :SOURCE, :MAGNITUDE, :MAGNITUDE_TYPE, :TOR_F_SCALE, :CATEGORY
    ])
    println("\tsize=$(size(df))")
    # println("load_s_storm: columns=$(names(df))")

    LibPQ.load!(
        df,
        postgres,
        """
        insert into public.s_storm (
            id,
            state,
            state_fips,
            begin_yearmonth,
            begin_day,
            begin_location,
            begin_latitude,
            begin_longitude,
            end_yearmonth,
            end_day,
            end_location,
            end_latitude,
            end_longitude,
            event_type,
            source,
            magnitude,
            magnitude_type,
            tor_f_scale,
            category
        ) values (
            \$1,
            \$2,
            \$3,
            \$4,
            \$5,
            \$6,
            \$7,
            \$8,
            \$9,
            \$10,
            \$11,
            \$12,
            \$13,
            \$14,
            \$15,
            \$16,
            \$17,
            \$18,
            \$19
        )
        """
    )

    LibPQ.close(postgres)
end


starttime = Dates.now()
jobs = []
for filepath = FILE_PATHS
    job = @spawn load_s_storm(filepath)
    push!(jobs, job)
end
for job in jobs
    fetch(job)
end

endtime = Dates.now()
println("load_s_storm: elapsed time is $(Dates.canonicalize(Dates.CompoundPeriod(endtime - starttime)))")
println("load_s_storm: done")
