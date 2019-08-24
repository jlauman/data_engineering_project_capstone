println("\n\nload_s_state_geocodes: start")

prepend!(LOAD_PATH, ["Project.toml"])
import CSV, LibPQ
using Dates, DataFrames, Glob

DISASTER_PASSWORD = read("./etc/disaster-pass", String)

FILE_PATH = "./data/state-geocodes-v2015.csv"
println("load_s_state_geocodes: FILE_PATH=$(FILE_PATH)")

postgres = LibPQ.Connection("host=127.0.0.1 port=5432 dbname=disaster user=disaster password=$DISASTER_PASSWORD")

# create empty storm staging table
sql =
"""
drop table if exists public.s_state_geocode;
create table if not exists public.s_state_geocode (
    region      text,
    division    text,
    state_fips  text,
    state_name  text
);
"""
LibPQ.execute(postgres, sql)
LibPQ.close(postgres)


function load_s_state_geocodes(filepath)
    println("\tfilepath=$filepath")
    postgres = LibPQ.Connection("host=127.0.0.1 port=5432 dbname=disaster user=disaster password=$DISASTER_PASSWORD")

    df = CSV.read(filepath)
    println("\tsize=$(size(df))")
    println("load_s_state_geocodes: columns=$(names(df))")

    LibPQ.load!(
        df,
        postgres,
        """
        insert into public.s_state_geocode (
            region,
            division,
            state_fips,
            state_name
        ) values (
            \$1,
            \$2,
            \$3,
            \$4
        )
        """
    )

    LibPQ.execute(postgres, "delete from s_state_geocode where state_fips = '0';")
    LibPQ.close(postgres)
end

starttime = Dates.now()
load_s_state_geocodes(FILE_PATH)

endtime = Dates.now()
println("load_s_state_geocodes: elapsed time is $(Dates.canonicalize(Dates.CompoundPeriod(endtime - starttime)))")
println("load_s_state_geocodes: done")
