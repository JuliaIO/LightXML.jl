__precompile__()

module LightXML

using Compat

# We do not actually support calling these, since the traits are not defined
import Base: SizeUnknown, IsInfinite, HasLength
import Base: start, done, next, show, getindex, show, string, length

const libxml2 =
    (Compat.Sys.iswindows()
     ? Pkg.dir("WinRPM", "deps", "usr", "$(Sys.ARCH)-w64-mingw32", "sys-root", "mingw",
               "bin", "libxml2-2")
     : "libxml2")

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
