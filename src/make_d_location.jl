println("\n\nmake_d_location: start")

prepend!(LOAD_PATH, ["Project.toml"])
import LibPQ

DISASTER_PASSWORD = read("./etc/disaster-pass", String)

postgres = LibPQ.Connection("host=127.0.0.1 port=5432 dbname=disaster user=disaster password=$DISASTER_PASSWORD")

sql =
"""
drop table if exists public.d_location;
create table if not exists public.d_location (
    d_location_id  integer primary key,
    state_fips     text not null,
    state_name     text,
    county_fips    text not null,
    county_name    text
);


truncate public.d_location;
insert into public.d_location (
    d_location_id,
    state_fips,
    state_name,
    county_fips,
    county_name
)
select G.ogc_fid, G.statefp, S.state_name, G.countyfp, G.name
from tl_2015_us_county G
left join s_state_geocode S on S.state_fips = G.statefp;

-- add some values to fill in the gaps
update public.d_location set state_name = 'Puerto Rico' where state_fips = '72';
"""
LibPQ.execute(postgres, sql)
LibPQ.close(postgres)


println("make_d_location: stop")
