println("\n\nmake_f_earthquake: start")

prepend!(LOAD_PATH, ["Project.toml"])
import LibPQ

DISASTER_PASSWORD = read("./etc/disaster-pass", String)

postgres = LibPQ.Connection("host=127.0.0.1 port=5432 dbname=disaster user=disaster password=$DISASTER_PASSWORD")

sql =
"""
drop table if exists public.f_earthquake;
create table if not exists public.f_earthquake (
    event_id        uuid primary key default gen_random_uuid(),
    earthquake_id   text not null,
    latitude        decimal not null,
    longitude       decimal not null,
    magnitude       decimal not null,
    magnitude_type  text,
    d_datestamp_id  date not null references public.d_datestamp(d_datestamp_id),
    d_location_id   integer not null references public.d_location(d_location_id),
    d_severity_id   integer not null references public.d_severity(d_severity_id)
);


truncate public.f_earthquake;
insert into public.f_earthquake (
    earthquake_id,
    latitude,
    longitude,
    magnitude,
    magnitude_type,
    d_datestamp_id,
    d_location_id,
    d_severity_id
)
select
    id,
    latitude,
    longitude,
    magnitude,
    magnitude_type,
    datestamp,
    ogc_fid,
    severity
from public.s_earthquake
where ogc_fid is not null
and type = 'earthquake';
"""
LibPQ.execute(postgres, sql)
LibPQ.close(postgres)


println("make_f_earthquake: stop")
