-- select distinct(status) from public.s_earthquake;
--
-- select distinct(category) from public.s_storm;
--
-- select * from pg_extension;
--
-- SELECT ST_AsText(geom) from tl_2015_us_count;

--32.532237	 -86.646440
--39.673284	-110.588484
-- 36.73	-108.2

-- select ogc_fid, statefp, state_name, namelsad from tl_2015_us_county
-- join s_state_geocode ST on ST.state_fips = statefp
-- where
-- st_contains(
--   tl_2015_us_county.wkb_geometry,
--   ST_GeomFromText('Point(-105.50555556 42.35472222)', 4326)
-- );

-- lat=42.35472222	lon=-105.50555556
-- Point(lon, lat)

-- select ogc_fid from tl_2015_us_county
-- where
-- st_contains(
--   tl_2015_us_county.wkb_geometry,
--   ST_GeomFromText('Point(-105.50555556 42.35472222)', 4326)
-- );



select 's_earthquake: record_count=' ||
    (select count(*) from public.s_earthquake) ||
    ', with_ogc_fid_count=' ||
    (select count(*) from public.s_earthquake where ogc_fid is not null);


select 's_storm: record_count=' ||
    (select count(*) from public.s_storm) ||
    ', with_ogc_fid_count=' ||
    (select count(*) from public.s_storm where ogc_fid is not null);


select 's_storm: record_count=' ||
    (select count(*) from public.s_wildfire) ||
    ', with_ogc_fid_count=' ||
    (select count(*) from public.s_wildfire where ogc_fid is not null);
