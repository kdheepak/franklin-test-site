using FranklinUtils, Franklin, Markdown, Dates, TimeZones

function blogpost_date(b)
    open(b) do f
        r = read(f, String)
        m = match(r"date = DateTime(.*?)", r)
        ZonedDateTime(DateTime(string(only(m.captures))), tz"America/Denver")
    end
end

function is_blogpost(b)
    open(b) do f
        r = read(f, String)
        m = match(r"category = \"(.*?)\"", r)
        m != nothing ? string(only(m.captures)) == "blog" : false
    end
end

function hfun_blogposts()
    blogs = readdir(".")
    filter!(f -> endswith(f, ".md"), blogs)
    filter!(f -> !occursin("draft", f), blogs)
    filter!(f -> is_blogpost(f), blogs)
    @show blogs
    sort!(blogs, by = x -> blogpost_date(x))
    io = IOBuffer()
    @info " ... updating index"
    write(io, "")
    write(io, "<div class=\"tocwrapper\">\n")
    @show blogs
    for (i, b) in enumerate(blogs)
        title, date, category = open(b) do f
            r = read(f, String)
            m1 = match(r"title = \"(.*?)\"", r)
            m2 = match(r"date = DateTime\(\"(.*?)\"\)", r)
            m3 = match(r"category = \"(.*?)\"", r)
            string(only(m1.captures)), string(only(m2.captures)), string(only(m3.captures))
        end
        @show title, date, category
        date = ZonedDateTime(DateTime(date), tz"America/Denver")
        @info " .... processing page $title"
        pagename = first(splitext(b))
        k = """<p>
          <span class="toclink">
            <a href="/$(pagename)/">$(title)</a>
          </span>
          <span class="tocdate">
            $(month(date)), $(year(date))
          </span>
        </p>"""
        write(io, """$k\n""")
    end
    write(io, "</div>\n")
    write(io, "")
    return String(take!(io))
end
