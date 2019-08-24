println("\n\nload_s_wildfire: start")

# number of records to load as sample (0 disables)
# RECORD_LIMIT=10_000
RECORD_LIMIT=0

using Distributed
if RECORD_LIMIT == 0 && nprocs() < length(Sys.cpu_info())
    n = length(Sys.cpu_info()) - nprocs()
    addprocs(n, restrict=true)
end
println("load_s_wildfire: nprocs=$(nprocs())")

@everywhere prepend!(LOAD_PATH, ["Project.toml"])
@everywhere import LibPQ, SQLite
@everywhere using Dates, DataFrames

@everywhere DISASTER_PASSWORD = read("./etc/disaster-pass", String)

# the step must match the sql value
RECORD_RANGE = 1:5_000:2_000_000
if RECORD_LIMIT > 0
    RECORD_RANGE = 1:5_000:RECORD_LIMIT
end
println("load_s_wildfire: RECORD_RANGE=$(RECORD_RANGE)")

postgres = LibPQ.Connection("host=127.0.0.1 port=5432 dbname=disaster user=disaster password=$DISASTER_PASSWORD")
sqlite = SQLite.DB("data/fs_usda_wildfire/Data/FPA_FOD_20170508.sqlite")

# table_names = SQLite.tables(db)
# println(table_names)

# create empty wildfire staging table
sql =
"""
drop table if exists public.s_wildfire;
create table if not exists public.s_wildfire (
  id                   integer primary key,
  reporting_unit_name  text,
  fire_name            text,
  fire_year            integer,
  fire_doy             integer,
  stat_cause_code      decimal,
  stat_cause_descr     text,
  cont_date            real,
  cont_doy             integer,
  cont_time            text,
  fire_size            decimal,
  fire_size_class      text,
  latitude             decimal,
  longitude            decimal,
  state                text,
  county               text,
  ogc_fid              integer,
  datestamp            date,
  severity             integer
);

create or replace function public.trigger_s_wildfire_udf()
returns trigger as \$body\$
declare
    _ogc_fid  integer;
begin
    select ogc_fid into _ogc_fid
        from public.tl_2015_us_county
        where ST_Contains(
            tl_2015_us_county.wkb_geometry,
            ST_SetSRID(ST_MakePoint(new.longitude, new.latitude), 4326));
    -- raise notice 'update_s_wildfire_ogc_fid: id=%, ogc_fid=%', new.id, _ogc_fid;
    new.ogc_fid := _ogc_fid;
    new.datestamp := (new.fire_year::text || '.' || lpad(new.fire_doy::text, 3, '0'))::date;
    -- use size_class to create 1-10 severity value
    if new.fire_size_class = 'A' then new.severity = 1;
    elsif new.fire_size_class = 'B' then new.severity = 2;
    elsif new.fire_size_class = 'C' then new.severity = 3;
    elsif new.fire_size_class = 'D' then new.severity = 4;
    elsif new.fire_size_class = 'E' then new.severity = 5;
    elsif new.fire_size_class = 'F' then new.severity = 6;
    elsif new.fire_size < 10000 then new.severity = 8;
    elsif new.fire_size < 100000 then new.severity = 9;
    else new.severity = 10;
    end if;
    return new;
end; \$body\$ language plpgsql;

drop trigger if exists trigger_s_wildfire on public.s_wildfire;
create trigger trigger_s_wildfire
  before insert on public.s_wildfire
  for each row execute function public.trigger_s_wildfire_udf();
"""
LibPQ.execute(postgres, sql)
LibPQ.close(postgres)

@everywhere function load_s_wildfire(i)
    println("\ti=$i")
    postgres = LibPQ.Connection("host=127.0.0.1 port=5432 dbname=disaster user=disaster password=$DISASTER_PASSWORD")
    sqlite = SQLite.DB("data/fs_usda_wildfire/Data/FPA_FOD_20170508.sqlite")

    sql =
    """
    select
        "OBJECTID" as id,
        "NWCG_REPORTING_UNIT_NAME" as reporting_unit_name,
        "FIRE_NAME" as fire_name,
        "FIRE_YEAR" as fire_year,
        "DISCOVERY_DOY" as fire_doy,
        "STAT_CAUSE_CODE" as stat_cause_code,
        "STAT_CAUSE_DESCR" as stat_cause_descr,
        "CONT_DATE" as cont_date,
        "CONT_DOY" as cont_doy,
        "CONT_TIME" as cont_time,
        "FIRE_SIZE" as fire_size,
        "FIRE_SIZE_CLASS" as fire_size_class,
        "LATITUDE" as latitude,
        "LONGITUDE" as longitude,
        "STATE" as state,
        "COUNTY" as county
    from "Fires"
    where "OBJECTID" >= $i
    order by "OBJECTID"
    limit 5000;
    """

    df = SQLite.Query(sqlite, sql, values=[]) |> DataFrame
    # println(df)

    LibPQ.load!(
        df,
        postgres,
        """
        insert into public.s_wildfire (
            id,
            reporting_unit_name,
            fire_name,
            fire_year,
            fire_doy,
            stat_cause_code,
            stat_cause_descr,
            cont_date,
            cont_doy,
            cont_time,
            fire_size,
            fire_size_class,
            latitude,
            longitude,
            state,
            county
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
            \$16
        )
        """
    )

    LibPQ.close(postgres)
    SQLite._close(sqlite)
end


starttime = Dates.now()
jobs = []
for i = RECORD_RANGE
    job = @spawn load_s_wildfire(i)
    push!(jobs, job)
end
for job in jobs
    fetch(job)
end

endtime = Dates.now()
println("load_s_wildfire: elapsed time is $(Dates.canonicalize(Dates.CompoundPeriod(endtime - starttime)))")
println("load_s_wildfire: done")
