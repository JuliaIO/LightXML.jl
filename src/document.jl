
#### Document type

immutable _XMLDocStruct  # use the same layout as C
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
	compression::Cint
	standalone::Cint
	intsubset::Xptr
	extsubset::Xptr
	oldns::Xptr
	version::Xstr
	encoding::Xstr

	ids::Ptr{Void}
	refs::Ptr{Void}
	url::Xstr
	charset::Cint
	dict::Xstr
	psvi::Ptr{Void}
	parseflags::Cint
	properties::Cint
end

type XMLDocument
	ptr::Xptr
	_struct::_XMLDocStruct

	function XMLDocument(ptr::Xptr)
		s::_XMLDocStruct = unsafe_load(convert(Ptr{_XMLDocStruct}, ptr))

		# validate integrity
		@assert s.nodetype == XML_DOCUMENT_NODE
		@assert s.doc == ptr

		new(ptr, s)
	end
end

version(xdoc::XMLDocument) = bytestring(xdoc._struct.version)
encoding(xdoc::XMLDocument) = bytestring(xdoc._struct.encoding)
compression(xdoc::XMLDocument) = int(xdoc._struct.compression)
standalone(xdoc::XMLDocument) = int(xdoc._struct.standalone)

function docelement(xdoc::XMLDocument)
	pr = ccall(xmlDocGetRootElement, Ptr{Void}, (Ptr{Void},), xdoc.ptr)
	pr != nullptr || throw(XMLNoRootError())
	XMLElement(pr)
end

#### parse and free

function parsefile(filename::ASCIIString)
	p = ccall(xmlParseFile, Ptr{Void}, (Ptr{Cchar},), filename)
	p != nullptr || throw(XMLParseError("Failure in parsing an XML file."))
	XMLDocument(p)
end

function free(xdoc::XMLDocument)
	ccall(xmlFreeDoc, Void, (Ptr{Void},), xdoc.ptr)
	xdoc.ptr = nullptr
end

