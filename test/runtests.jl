tests = ["parse", "create", "cdata", "getindex"]

for t in tests
    fpath = "$t.jl"
    @printf("running %s ...\n", fpath)
    include(fpath)
end
