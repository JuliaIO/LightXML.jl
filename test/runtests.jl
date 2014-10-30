tests = ["parse", "create", "cdata"]

for t in tests
    fpath = "$t.jl"
    @printf("running %s ...\n", fpath)
    include(fpath)
end
