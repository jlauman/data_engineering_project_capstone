# Data Engineering Capstone Project

This is a Udacity Data Engineering Nanodegree course open-ended capstone project.


## Project Preface

This project uses the Julia language for ETL scripts which provides a similar,
but different, environment for data transformation as Python+Pandas. One
interesting Julia module used in this project is `Distributed` which provides
a Python `multiprocessing`-like for spawning work into new OS processes. The
problems encountered with the Julia language in this project were related to
the relative youth of the Julia ecosystem and lack of documentation and examples
for Julia modules.


## Project Scope

The goal of this project is to prepare multiple data sets with over 1 million
records for analysis using a standard RDBMS star schema. The topic selected for
this data engineering project is anomalous weather events, natural disasters and
other extreme environmental events. The complete original data sets will be
extracted, transformed and loaded without any filtering or pre-selection. A
data scientist using the final combined data sets is expected to define "extreme
environmental event" is within the context of their analysis.

The data sets identified for this project are historical data sets, so the
ETL process will focus on creating a standard star schema design with fact and
dimension tables.

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

  ```
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
   ```


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

  ```
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
  ```

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

  ```
  $ du -h data
    65M	 data/usgs_earthquake
   108K	 data/fs_usda_wildfire/Supplements
   773M	 data/fs_usda_wildfire/Data
   939M	 data/fs_usda_wildfire
   1014M data/noaa_storm
   2.0G	 data
  ```

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
is installed correctly.

  ```
  extname           extowner extnamespace extrelocatable extversion
  plpgsql	          10       11           false	         1.0
  pgcrypto	        10       2200	        true           1.3
  postgis	          10       2200         false          2.5.2
  postgis_topology	10       34395        false          2.5.2
  ```

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

  ```
  SELECT statefp, state_name, namelsad FROM tl_2015_us_county
  join s_state_geocode ST on ST.state_fips = statefp
  where
  ST_Contains(
    tl_2015_us_county.wkb_geometry,
    ST_GeomFromText('Point(-110.588484 39.673284)', 4326)
  );
  ```


## Exploring Data Sets

The U.S. Forest Service wildfire data set is the easiest to work because it is
already in table format as a SQLite database. The number of fields and related
tables provided in the SQLite database is extensive -- only a small set of
fields from the `Fires` table is used in this project.

The U.S. Geological Survey earthquake data set is an interesting data set
because the initial filtering is done through the HTTP API. For this project,
only earthquakes with a 2 magnitude and higher are requested from the API. The
results contain records for earthquakes, and quarry explosions. Only earthquakes
are included in the earthquake fact table.

The NOAA storm data is an interesting data set to work with because it contains
many different types of storm events including "Debris Flow", "Dust Devil", "Flood",
"Hail", "Heavy Rain", "Lightning", "Thunderstorm Wind", "Tornado" and "Waterspout".
For this project the severity value is calculated differently for hail (magnitude is
the diameter of the hail), tornado which uses the Fujita "F" scale and other storms
which are measured by wind speed.

All three data sets included latitude and longitude coordinates to identify location
of the event. For earthquakes and storm the coordinates could be offshore, so only
only land based events are includes to match with the state/county data from the
U.S. Census Bureau. The storm event records also include beginning and ending
coordinates -- only beginning coordinates are used in this project.


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

  ```
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
  ```

## Project Data Dictionary

The following tables and fields describe the star schema tables that are the
result of the ETL process.

|Table         |Field           |Type          |Description                                           |
|--------------|----------------|--------------|------------------------------------------------------|
|d_datestamp   |d_datestamp_id  |DATE          |Date in yyyy-mm-dd format                             |
|              |year            |INTEGER       |Four digit numieric year                              |
|              |month           |INTEGER       |Month as numeric value 1-12                           |
|              |day             |INTEGER       |Day of month as numeric value 1-31                    |
|              |weekofyear      |INTEGER       |Week of year as numeric value 1-53                    |

|Table         |Field           |Type          |Description                                           |
|--------------|----------------|--------------|------------------------------------------------------|
|d_location    |d_location_id   |INTEGER       |Integer value from the U.S. Census Bureau shape file  |
|              |state_fips      |TEXT          |Value that identifies a state                         |
|              |state_name      |TEXT          |English name of state                                 |
|              |county_fips     |TEXT          |Value that identifies a county (or equivalent)        |
|              |county_name     |TEXT          |English name of county                                |


|Table         |Field           |Type          |Description                                           |
|--------------|----------------|--------------|------------------------------------------------------|
|d_severity    |d_severity_id   |INTEGER       |Relative numeric value 1-10 for size/strenth of event |

|Table         |Field           |Type          |Description                                           |
|--------------|----------------|--------------|------------------------------------------------------|
|f_earthquake  |event_id        |UUID          |Unique identifier across disaster events              |
|              |earthquake_id   |TEXT          |Original earthquake ID from imported data set         |
|              |latitude        |DECIMAL       |Latitude value                                        |
|              |longitude       |DECIMAL       |Longitude value                                       |
|              |magnitude       |DECIMAL       |Magnitude of earthquake on Ricther scale              |
|              |magnitude_type  |TEXT          |Method of calculating the magnitude                   |
|              |d_datestamp_id  |DATE          |Unique ID into datestamp dimension                    |
|              |d_location_id   |INTEGER       |Unique ID into location dimension                     |
|              |d_severity_id   |INTEGER       |Unique ID (1-10) into severity dimension              |

|Table         |Field           |Type          |Description                                           |
|--------------|----------------|--------------|------------------------------------------------------|
|f_storm       |event_id        |UUID          |Unique identifier across disaster events              |
|              |storm_id        |TEXT          |Original storm ID from imported data set              |
|              |latitude        |DECIMAL       |Latitude value                                        |
|              |longitude       |DECIMAL       |Longitude value                                       |
|              |type            |TEXT          |English name of storm type                            |
|              |magnitude       |DECIMAL       |Wind speed (or size if Hail)                          |
|              |d_datestamp_id  |DATE          |Unique ID into datestamp dimension                    |
|              |d_location_id   |INTEGER       |Unique ID into location dimension                     |
|              |d_severity_id   |INTEGER       |Unique ID (1-10) into severity dimension              |

|Table         |Field           |Type          |Description                                           |
|--------------|----------------|--------------|------------------------------------------------------|
|f_wildfire    |event_id        |UUID          |Unique identifier across disaster events              |
|              |wildfire_id     |TEXT          |Original wildfire ID from imported data set           |
|              |wildfire_name   |TEXT          |Original English name of wildfire                     |
|              |latitude        |DECIMAL       |Latitude value                                        |
|              |longitude       |DECIMAL       |Longitude value                                       |
|              |size_acre       |DECIMAL       |Size of area covered by wildfire                      |
|              |size_class      |TEXT          |Size class of wildfire (A-H)                          |
|              |d_datestamp_id  |DATE          |Unique ID into datestamp dimension                    |
|              |d_location_id   |INTEGER       |Unique ID into location dimension                     |
|              |d_severity_id   |INTEGER       |Unique ID (1-10) into severity dimension              |


## Fact Table Data Quality Checks

  ```
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
  ```


## Project Conclusion

This project served as an interesting experiment in processing million-plus sized
data sets into an efficient structure for reporting. The combination of the Julia
language and the PostgreSQL database (with the PostGIS extension) form a powerful
duo of processing and storage.

The one slow process within the ETL scripts is the loading of CSV records into
PostgreSQL. This is likely due to the 2-step conversion from CSV to a Julia dataframe
and then from a dataframe to SQL for inserting into PostgreSQL. Based on experience
with other ETL projects and discussions in online forums, this 2-step process can
be improved by transforming the CSV records directly into SQL in batches.

Another detail in this project that can be improved is the relative severity scale
created to have number to compare earthquakes to storms to wildfires. The method
for assigning a severity number (1-10) is crude and requires more research to find
an appropriate scale for comparing disaster events.

## Other Questions

### What if the data was increased by 100x?

If the data of this reporting database is increased by 100x a distributed processing
mechanism could be used to ensure that ETL times remain reasonable. The Julia language
has a Spark-like work distribution system where many remote Julia "nodes" can
parallelize the ETL workload.

### What if the pipelines were run on a daily basis by 7am?

If this reporting database needs to be run daily at 7am, some form of orchestrator
similar to Apache Airflow needs to be employed. Based on the maturity of Apache
Airflow it should be possible to use the bash operator to launch Julia scripts in
order to provide a familiar orchestration framework to end users.

### What if the database needed to be accessed by 100+ people?

If this reporting database needs to be accessed by 100+ people on a daily basis,
say as an online service, several options are available. One option would be to
use the read-replica pattern to have multiple read-only databases to support the
query load. Another option would be to use an cloud-native database like Amazon
Redshift where multiple cores may be used on partitions of the reporting database.
