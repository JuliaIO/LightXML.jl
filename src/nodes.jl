# XML nodes

abstract AbstractXMLNode

#### Types of attributes

const XML_ATTRIBUTE_CDATA = 1
const XML_ATTRIBUTE_ID = 2
const XML_ATTRIBUTE_IDREF = 3
const XML_ATTRIBUTE_IDREFS = 4
const XML_ATTRIBUTE_ENTITY = 5
const XML_ATTRIBUTE_ENTITIES = 6
const XML_ATTRIBUTE_NMTOKEN = 7
const XML_ATTRIBUTE_NMTOKENS = 8
const XML_ATTRIBUTE_ENUMERATION = 9
const XML_ATTRIBUTE_NOTATION = 10

#### Types of nodes

const XML_ELEMENT_NODE = 1
const XML_ATTRIBUTE_NODE = 2
const XML_TEXT_NODE = 3
const XML_CDATA_SECTION_NODE = 4
const XML_ENTITY_REF_NODE = 5
const XML_ENTITY_NODE = 6
const XML_PI_NODE = 7
const XML_COMMENT_NODE = 8
const XML_DOCUMENT_NODE = 9
const XML_DOCUMENT_TYPE_NODE = 10
const XML_DOCUMENT_FRAG_NODE = 11
const XML_NOTATION_NODE = 12
const XML_HTML_DOCUMENT_NODE = 13
const XML_DTD_NODE = 14
const XML_ELEMENT_DECL = 15
const XML_ATTRIBUTE_DECL = 16
const XML_ENTITY_DECL = 17
const XML_NAMESPACE_DECL = 18
const XML_XINCLUDE_START = 19
const XML_XINCLUDE_END = 20
const XML_DOCB_DOCUMENT_NODE = 21

##### Generic methods

is_elementnode(nd::AbstractXMLNode) = (nodetype(nd) == XML_ELEMENT_NODE)
is_textnode(nd::AbstractXMLNode) = (nodetype(nd) == XML_TEXT_NODE)
is_commentnode(nd::AbstractXMLNode) = (nodetype(nd) == XML_COMMENT_NODE)
is_cdatanode(nd::AbstractXMLNode) = (nodetype(nd) == XML_CDATA_SECTION_NODE)


#######################################
#
#  XML Attributes
#
#######################################

immutable _XMLAttrStruct
    # common part
    _private::Ptr{Void}
    nodetype::Cint
    name::Xstr
    children::Xptr
    last::Xptr
    parent::Xptr
    next::Xptr
    prev::Xptr
    doc::Xptr

    # specific part
    ns::Xptr
    atype::Cint
    psvi::Ptr{Void}
end

type XMLAttr
    ptr::Xptr
    _struct::_XMLAttrStruct

    function XMLAttr(ptr::Xptr)
        s = unsafe_load(convert(Ptr{_XMLAttrStruct}, ptr))
        @assert s.nodetype == XML_ATTRIBUTE_NODE
        new(ptr, s)
    end
end

name(a::XMLAttr) = bytestring(a._struct.name)

function value(a::XMLAttr)
    pct = ccall(xmlNodeGetContent, Xstr, (Xptr,), a._struct.children)
    (pct != nullptr ? _xcopystr(pct) : "")::String
end

# iterations

immutable XMLAttrIter
    p::Xptr
end

Base.start(it::XMLAttrIter) = it.p
Base.done(it::XMLAttrIter, p::Xptr) = (p == nullptr)
Base.next(it::XMLAttrIter, p::Xptr) = (a = XMLAttr(p); (a, a._struct.next))


#######################################
#
#  Base XML Nodes
#
#######################################

immutable _XMLNodeStruct
    # common part
    _private::Ptr{Void}
    nodetype::Cint
    name::Ptr{Cchar}
    children::Xptr
    last::Xptr
    parent::Xptr
    next::Xptr
    prev::Xptr
    doc::Xptr

    # specific part
    ns::Xptr
    content::Xstr
    attrs::Xptr
    nsdef::Xptr
    psvi::Ptr{Void}
    line::Cushort
    extra::Cushort
end

type XMLNode <: AbstractXMLNode
    ptr::Xptr
    _struct::_XMLNodeStruct

    function XMLNode(ptr::Xptr)
        s = unsafe_load(convert(Ptr{_XMLNodeStruct}, ptr))
        new(ptr, s)
    end
end

name(nd::XMLNode) = bytestring(nd._struct.name)
nodetype(nd::XMLNode) = nd._struct.nodetype
has_children(nd::XMLNode) = (nd._struct.children != nullptr)

# whether it is a white-space only text node
is_blanknode(nd::XMLNode) = bool(ccall(xmlIsBlankNode, Cint, (Xptr,), nd.ptr))

function free(nd::XMLNode)
    ccall(xmlFreeNode, Void, (Ptr{Void},), nd.ptr)
    nd.ptr = nullptr
end

# iteration over children

immutable XMLNodeIter
    p::Xptr
end

Base.start(it::XMLNodeIter) = it.p
Base.done(it::XMLNodeIter, p::Xptr) = (p == nullptr)
Base.next(it::XMLNodeIter, p::Xptr) = (nd = XMLNode(p); (nd, nd._struct.next))

child_nodes(nd::XMLNode) = XMLNodeIter(nd._struct.children)

function content(nd::XMLNode)
    pct = ccall(xmlNodeGetContent, Xstr, (Xptr,), nd.ptr)
    (pct != nullptr ? _xcopystr(pct) : "")::String
end

# dumping

const DEFAULT_DUMPBUFFER_SIZE = 4096

function Base.string(nd::XMLNode)
    buf = XBuffer(DEFAULT_DUMPBUFFER_SIZE)
    ccall(xmlNodeDump, Cint, (Xptr, Xptr, Xptr, Cint, Cint),
        buf.ptr, nd._struct.doc, nd.ptr, 0, 1)
    r = content(buf)
    free(buf)
    return r
end

Base.show(io::IO, nd::XMLNode) = println(io, string(nd))


#######################################
#
#  XML Elements
#
#######################################

type XMLElement <: AbstractXMLNode
    node::XMLNode

    function XMLElement(node::XMLNode)
        if !is_elementnode(node)
            throw(ArgumentError("The input node is not an element."))
        end
        new(node)
    end

    XMLElement(ptr::Xptr) = XMLElement(XMLNode(ptr))
end

name(x::XMLElement) = name(x.node)
nodetype(x::XMLElement) = XML_ELEMENT_NODE
has_children(x::XMLElement) = has_children(x.node)
child_nodes(x::XMLElement) = child_nodes(x.node)
content(x::XMLElement) = content(x.node)

Base.string(x::XMLElement) = string(x.node)
Base.show(io::IO, x::XMLElement) = show(io, x.node)

free(x::XMLElement) = free(x.node)

# attribute access

function attribute(x::XMLElement, name::String; required::Bool=false)
    pv = ccall(xmlGetProp, Xstr, (Xptr, Xstr), x.node.ptr, name)
    if pv != nullptr
        return _xcopystr(pv)
    else
        if required
            throw(XMLAttributeNotFound())
        else
            return nothing
        end
    end
end

function has_attribute(x::XMLElement, name::String)
    p = ccall(xmlHasProp, Xptr, (Xptr, Xstr), x.node.ptr, name)
    return p != nullptr
end

has_attributes(x::XMLElement) = (x.node._struct.attrs != nullptr)
attributes(x::XMLElement) = XMLAttrIter(x.node._struct.attrs)

function attributes_dict(x::XMLElement)
    # make an dictionary based on attributes

    dct = Dict{String,String}()
    if has_attributes(x)
        for a in attributes(x)
            dct[name(a)] = value(a)
        end
    end
    return dct
end


# element access

immutable XMLElementIter
    parent_ptr::Xptr
end

Base.start(it::XMLElementIter) = ccall(xmlFirstElementChild, Xptr, (Xptr,), it.parent_ptr)
Base.done(it::XMLElementIter, p::Xptr) = (p == nullptr)
Base.next(it::XMLElementIter, p::Xptr) = (XMLElement(p), ccall(xmlNextElementSibling, Xptr, (Xptr,), p))

child_elements(x::XMLElement) = XMLElementIter(x.node.ptr)

# elements by tag name

function find_element(x::XMLElement, n::String)
    for c in child_elements(x)
        if name(c) == n
            return c
        end
    end
    return nothing
end

function get_elements_by_tagname(x::XMLElement, n::String)
    lst = Array(XMLElement, 0)
    for c in child_elements(x)
        if name(c) == n
            push!(lst, c)
        end
    end
    return lst
end


#######################################
#
#  XML Tree Construction
#
#######################################

function new_element(name::String)
    p = ccall(xmlNewNode, Xptr, (Xptr, Xstr), nullptr, name)
    XMLElement(p)
end

function add_child(xparent::XMLElement, xchild::XMLNode)
    p = ccall(xmlAddChild, Xptr, (Xptr, Xptr), xparent.node.ptr, xchild.ptr)
    p != nullptr || throw(XMLTreeError("Failed to add a child node."))
end

add_child(xparent::XMLElement, xchild::XMLElement) = add_child(xparent, xchild.node)

function new_child(xparent::XMLElement, name::String)
    xc = new_element(name)
    add_child(xparent, xc)
    return xc
end

function new_textnode(txt::String)
    p = ccall(xmlNewText, Xptr, (Xstr,), txt)
    XMLNode(p)
end

add_text(x::XMLElement, txt::String) = add_child(x, new_textnode(txt))

function set_attribute(x::XMLElement, name::String, val::String)
    a = ccall(xmlSetProp, Xptr, (Xptr, Xstr, Xstr), x.node.ptr, name, val)
    return XMLAttr(a)
end

set_attribute(x::XMLElement, name::String, val) = set_attribute(x, name, string(val))

function set_attributes{P<:NTuple{2}}(x::XMLElement, attrs::AbstractArray{P})
    for (nam, val) in attrs
        set_attribute(x, string(nam), string(val))
    end
end

set_attributes(x::XMLElement, attrs::Associative) = set_attributes(x, collect(attrs))

function set_attributes(x::XMLElement; attrs...)
    for (nam, val) in attrs
        set_attribute(x, string(nam), string(val))
    end
end
