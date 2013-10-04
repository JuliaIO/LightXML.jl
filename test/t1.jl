using MiniDOM

xdoc = parsefile("ex1.xml")

@assert version(xdoc) == "1.0"
@assert encoding(xdoc) == "UTF-8"
@assert compression(xdoc) == 0
@assert standalone(xdoc) == -2

function dump(nd::AbstractXMLNode, level::Int)
	print(repeat(" ", level * 4))
	@printf("%s (%d)\n", name(nd), nodetype(nd), strip(content(nd)))
	for c in children(nd)
		dump(c, level + 1)
	end
end

dump(docelement(xdoc), 0)

free(xdoc)

