using LightXML
using Compat
@static VERSION < v"0.7.0-DEV" ? (using Base.Test) : (using Test)

tests = ["parse", "create", "cdata"]

for t in tests
    fpath = "$t.jl"
    println("running $fpath ...")
    include(fpath)
end
