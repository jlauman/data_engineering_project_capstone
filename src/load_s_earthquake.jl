println("\n\nload_s_earthquake: start")

# number of files to load as sample (0 disables)
FILE_LIMIT = 2

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
  status               text
);
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
