module MiniDOM

	export 

	# types
	XMLNode, XMLDocument, XMLElement, 

	# document
	parsefile, free, version, encoding, compression, standalone


	include("clib.jl")
	include("errors.jl")

	include("nodes.jl")
	include("document.jl")
end
