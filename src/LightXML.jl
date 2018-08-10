VERSION < v"0.7.0-beta2.199" && __precompile__()

module LightXML

using Compat

let depsfile = joinpath(@__DIR__, "..", "deps", "deps.jl")
    if !isfile(depsfile)
        error("LightXML is not properly installed. Run `Pkg.build(\"LightXML\")` and " *
              "restart Julia.")
    end
    include(depsfile)
end
check_deps()

export
    # common
    name, free,

    # nodes
    AbstractXMLNode,
    XMLAttr, XMLAttrIter, XMLNode, XMLNodeIter, XMLElement, XMLElementIter,
    nodetype, value, content, attribute, has_attribute,
    is_elementnode, is_textnode, is_commentnode, is_cdatanode, is_blanknode, is_pinode,
    child_nodes, has_children, attributes, has_attributes, attributes_dict,
    child_elements, find_element, get_elements_by_tagname,

    new_element, add_child, new_child, new_textnode, add_text, add_cdata, add_pi,
    set_attribute, set_attributes, unlink, set_content,

    # document
    XMLDocument, version, encoding, compression, standalone, root,
    parse_file, parse_string, save_file, set_root, create_root

const Xchar = UInt8
const Xstr = Ptr{Xchar}

# opaque pointer type (do not dereference!) corresponding to xmlBufferPtr in C
struct xmlBuffer end
const Xptr = Ptr{xmlBuffer}

# pre-condition: p is not null
# (After tests, it seems that free in libc instead of xmlFree
#  should be used here.)
function _xcopystr(p::Xstr)
    r = unsafe_string(p)
    Libc.free(p)
    return r
end

include("errors.jl")

include("utils.jl")
include("nodes.jl")
include("document.jl")
include("cdata.jl")

end
