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
	(pct != nullptr ? _xcopystr(pct) : "")::ASCIIString
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
	(pct != nullptr ? _xcopystr(pct) : "")::ASCIIString
end


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

# attribute access

function attribute(x::XMLElement, name::ASCIIString)
	pv = ccall(xmlGetProp, Xstr, (Xptr, Xstr), x.node.ptr, name)
	pv != nullptr || throw(XMLAttributeNotFound())
	_xcopystr(pv)
end

has_attributes(x::XMLElement) = (x.node._struct.attrs != nullptr)
attributes(x::XMLElement) = XMLAttrIter(x.node._struct.attrs)

# element access

immutable XMLElementIter
	parent_ptr::Xptr
end

Base.start(it::XMLElementIter) = ccall(xmlFirstElementChild, Xptr, (Xptr,), it.parent_ptr)
Base.done(it::XMLElementIter, p::Xptr) = (p == nullptr)
Base.next(it::XMLElementIter, p::Xptr) = (XMLElement(p), ccall(xmlNextElementSibling, Xptr, (Xptr,), p))

child_elements(x::XMLElement) = XMLElementIter(x.node.ptr)

# elements by tag name

function find_element(x::XMLElement, n::ASCIIString)
	for c in child_elements(x)
		if name(c) == n
			return c
		end
	end 
	return nothing
end

function get_elements_by_tagname(x::XMLElement, n::ASCIIString)
	lst = Array(XMLElement, 0)
	for c in child_elements(x)
		if name(c) == n
			push!(lst, c)
		end
	end 
	return lst
end

