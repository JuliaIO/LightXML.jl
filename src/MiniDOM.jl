module MiniDOM

	export 

	# common
	name, free,

	# nodes
	AbstractXMLNode, 
	XMLAttr, XMLAttrIter, XMLNode, XMLNodeIter, XMLElement, XMLElementIter,
	nodetype, value, content, attribute,
	is_elementnode, is_textnode, is_commentnode, is_cdatanode,
	child_nodes, has_children, attributes, has_attributes, child_elements,
	find_element, get_elements_by_tagname,

	# document
	XMLDocument,
	parse_file, parse_string, version, encoding, compression, standalone, 
	docelement

	include("clib.jl")
	include("errors.jl")

	include("nodes.jl")
	include("document.jl")
end
