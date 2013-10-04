
#### Document type

immutable _XMLDocStruct  # use the same layout as C
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
	compression::Cint
	standalone::Cint
	intsubset::Ptr{Void}
	extsubset::Ptr{Void}
	oldns::Ptr{Void}
	version::Ptr{Uint8}
	encoding::Ptr{Uint8}

	ids::Ptr{Void}
	refs::Ptr{Void}
	url::Ptr{Uint8}
	charset::Cint
	dict::Ptr{Void}
	psvi::Ptr{Void}
	parseflags::Cint
	properties::Cint
end

type XMLDocument
	ptr::Ptr{Void}
	_struct::_XMLDocStruct

	function XMLDocument(ptr::Ptr{Void})
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

