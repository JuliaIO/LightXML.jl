module MiniDOM

	export 

	# types
	XMLNode, XMLDocument, XMLElement, 

	# nodes
	AbstractXMLNode,
	name, nodetype, is_elementnode, is_textnode, is_commentnode, is_cdatanode,
	XMLNode, XMLNodeIter, children, has_children, content,

	# document
	parsefile, free, version, encoding, compression, standalone, 
	docelement

	include("clib.jl")
	include("errors.jl")

	include("nodes.jl")
	include("document.jl")
end
