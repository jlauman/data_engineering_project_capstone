
drop table if exists public.wildfire
create table if not exists public.wildfire (
  id                   integer primary key,
  reporting_unit_name  text
);
