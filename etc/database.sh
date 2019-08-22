# these come from container environment
export PGUSER=$POSTGRES_USER
export PGPASSWORD=$POSTGRES_PASSWORD


psql --dbname=template1 --command="create extension if not exists \"pgcrypto\";"

psql --dbname=template1 --command="create extension if not exists \"postgis\";"

psql --dbname=template1 --command="create extension if not exists \"postgis_topology\";"

psql --dbname=postgres --command "create role disaster login encrypted password 'Iej0xooV5quo4vahnaKi'";

psql --dbname=postgres --command "create database \"disaster\" with owner disaster";
