println("\n\nmake_f_storm: start")

prepend!(LOAD_PATH, ["Project.toml"])
import LibPQ

DISASTER_PASSWORD = read("./etc/disaster-pass", String)

postgres = LibPQ.Connection("host=127.0.0.1 port=5432 dbname=disaster user=disaster password=$DISASTER_PASSWORD")

sql =
"""
drop table if exists public.f_storm;
create table if not exists public.f_storm (
    event_id        uuid primary key default gen_random_uuid(),
    storm_id        text not null,
    latitude        decimal not null,
    longitude       decimal not null,
    type            text,
    magnitude       decimal,
    d_datestamp_id  date not null references public.d_datestamp(d_datestamp_id),
    d_location_id   integer not null references public.d_location(d_location_id),
    d_severity_id   integer not null references public.d_severity(d_severity_id)
);


truncate public.f_storm;
insert into public.f_storm (
    storm_id,
    latitude,
    longitude,
    type,
    magnitude,
    d_datestamp_id,
    d_location_id,
    d_severity_id
)
select
    id,
    begin_latitude,
    begin_longitude,
    event_type,
    magnitude,
    datestamp,
    ogc_fid,
    severity
from public.s_storm
where ogc_fid is not null;
"""
LibPQ.execute(postgres, sql)
LibPQ.close(postgres)


println("make_f_storm: stop")
