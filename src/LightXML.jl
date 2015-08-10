 __precompile__(false)

module LightXML

    export

    # common
    name, free,

    # nodes
    AbstractXMLNode,
    XMLAttr, XMLAttrIter, XMLNode, XMLNodeIter, XMLElement, XMLElementIter,
    nodetype, value, content, attribute, has_attribute,
    is_elementnode, is_textnode, is_commentnode, is_cdatanode, is_blanknode,
    child_nodes, has_children, attributes, has_attributes, attributes_dict,
    child_elements, find_element, get_elements_by_tagname,

    new_element, add_child, new_child, new_textnode, add_text, add_cdata,
    set_attribute, set_attributes, unlink,

    # document
    XMLDocument, version, encoding, compression, standalone, root,
    parse_file, parse_string, save_file, set_root, create_root

    using Compat
    include("clib.jl")
    include("errors.jl")

    include("utils.jl")
    include("nodes.jl")
    include("document.jl")
    include("cdata.jl")
end
