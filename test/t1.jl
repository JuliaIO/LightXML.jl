using MiniDOM

xdoc = parsefile("ex1.xml")

println(version(xdoc))
println(encoding(xdoc))
println(compression(xdoc))
println(standalone(xdoc))

free(xdoc)

