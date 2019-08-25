println("\n\nmake_f_wildfire: start")

prepend!(LOAD_PATH, ["Project.toml"])
import LibPQ

DISASTER_PASSWORD = read("./etc/disaster-pass", String)

postgres = LibPQ.Connection("host=127.0.0.1 port=5432 dbname=disaster user=disaster password=$DISASTER_PASSWORD")

sql =
"""
drop table if exists public.f_wildfire;
create table if not exists public.f_wildfire (
    event_id        uuid primary key default gen_random_uuid(),
    wildfire_id     text not null,
    wildfire_name   text,
    latitude        decimal not null,
    longitude       decimal not null,
    size_acre       decimal not null,
    size_class      text not null,
    d_datestamp_id  date not null references public.d_datestamp(d_datestamp_id),
    d_location_id   integer not null references public.d_location(d_location_id),
    d_severity_id   integer not null references public.d_severity(d_severity_id)
);


truncate public.f_wildfire;
insert into public.f_wildfire (
    wildfire_id,
    wildfire_name,
    latitude,
    longitude,
    size_acre,
    size_class,
    d_datestamp_id,
    d_location_id,
    d_severity_id
)
select
    id,
    fire_name,
    latitude,
    longitude,
    fire_size,
    fire_size_class,
    datestamp,
    ogc_fid,
    severity
from public.s_wildfire
where ogc_fid is not null;
"""
LibPQ.execute(postgres, sql)
LibPQ.close(postgres)


println("make_f_wildfire: stop")
