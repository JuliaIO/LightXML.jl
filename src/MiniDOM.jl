module MiniDOM

	export 

	# types
	XMLNode, XMLDocument, XMLElement, 

	# nodes
	AbstractXMLNode, 
	XMLAttr, XMLAttrIter, XMLNode, XMLNodeIter, 
	name, nodetype, value, content, attribute,
	is_elementnode, is_textnode, is_commentnode, is_cdatanode,
	children, has_children, attributes, has_attributes,

	# document
	parsefile, free, version, encoding, compression, standalone, 
	docelement

	include("clib.jl")
	include("errors.jl")

	include("nodes.jl")
	include("document.jl")
end
