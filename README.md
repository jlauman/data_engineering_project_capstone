# Data Engineering Capstone Project

This is a Udacity Data Engineering Nanoegree open-ended capstone project.


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
data set selection (specifically for this project) is the data sets sources
must be different organizations (not from an aggregator/broker) and the formats
must me varied (not just CSV).


### United States Wildfires, 1992-2015

This data set includes 1.88 million geo-referenced wildfire records over a
24-year period. This data is known as the Fire Program Analysis fire-occurrence
database.

The source of this data set is:

  https://www.fs.usda.gov/rds/archive/catalog/RDS-2013-0009.4

  https://www.nwcg.gov/term/glossary/size-class-of-fire

The format selected for this project is the SQLite database.


### NOAA Storm Events Database, 1950-2018

This is the NOAA National Weather Service (NWS) database for storm events. The
expectation is this will be a large data set and the ETL process will identify
fields within the records that may be used to define a storm as extreme or
anomalous.

The source of this data set is:

  https://www.ncdc.noaa.gov/stormevents/ftp.jsp

The format selected for this project is CSV files.

  ftp://ftp.ncdc.noaa.gov/pub/data/swdi/stormevents/csvfiles/


### USGS Earthquake Catalog, API

This data set is provided by the National Earthquake Hazards Reduction Program
(NEHRP) led by the National Institutes of Standards and Technology (NIST) and
part of the Earthquake Hazards Program with the U.S. Geological Survey (USGS).

The starting URL for this data source is:

  https://earthquake.usgs.gov/ws/

The data dictionary is:

  https://earthquake.usgs.gov/data/comcat/data-eventterms.php

The data set is available through a web API and results specified through URL
query parameters as shown below.

  https://wiki.openstreetmap.org/wiki/Bounding_Box

  bbox = left,bottom,right,top
  bbox = min Longitude , min Latitude , max Longitude , max Latitude

  https://boundingbox.klokantech.com/

  westlimit=-170.0; southlimit=15.0; eastlimit=-59.9; northlimit=72.0

  minlongitude=-170
  minlatitude=15
  maxlongitude=-60
  maxlatitude=72

  https://earthquake.usgs.gov/fdsnws/event/1/query?format=text&starttime=1992-01-01&endtime=1992-03-31&minlongitude=-170&minlatitude=15&maxlongitude=-60&maxlatitude=72



The format selected for this project is XML.


There are limits on record counts the web API may return.

  Error 400: Bad Request
  286412 matching events exceeds search limit of 20000. Modify the search to match fewer events.
  Usage details are available from https://earthquake.usgs.gov/fdsnws/event/1
  Request Submitted: 2019-08-11T17:50:26+00:00
  Service version: 1.8.1



https://pe.usps.com/text/pub28/28apb.htm


## United States Census Bureau Gazetteer Files

ZIP Code Tabulation Areas

Urban Areas

  https://www.census.gov/geographies/reference-files/time-series/geo/gazetteer-files.2015.html


fires, storms, flooding, heat-waves and cold-snaps

  sqlite3 data/fs_usda_wildfire/Data/FPA_FOD_20170508.sqlite "select count(*) from Fires;"
  1880465

  load_s_wildfire: elapsed time is 17 minutes, 13 seconds, 630 milliseconds


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

  load_s_earthquake: elapsed time is 3 minutes, 23 seconds, 930 milliseconds


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

   load_s_storm: elapsed time is 11 minutes, 58 seconds, 821 milliseconds


   $ du -h data
    65M	data/usgs_earthquake
   108K	data/fs_usda_wildfire/Supplements
   773M	data/fs_usda_wildfire/Data
   939M	data/fs_usda_wildfire
   1014M	data/noaa_storm
   2.0G	data

## PostgreSQL 11 with PostGIS Extension

https://hub.docker.com/_/postgres

https://github.com/appropriate/docker-postgis/blob/f6d28e4a1871b1f72e1c893ff103f10b6d7cb6e1/10-2.4/Dockerfile


http://www.silota.com/docs/sql-load-data/shapefile-postgis.html
extname           extowner extnamespace extrelocatable extversion
plpgsql	          10	11	  false	 1.0
pgcrypto	        10	2200	true	 1.3
postgis	          10	2200	false	 2.5.2
postgis_topology	10	34395	false	 2.5.2


## State FIPS Codes

  https://www.census.gov/geographies/reference-files/2015/demo/popest/2015-fips.html


https://www.census.gov/programs-surveys/geography/guidance/geo-identifiers.html

https://www2.census.gov/geo/pdfs/maps-data/data/tiger/tgrshp2017/TGRSHP2017_TechDoc_Ch3.pdf

https://www.census.gov/programs-surveys/geography.html

https://www.census.gov/cgi-bin/geo/shapefiles/index.php

  select year: 2015
  select layer type: Counties (and equivalent)

  select year: 2015
  select layer type: ZIP Code Tabulation Areas


ogr2ogr -nlt PROMOTE_TO_MULTI -f PGDump -t_srs "EPSG:4326" tl_2015_us_county.sql tl_2015_us_county.shp

psql --host=127.0.0.1 --user=disaster --dbname=disaster --file=tl_2015_us_county.sql


https://en.wikipedia.org/wiki/Spatial_reference_system

https://spatialreference.org/ref/epsg/4326/

https://gist.github.com/clhenrick/ebc8dc779fb6f5ee6a88#postgis-1


SELECT statefp, state_name, namelsad FROM tl_2015_us_county
join s_state_geocode ST on ST.state_fips = statefp
where
st_contains(
  tl_2015_us_county.wkb_geometry,
  ST_GeomFromText('Point(-110.588484 39.673284)', 4326)      
);
