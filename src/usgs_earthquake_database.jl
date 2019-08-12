using Dates
import HTTP

# r = HTTP.request("GET", "http://httpbin.org/ip"; verbose=3)
# println(r.status)
# println(String(r.body))

years = collect(1992:2015)
months = collect(1:12)

println("years=", years)
println("months=", months)

make_url(starttime, endtime) = "https://earthquake.usgs.gov/fdsnws/event/1/query?format=csv&starttime=$(starttime)&endtime=$(endtime)&minlongitude=-170&minlatitude=15&maxlongitude=-60&maxlatitude=72"

format = DateFormat("yyyy-m-d");
base = "./data/usgs_earthquake"
mkpath(base)

for year in years
    path = joinpath(base, "$(year).csv")
    open(path, "w") do file
        for month in months
            dt1 = DateTime(year, month, 1)
            dt2 = lastdayofmonth(dt1)
            starttime = Dates.format(dt1, format)
            endtime = Dates.format(dt2, format)
            println("starttime=$(starttime)&endtime=$(endtime)")
            url =  make_url(starttime, endtime)
            # println(url)
            response = HTTP.request("GET", url)
            # println(String(response.body))
            content = String(response.body)
            if month != 1
                content = content[findfirst("\n", content).start+1:lastindex(content)]
            end
            write(file, content)
        end
        run(`wc -l $(path)`)
        exit(0)
    end
end
