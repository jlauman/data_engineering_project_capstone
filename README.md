# Data Engineering Capstone Project

This is a Udacity Data Engineering Nanoegree open-ended capstone project.


## Project Preface



## Project Scope

The goal of this project is to prepare multiple data sets with over 1 million
records for analysis using a standard RDBMS star schema. The topic selected for
this data engineering project is anomalous weather events, natural disasters and
other extreme environmental events. The complete original data sets will be
extracted, transformed and loaded without any filtering or pre-selection. A
data scientist using the final combined data sets is expected to define "extreme
environmental event" is within the context of their analysis.


## Source Data Sets

The following data sets have been selected for this project. The criteria for
data set selection (specifically for this project) are 1) at least two data
sets are required and 2) the data sets must contain more than 1 million
records.


### United States Wildfires, 1992-2015

This data set includes 1.88 million geo-referenced wildfire records over a
24-year period. This data is known as the Fire Program Analysis fire-occurrence
database.

The source of this data set is:

  https://www.fs.usda.gov/rds/archive/catalog/RDS-2013-0009.4

The following references describe values in the data set:

  https://www.nwcg.gov/term/glossary/size-class-of-fire

The format selected for this project is the SQLite database. The record cound
for the wildfire SQLite database is shown below.

  sqlite3 data/fs_usda_wildfire/Data/FPA_FOD_20170508.sqlite "select count(*) from Fires;"
  1880465


### NOAA Storm Events Database, 1950-2018

This is the NOAA National Weather Service (NWS) database for storm events. The
expectation is this will be a large data set and the ETL process will identify
fields within the records that may be used to define a storm as extreme or
anomalous.

The source of this data set is:

  https://www.ncdc.noaa.gov/stormevents/ftp.jsp

  ftp://ftp.ncdc.noaa.gov/pub/data/swdi/stormevents/csvfiles/

The following file contains the data dictionary:

  [NOAA Storm Data Export Format](./doc/noaa_storm_dictionary.html)

The format selected for this data set is CSV files. The record count output
from the download CSV files is shown below.

  $ wc -l data/noaa_storm/StormEvents_details-ftp_v1.0_d*.csv
     13535 data/noaa_storm/StormEvents_details-ftp_v1.0_d1992_c20170717.csv
      8665 data/noaa_storm/StormEvents_details-ftp_v1.0_d1993_c20170717.csv
     15628 data/noaa_storm/StormEvents_details-ftp_v1.0_d1994_c20170717.csv
     20462 data/noaa_storm/StormEvents_details-ftp_v1.0_d1995_c20170522.csv
     48562 data/noaa_storm/StormEvents_details-ftp_v1.0_d1996_c20170717.csv
     41992 data/noaa_storm/StormEvents_details-ftp_v1.0_d1997_c20170717.csv
     50974 data/noaa_storm/StormEvents_details-ftp_v1.0_d1998_c20170717.csv
     46384 data/noaa_storm/StormEvents_details-ftp_v1.0_d1999_c20170717.csv
     52008 data/noaa_storm/StormEvents_details-ftp_v1.0_d2000_c20170717.csv
     48876 data/noaa_storm/StormEvents_details-ftp_v1.0_d2001_c20170717.csv
     50937 data/noaa_storm/StormEvents_details-ftp_v1.0_d2002_c20170717.csv
     52957 data/noaa_storm/StormEvents_details-ftp_v1.0_d2003_c20170717.csv
     52410 data/noaa_storm/StormEvents_details-ftp_v1.0_d2004_c20170717.csv
     53977 data/noaa_storm/StormEvents_details-ftp_v1.0_d2005_c20170717.csv
     56401 data/noaa_storm/StormEvents_details-ftp_v1.0_d2006_c20170717.csv
     59011 data/noaa_storm/StormEvents_details-ftp_v1.0_d2007_c20170717.csv
     71191 data/noaa_storm/StormEvents_details-ftp_v1.0_d2008_c20180718.csv
     57399 data/noaa_storm/StormEvents_details-ftp_v1.0_d2009_c20180718.csv
     62805 data/noaa_storm/StormEvents_details-ftp_v1.0_d2010_c20170726.csv
     79092 data/noaa_storm/StormEvents_details-ftp_v1.0_d2011_c20180718.csv
     64504 data/noaa_storm/StormEvents_details-ftp_v1.0_d2012_c20190516.csv
     59986 data/noaa_storm/StormEvents_details-ftp_v1.0_d2013_c20170519.csv
     59466 data/noaa_storm/StormEvents_details-ftp_v1.0_d2014_c20180718.csv
     57789 data/noaa_storm/StormEvents_details-ftp_v1.0_d2015_c20190817.csv
   1185011 total


### USGS Earthquake Catalog (API)

This data set is provided by the National Earthquake Hazards Reduction Program
(NEHRP) led by the National Institutes of Standards and Technology (NIST) and
part of the Earthquake Hazards Program with the U.S. Geological Survey (USGS).

The starting URL for this data source is:

  https://earthquake.usgs.gov/ws/

The data dictionary is:

  https://earthquake.usgs.gov/data/comcat/data-eventterms.php

  [ComCat Documentation - Event Terms](./doc/usgs_earthquake_dictionary.htm)

The data set is available through a web API and results specified through URL
query parameters as shown below.

  https://earthquake.usgs.gov/fdsnws/event/1/query?format=text&starttime=1992-01-01&endtime=1992-03-31&minlongitude=-170&minlatitude=15&maxlongitude=-60&maxlatitude=72

The API limits the number of records returned in each response. The error when
the limit is exceeded is shown below. The download script that calls the API
includes a mechanism to limit the number of records in the response.

    Error 400: Bad Request
    286412 matching events exceeds search limit of 20000. Modify the search to match fewer events.
    Usage details are available from https://earthquake.usgs.gov/fdsnws/event/1
    Request Submitted: 2019-08-11T17:50:26+00:00
    Service version: 1.8.1

This API requires a latitude-longitude bounding box. Notes on identifying
and building bounding box query parameters are included below.

  https://wiki.openstreetmap.org/wiki/Bounding_Box

  bbox = left,bottom,right,top
  bbox = min Longitude , min Latitude , max Longitude , max Latitude

  https://boundingbox.klokantech.com/

  westlimit=-170.0; southlimit=15.0; eastlimit=-59.9; northlimit=72.0

  minlongitude=-170
  minlatitude=15
  maxlongitude=-60
  maxlatitude=72

The format selected for this data set is CSV. The record count output from the
downloaded CSV files is shown below.

  $ wc -l data/usgs_earthquake/*.csv
   22654 data/usgs_earthquake/1992.csv
    8419 data/usgs_earthquake/1993.csv
    9559 data/usgs_earthquake/1994.csv
    7122 data/usgs_earthquake/1995.csv
    6812 data/usgs_earthquake/1996.csv
    7333 data/usgs_earthquake/1997.csv
    8555 data/usgs_earthquake/1998.csv
   11713 data/usgs_earthquake/1999.csv
    7909 data/usgs_earthquake/2000.csv
    8254 data/usgs_earthquake/2001.csv
   15283 data/usgs_earthquake/2002.csv
   13501 data/usgs_earthquake/2003.csv
   14753 data/usgs_earthquake/2004.csv
   13378 data/usgs_earthquake/2005.csv
   12023 data/usgs_earthquake/2006.csv
   12398 data/usgs_earthquake/2007.csv
   14400 data/usgs_earthquake/2008.csv
   11770 data/usgs_earthquake/2009.csv
   24695 data/usgs_earthquake/2010.csv
   13022 data/usgs_earthquake/2011.csv
   12918 data/usgs_earthquake/2012.csv
   13476 data/usgs_earthquake/2013.csv
   18107 data/usgs_earthquake/2014.csv
   18968 data/usgs_earthquake/2015.csv
  307022 total


### United States Census Bureau Reference Files

In order to support location identification from latitude-longitude coordinates
additional data sets are required. The United States Census Bureau publishes
U.S. geography shape files that are used in this project.

  https://www.census.gov/programs-surveys/geography.html

The U.S. state FIPS codes are one set of codes used to encode states.

  https://www.census.gov/geographies/reference-files/2015/demo/popest/2015-fips.html

The following URL and input information are used to select and download the
shape files for location resolution down to the county level.

  https://www.census.gov/cgi-bin/geo/shapefiles/index.php

  select year: 2015
  select layer type: Counties (and equivalent)

The data dictionary for the downloaded shape files is below.

  https://www2.census.gov/geo/pdfs/maps-data/data/tiger/tgrshp2017/TGRSHP2017_TechDoc_Ch3.pdf


### Summary of Project Data Sets

A summary of the data sets disk sizes is shown below.

   $ du -h data
    65M	data/usgs_earthquake
   108K	data/fs_usda_wildfire/Supplements
   773M	data/fs_usda_wildfire/Data
   939M	data/fs_usda_wildfire
   1014M	data/noaa_storm
   2.0G	data


## Project Set Up

This project uses three key technologies for the ETL process 1) the Julia
programming language 2) the PostgreSQL database and 3) the PostGIS spacial
database extension for PostgreSQL.

To replicate the set up for this project install the Julia language as
described here: https://julialang.org/downloads/

### PostgreSQL 11 with PostGIS Extension

For this project PostgreSQL is run as a docker container. Use the bash script
`bin/build.sh` to construct the docker image.

The following references were used to construct the Docker file for the
PostgreSQL with PostGIS extension docker image.

  https://hub.docker.com/_/postgres

  https://github.com/appropriate/docker-postgis/blob/f6d28e4a1871b1f72e1c893ff103f10b6d7cb6e1/10-2.4/Dockerfile

Use the SQL `select * from pg_extension;` to check that the PostGIS extension
is installed correclty.

  extname           extowner extnamespace extrelocatable extversion
  plpgsql	          10       11           false	         1.0
  pgcrypto	        10       2200	        true           1.3
  postgis	          10       2200         false          2.5.2
  postgis_topology	10       34395        false          2.5.2

Additional command line tools are required to convert shape files. On MacOS
use the command below to install the GDAL tool set. See: https://gdal.org/

  brew install gdal

The following references were used to understand the spatial system and tools.

  http://www.silota.com/docs/sql-load-data/shapefile-postgis.html

  https://en.wikipedia.org/wiki/Spatial_reference_system

  https://spatialreference.org/ref/epsg/4326/

  https://gist.github.com/clhenrick/ebc8dc779fb6f5ee6a88#postgis-1

An example SQL query that combines functions from PostGIS, the U.S. Census
Bureau shape file data and state FIPS codes is shown below.

  SELECT statefp, state_name, namelsad FROM tl_2015_us_county
  join s_state_geocode ST on ST.state_fips = statefp
  where
  st_contains(
    tl_2015_us_county.wkb_geometry,
    ST_GeomFromText('Point(-110.588484 39.673284)', 4326)      
  );


## Exploring Data Sets





## Project Script Execution

Use the following steps to execute the scripts in this project. Note: Julia
will install the libraries listed in the `Project.toml` file when a script
that requires them is run.

1. Download the wildfire database from: https://www.fs.usda.gov/rds/archive/catalog/RDS-2013-0009.4
2. Copy the wildfire database archive into `./data/fs_usda_wildfire` and extract.
3. Run `julia ./src/download_noaa_storm_event_db.jl` to download the storm events database.
4. Run `julia ./src/download_usgs_earthquake_db.jl` to download the earthquake databae.
5. Run `./bin/start.sh` to start the PostgeSQL database.
5. Run `julia ./src/load.jl` to the the ETL process scripts.
6. Run `julia ./src/check_records.jl` to run the data quality check script.

The output of the `load.jl` script will be similar to the following:

  load...
  ./src/load_s_state_geocodes.jl: elapsed time is 16 seconds, 707 milliseconds
  ./src/load_us_county_shp.jl: elapsed time is 36 seconds, 472 milliseconds
  ./src/load_s_earthquake.jl: elapsed time is 5 minutes, 32 seconds, 786 milliseconds
  ./src/load_s_storm.jl: elapsed time is 27 minutes, 10 seconds, 947 milliseconds
  ./src/load_s_wildfire.jl: elapsed time is 34 minutes, 11 seconds, 204 milliseconds
  ./src/make_d_datestamp.jl: elapsed time is 5 seconds, 416 milliseconds
  ./src/make_d_location.jl: elapsed time is 5 seconds, 45 milliseconds
  ./src/make_d_severity.jl: elapsed time is 4 seconds, 950 milliseconds
  ./src/make_f_earthquake.jl: elapsed time is 18 seconds, 325 milliseconds
  ./src/make_f_storm.jl: elapsed time is 49 seconds, 347 milliseconds
  ./src/make_f_wildfire.jl: elapsed time is 2 minutes, 18 seconds, 883 milliseconds
  load: total elapsed time is 1 hour, 11 minutes, 30 seconds, 455 milliseconds


## Project Data Dictionary

The following tables and fields describe the star schema tables that are the
result of the ETL process.

d_datestamp
d_location
d_severity
f_earthquake
f_storm
f_wildfire


## Fact Table Data Quality Checks

  check_records.jl: start
  ┌──────────────────────────────────────────────────────────────┐
  │                                                     ?column? │
  │                                       Union{Missing, String} │
  ├──────────────────────────────────────────────────────────────┤
  │ s_earthquake: record_count=306998, with_ogc_fid_count=206206 │
  └──────────────────────────────────────────────────────────────┘
  ┌──────────────────────────────────────────────────────────┐
  │                                                 ?column? │
  │                                   Union{Missing, String} │
  ├──────────────────────────────────────────────────────────┤
  │ s_storm: record_count=1184987, with_ogc_fid_count=655989 │
  └──────────────────────────────────────────────────────────┘
  ┌──────────────────────────────────────────────────────────────┐
  │                                                     ?column? │
  │                                       Union{Missing, String} │
  ├──────────────────────────────────────────────────────────────┤
  │ s_wildfire: record_count=1880465, with_ogc_fid_count=1880455 │
  └──────────────────────────────────────────────────────────────┘
  ┌─────────────────────────────┐
  │                    ?column? │
  │      Union{Missing, String} │
  ├─────────────────────────────┤
  │ total: record_count=2735615 │
  └─────────────────────────────┘
  ┌───────────────────────────────────┐
  │                          ?column? │
  │            Union{Missing, String} │
  ├───────────────────────────────────┤
  │ f_earthquake: record_count=199171 │
  └───────────────────────────────────┘
  ┌──────────────────────────────┐
  │                     ?column? │
  │       Union{Missing, String} │
  ├──────────────────────────────┤
  │ f_storm: record_count=655989 │
  └──────────────────────────────┘
  ┌──────────────────────────────────┐
  │                         ?column? │
  │           Union{Missing, String} │
  ├──────────────────────────────────┤
  │ f_wildfire: record_count=1880455 │
  └──────────────────────────────────┘
  ┌───────────────────────┬───────────────────────┐
  │         d_severity_id │                 count │
  │ Union{Missing, Int32} │ Union{Missing, Int64} │
  ├───────────────────────┼───────────────────────┤
  │                     3 │                172907 │
  │                     4 │                 23228 │
  │                     5 │                  2744 │
  │                     6 │                   266 │
  │                     7 │                    20 │
  │                     8 │                     6 │
  └───────────────────────┴───────────────────────┘
  ┌───────────────────────┬───────────────────────┐
  │         d_severity_id │                 count │
  │ Union{Missing, Int32} │ Union{Missing, Int64} │
  ├───────────────────────┼───────────────────────┤
  │                     1 │                666917 │
  │                     2 │                939369 │
  │                     3 │                220077 │
  │                     4 │                 28427 │
  │                     5 │                 14107 │
  │                     6 │                  7785 │
  │                     8 │                  1576 │
  │                     9 │                  2013 │
  │                    10 │                   184 │
  └───────────────────────┴───────────────────────┘
  ┌───────────────────────┬───────────────────────┐
  │         d_severity_id │                 count │
  │ Union{Missing, Int32} │ Union{Missing, Int64} │
  ├───────────────────────┼───────────────────────┤
  │                     1 │                124859 │
  │                     2 │                  4832 │
  │                     3 │                  3349 │
  │                     4 │                351848 │
  │                     5 │                 82879 │
  │                     6 │                 45130 │
  │                     7 │                  4372 │
  │                     8 │                  6392 │
  │                     9 │                   761 │
  │                    10 │                 31567 │
  └───────────────────────┴───────────────────────┘

  check_records: stop


## Project Conclusion
