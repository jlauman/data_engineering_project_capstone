println("\n\ncheck_records.jl: start")

prepend!(LOAD_PATH, ["Project.toml"])
import LibPQ, Tables

DISASTER_PASSWORD = read("./etc/disaster-pass", String)

postgres = LibPQ.Connection("host=127.0.0.1 port=5432 dbname=disaster user=disaster password=$DISASTER_PASSWORD")

sql_queries = [
    """
    select 'total: record_count=' || (
        (select count(*) from public.f_earthquake) +
        (select count(*) from public.f_storm) +
        (select count(*) from public.f_wildfire)
    );
    """,
    """
    select 'f_earthquake: record_count=' ||
        (select count(*) from public.f_earthquake);
    """,
    """
    select 'f_storm: record_count=' ||
        (select count(*) from public.f_storm);
    """,
    """
    select 'f_wildfire: record_count=' ||
        (select count(*) from public.f_wildfire);
    """,
    """
    select 's_earthquake: record_count=' ||
        (select count(*) from public.s_earthquake) ||
        ', with_ogc_fid_count=' ||
        (select count(*) from public.s_earthquake where ogc_fid is not null);
    """,
    """
    select 's_storm: record_count=' ||
        (select count(*) from public.s_storm) ||
        ', with_ogc_fid_count=' ||
        (select count(*) from public.s_storm where ogc_fid is not null);
    """,
    """
    select 's_wildfire: record_count=' ||
        (select count(*) from public.s_wildfire) ||
        ', with_ogc_fid_count=' ||
        (select count(*) from public.s_wildfire where ogc_fid is not null);
    """,
]

for sql_query in sql_queries
    result = LibPQ.execute(postgres, sql_query)
    rows = Tables.rowtable(result)
    for row in rows
        for columnname in propertynames(row)
            value = getproperty(row, columnname)
            println(value)
        end
    end
end

LibPQ.close(postgres)

println("check_records: stop")
