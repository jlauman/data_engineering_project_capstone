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

The starting URL for this data sorce is:

  https://earthquake.usgs.gov/ws/

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


fires, storms, flooding, heat-waves and cold-snaps
