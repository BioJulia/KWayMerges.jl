using Documenter, KWayMerges

# This code will be executed in the environment your doctests inside the
# package's docstrings are run.
# Use it to define some global variables that can be referred to in your
# docstrings.
meta = quote
    using KWayMerges
    data = "abcde"
end

DocMeta.setdocmeta!(KWayMerges, :DocTestSetup, meta; recursive=true)

makedocs(
    modules = [KWayMerges],
    sitename = "KWayMerges.jl",
    doctest = true,
    # These two pages are recommended, you can add more as you wish
    pages = [
        "KWayMerges" => "index.md",
        "Reference" => "reference.md",
    ],
    authors = "Jakob Nybo Nissen <jakobnybonissen@gmail.com>",
    checkdocs = :public,
    remotes=nothing
)

deploydocs(;
    repo="github.com/BioJulia/KWayMergess.jl.git",
    push_preview=true,
    deps=nothing,
    make=nothing,
)
