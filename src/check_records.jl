println("\n\ncheck_records.jl: start")

prepend!(LOAD_PATH, ["Project.toml"])
import LibPQ
using DataFrames, PrettyTables

DISASTER_PASSWORD = read("./etc/disaster-pass", String)

postgres = LibPQ.Connection("host=127.0.0.1 port=5432 dbname=disaster user=disaster password=$DISASTER_PASSWORD")

sql_queries = [
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
    select distinct(d_severity_id), count(1)
    from public.f_earthquake
    group by d_severity_id
    order by d_severity_id;
    """,
    """
    select distinct(d_severity_id), count(1)
    from public.f_wildfire
    group by d_severity_id
    order by d_severity_id;
    """,
    """
    select distinct(d_severity_id), count(1)
    from public.f_storm
    group by d_severity_id
    order by d_severity_id;
    """,
]

for sql_query in sql_queries
    result = LibPQ.execute(postgres, sql_query) |> DataFrame
    pretty_table(result)
end

LibPQ.close(postgres)

println("\ncheck_records: stop")
