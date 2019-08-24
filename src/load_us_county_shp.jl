println("\n\nload_us_county_shp: start")

prepend!(LOAD_PATH, ["Project.toml"])

XENV = copy(ENV)

PGPASSWORD = strip(read("etc/disaster-pass", String))
XENV["PGPASSWORD"] = PGPASSWORD

XDIR = "./data/us_census_bureau/"

run(Cmd(`ogr2ogr -nlt PROMOTE_TO_MULTI -f PGDump -t_srs "EPSG:4326" tl_2015_us_county.sql tl_2015_us_county.shp`, dir=XDIR))

run(Cmd(`psql --host=127.0.0.1 --user=disaster --dbname=disaster --file=tl_2015_us_county.sql`, env=XENV, dir=XDIR))

println("load_us_county_shp: done")
