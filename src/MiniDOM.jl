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
	XMLDocument, version, encoding, compression, standalone, docelement, 
	parse_file, parse_string, save_file
	

	include("clib.jl")
	include("errors.jl")

	include("utils.jl")
	include("nodes.jl")
	include("document.jl")
end
