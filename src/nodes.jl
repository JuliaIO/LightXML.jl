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
	name::Ptr{Cchar}
	children::Ptr{Void}
	last::Ptr{Void}
	parent::Ptr{Void}
	next::Ptr{Void}
	prev::Ptr{Void}
	doc::Ptr{Void}

	# specific part	
	ns::Ptr{Void}
	atype::Cint
	psvi::Ptr{Void}
end


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
	children::Ptr{Void}
	last::Ptr{Void}
	parent::Ptr{Void}
	next::Ptr{Void}
	prev::Ptr{Void}
	doc::Ptr{Void}

	# specific part
	ns::Ptr{Void}
	content::Ptr{Void}
	attr::Ptr{Void}
	nsdef::Ptr{Void}
	psvi::Ptr{Void}
	line::Cushort
	extra::Cushort
end

type XMLNode <: AbstractXMLNode
	ptr::Ptr{Void}
	_struct::_XMLNodeStruct

	function XMLNode(ptr::Ptr{Void})		
		s = unsafe_load(convert(Ptr{_XMLNodeStruct}, ptr))
		new(ptr, s)
	end
end

name(nd::XMLNode) = bytestring(nd._struct.name)
nodetype(nd::XMLNode) = nd._struct.nodetype
has_children(nd::XMLNode) = (nd._struct.children != nullptr)

# iteration over children

immutable XMLNodeIter
	p::Ptr{Void}
end

Base.start(it::XMLNodeIter) = it.p
Base.done(it::XMLNodeIter, p::Ptr{Void}) = (p == nullptr)
Base.next(it::XMLNodeIter, p::Ptr{Void}) = (nd = XMLNode(p); (nd, nd._struct.next))

children(nd::XMLNode) = XMLNodeIter(nd._struct.children) 

function content(nd::XMLNode)
	pct = ccall(xmlNodeGetContent, Ptr{Uint8}, (Ptr{Void},), nd.ptr)
	_xcopystr(pct)::ASCIIString
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

	XMLElement(ptr::Ptr{Void}) = XMLElement(XMLNode(ptr))
end

name(x::XMLElement) = name(x.node)
nodetype(nd::XMLElement) = XML_ELEMENT_NODE
has_children(nd::XMLElement) = has_children(x.node)
children(x::XMLElement) = children(x.node)
content(x::XMLElement) = content(x.node)









