import Pkg

Pkg.add("FTPClient")

using FTPClient

ftp = FTP(hostname="ftp.ncdc.noaa.gov/pub/data/swdi/stormevents/csvfiles/")

println("pwd=", pwd(ftp))

mkpath("files")

for filename in readdir(ftp)
    if endswith(filename, ".csv.gz")
        println("filename=", filename)
        download(ftp, filename, joinpath("files", filename))
    end
end
