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

	new_node, add_child, new_child, add_text, set_attribute,

	# document
	XMLDocument, version, encoding, compression, standalone, root, 
	parse_file, parse_string, save_file, set_root, create_root
	

	include("clib.jl")
	include("errors.jl")

	include("utils.jl")
	include("nodes.jl")
	include("document.jl")
end
