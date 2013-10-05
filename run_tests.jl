tests = ["parse", "create"]

for t in tests
	fpath = joinpath("test", "$t.jl")
	@printf("running %s ...\n", fpath)
	include(fpath)
end
