using FranklinUtils, Franklin, Markdown, Dates, TimeZones


function is_blogpost(post)
    rpath = joinpath(splitext(post)[1])
    category = pagevar(rpath, :category)
    category == "blog"
end

function get_all_blog_posts()
    first_year = globvar(:first_blog_year)
    this_year = year(Dates.today())
    all_posts = Dict()
    base = abspath("content")
    posts = filter!(p -> endswith(p, ".md"), readdir(base))
    filter!(f -> endswith(f, ".md"), posts)
    filter!(f -> !occursin("draft", f), posts)
    filter!(f -> is_blogpost(joinpath(base, f)), posts)
    all_posts = Dict()
    for (i, post) in enumerate(posts)
        posts[i] = rpath = joinpath(base, splitext(post)[1])
        @show rpath
        date = pagevar(rpath, :date)
        title = pagevar(rpath, :title)
        url = pagevar(rpath, :slug)
        all_posts[post] = Dict(:title => title, :date => date, :url => url)
    end
    all_posts
end

function hfun_blogposts()
    all_posts = get_all_blog_posts()
    io = IOBuffer()
    write(io, "")
    write(io, "<div class=\"tocwrapper\">\n")
    for (k,v) in all_posts
        url = v[:url]
        title = v[:title]
        date = v[:date]
        k = """<p>
          <span class="toclink">
            <a href="$(url)">$(title)</a>
          </span>
          <span class="tocdate">
            $(monthabbr(date)), $(year(date))
          </span>
        </p>"""
        write(io, """$k\n""")
    end
    write(io, "</div>\n")
    write(io, "")
    return String(take!(io))
end


function hfun_title()
    io = IOBuffer()
    write(io, "")
    write(io, """<h1 class="title">\n""")
    write(io, """<a class="home" href="https://kdheepak.com">~</a> / blog""")
    write(io, """</h1>\n""")
    write(io, "")
    date = Dates.today()
    write(io, """
    <p class="subtitle sourceurl">
        <a class="sourceurl" target="_blank" href="https://github.com/kdheepak/blog/">
            $(dayabbr(date)), $(monthabbr(date)) $(day(date)), $(year(date))
        </a>
    </p>
    """)
    return String(take!(io))
end
