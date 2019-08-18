prepend!(LOAD_PATH, ["Project.toml"])

using FTPClient

years = collect(1992:2015)

base = "./data/noaa_storm"
mkpath(base)

ftp = FTP(hostname="ftp.ncdc.noaa.gov/pub/data/swdi/stormevents/csvfiles/")
println("pwd=", pwd(ftp))

for filename in readdir(ftp)
    if endswith(filename, ".csv.gz")
        m = match(r"_d(\d{4})_", filename)
        if m !== nothing && length(m.captures) == 1
            year = parse(Int, m.captures[1])
            if in(year, years)
                println("filename=", filename)
                target = joinpath(base, filename)
                download(ftp, filename, target)
                run(`gunzip $target`)
            end
        end
    end
end
