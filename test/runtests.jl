using LightXML
using Test

tests = ["parse", "create", "cdata", "pi", "validate"]

for t in tests
    fpath = "$t.jl"
    println("running $fpath ...")
    include(fpath)
end
