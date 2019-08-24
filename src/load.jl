
run(`julia ./src/load_s_state_geocodes.jl`)

run(`julia ./src/load_us_county_shp.jl`)

run(`julia ./src/load_s_earthquake.jl`)

run(`julia ./src/load_s_storm.jl`)

run(`julia ./src/load_s_wildfire.jl`)

run(`julia ./src/make_d_datestamp.jl`)

run(`julia ./src/make_d_location.jl`)

run(`julia ./src/make_f_earthquake.jl`)
