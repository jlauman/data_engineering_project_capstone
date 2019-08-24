println("\n\nmake_d_severity: start")

prepend!(LOAD_PATH, ["Project.toml"])
import LibPQ

DISASTER_PASSWORD = read("./etc/disaster-pass", String)

postgres = LibPQ.Connection("host=127.0.0.1 port=5432 dbname=disaster user=disaster password=$DISASTER_PASSWORD")

sql =
"""
drop table if exists public.d_severity;
create table if not exists public.d_severity (
    d_severity_id  integer primary key
);

do \$body\$
declare
    _value  integer;
begin
    for _value in select generate_series(1, 10, 1) loop
        -- raise notice '_value=%', _value;
        insert into public.d_severity (
            d_severity_id
        ) values (
            _value
        ) on conflict do nothing;
    end loop;

end; \$body\$ language plpgsql;
"""
LibPQ.execute(postgres, sql)
LibPQ.close(postgres)


println("make_d_severity: stop")
