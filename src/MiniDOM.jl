module MiniDOM

	export 

	# types
	XMLNode, XMLDocument, XMLElement, 

	# document
	parsefile, free


	include("clib.jl")
	include("types.jl")
	include("errors.jl")

	include("nodes.jl")
	include("document.jl")
end
