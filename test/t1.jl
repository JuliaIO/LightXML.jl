using MiniDOM

xdoc = parsefile("ex1.xml")

@assert version(xdoc) == "1.0"
@assert encoding(xdoc) == "UTF-8"
@assert compression(xdoc) == 0
@assert standalone(xdoc) == -2

free(xdoc)

