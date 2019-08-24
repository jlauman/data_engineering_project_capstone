println("\n\nmake_d_location: start")

prepend!(LOAD_PATH, ["Project.toml"])
import LibPQ

DISASTER_PASSWORD = read("./etc/disaster-pass", String)

postgres = LibPQ.Connection("host=127.0.0.1 port=5432 dbname=disaster user=disaster password=$DISASTER_PASSWORD")

sql =
"""
drop table if exists public.d_datestamp;
create table if not exists public.d_datestamp (
    d_datestamp_id  date primary key,
    year          integer not null,
    month         integer not null,
    day           integer not null,
    weekofyear    integer not null
);

do \$body\$
declare
    _date  date;
begin
    for _date in select generate_series('1992-01-01'::date, '2015-12-31', '1 day') loop
        -- raise notice '_date=%', _date;
        insert into public.d_datestamp (
            d_datestamp_id,
            year,
            month,
            day,
            weekofyear
        ) values (
            _date,
            date_part('year', _date),
            date_part('month', _date),
            date_part('day', _date),
            date_part('week', _date)
        ) on conflict do nothing;
    end loop;

end; \$body\$ language plpgsql;
"""
LibPQ.execute(postgres, sql)
LibPQ.close(postgres)


println("make_d_location: stop")
