println("\n\nload_s_earthquake: start")

# number of files to load as sample (0 disables)
# FILE_LIMIT = 2
FILE_LIMIT = 0

using Distributed
if FILE_LIMIT == 0 && nprocs() < length(Sys.cpu_info())
    n = length(Sys.cpu_info()) - nprocs()
    addprocs(n, restrict=true)
end
println("load_s_earthquake: nprocs=$(nprocs())")


@everywhere prepend!(LOAD_PATH, ["Project.toml"])
@everywhere import CSV, LibPQ
@everywhere using Dates, DataFrames, Glob

@everywhere DISASTER_PASSWORD = read("./etc/disaster-pass", String)

FILE_PATHS = glob("*.csv", "./data/usgs_earthquake")
if FILE_LIMIT > 0
    FILE_PATHS = FILE_PATHS[1:FILE_LIMIT]
end
println("load_s_earthquake: FILE_PATHS=$(FILE_PATHS)")

postgres = LibPQ.Connection("host=127.0.0.1 port=5432 dbname=disaster user=disaster password=$DISASTER_PASSWORD")

# create empty earthquake staging table
sql =
"""
drop table if exists public.s_earthquake;
create table if not exists public.s_earthquake (
  id                   text primary key,
  time                 text,
  place                text,
  latitude             decimal,
  longitude            decimal,
  depth                decimal,
  magnitude            decimal,
  magnitude_type       text,
  type                 text,
  status               text,
  ogc_fid              integer,
  datestamp            date,
  severity             integer
);

create or replace function public.trigger_s_earthquake_udf()
returns trigger as \$body\$
declare
    _ogc_fid  integer;
begin
    select ogc_fid into _ogc_fid
        from public.tl_2015_us_county
        where st_contains(
            tl_2015_us_county.wkb_geometry,
            ST_SetSRID(ST_MakePoint(new.longitude, new.latitude), 4326));

    -- raise notice 'update_s_earthquake_ogc_fid: id=%, ogc_fid=%', new.id, _ogc_fid;
    new.ogc_fid = _ogc_fid;
    new.datestamp = new.time::date;

    -- use richter scale to create 1-10 severity value
    if new.magnitude < 1.0 then new.severity = 1;
    elsif new.magnitude < 2.0 then new.severity = 2;
    elsif new.magnitude < 3.0 then new.severity = 3;
    elsif new.magnitude < 4.0 then new.severity = 4;
    elsif new.magnitude < 5.0 then new.severity = 5;
    elsif new.magnitude < 6.0 then new.severity = 6;
    elsif new.magnitude < 7.0 then new.severity = 7;
    elsif new.magnitude < 8.0 then new.severity = 8;
    elsif new.magnitude < 9.0 then new.severity = 9;
    else new.severity = 10;
    end if;

    return new;
end; \$body\$ language plpgsql;

drop trigger if exists trigger_s_earthquake on public.s_earthquake;
create trigger trigger_s_earthquake
  before insert on public.s_earthquake
  for each row execute function public.trigger_s_earthquake_udf();
"""
LibPQ.execute(postgres, sql)
LibPQ.close(postgres)


@everywhere function load_s_earthquake(filepath)
    println("\tfilepath=$filepath")
    postgres = LibPQ.Connection("host=127.0.0.1 port=5432 dbname=disaster user=disaster password=$DISASTER_PASSWORD")

    df = CSV.read(filepath)
    select!(df, [
        :id, :time, :place, :latitude, :longitude, :depth, :mag, :magType,
        :type, :status, :net, :locationSource, :magSource, :updated
    ])
    select!(df, [
        :id, :time, :place, :latitude, :longitude, :depth, :mag, :magType,
        :type, :status
    ])
    println("\tsize=$(size(df))")
    # println("load_s_earthquake: columns=$(names(df))")

    LibPQ.load!(
        df,
        postgres,
        """
        insert into public.s_earthquake (
            id,
            time,
            place,
            latitude,
            longitude,
            depth,
            magnitude,
            magnitude_type,
            type,
            status
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
            \$10
        )
        """
    )

    LibPQ.close(postgres)
end


starttime = Dates.now()
jobs = []
for filepath = FILE_PATHS
    job = @spawn load_s_earthquake(filepath)
    push!(jobs, job)
end
for job in jobs
    fetch(job)
end

endtime = Dates.now()
println("load_s_earthquake: elapsed time is $(Dates.canonicalize(Dates.CompoundPeriod(endtime - starttime)))")
println("load_s_earthquake: done")
