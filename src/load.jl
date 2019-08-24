# run all ETL scripts for the disaster database
using Dates


scripts = [
    "./src/load_s_state_geocodes.jl",
    "./src/load_us_county_shp.jl",
    "./src/load_s_earthquake.jl",
    "./src/load_s_storm.jl",
    "./src/load_s_wildfire.jl",
    "./src/make_d_datestamp.jl",
    "./src/make_d_location.jl",
    "./src/make_d_severity.jl",
    "./src/make_f_earthquake.jl",
    "./src/make_f_storm.jl",
    "./src/make_f_wildfire.jl"
];

load_starttime = Dates.now()
elapsed_times = [];
for script in scripts
    starttime = Dates.now()
    run(`julia $(script)`)
    endtime = Dates.now()
    push!(elapsed_times, "$(script): elapsed time is $(Dates.canonicalize(Dates.CompoundPeriod(endtime - starttime)))")
end

println("\n\nload...")
for elapsed_time in elapsed_times
    println(elapsed_time)
end

load_endtime = Dates.now()
println("load: total elapsed time is $(Dates.canonicalize(Dates.CompoundPeriod(load_endtime - load_starttime)))")
