using MiniDOM

xdoc = parsefile("ex1.xml")

println(xdoc)

free(xdoc)

