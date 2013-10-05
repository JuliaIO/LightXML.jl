
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


#### construction & free

function free(xdoc::XMLDocument)
	ccall(xmlFreeDoc, Void, (Ptr{Void},), xdoc.ptr)
	xdoc.ptr = nullptr
end


#### parse and free

function parse_file(filename::ASCIIString)
	p = ccall(xmlParseFile, Xptr, (Ptr{Cchar},), filename)
	p != nullptr || throw(XMLParseError("Failure in parsing an XML file."))
	XMLDocument(p)
end

function parse_string(s::ASCIIString)
	p = ccall(xmlParseMemory, Xptr, (Ptr{Cchar}, Cint), s, length(s) + 1)
	p != nullptr || throw(XMLParseError("Failure in parsing an XML string."))
	XMLDocument(p)
end


#### output

function save_file(xdoc::XMLDocument, filename::ASCIIString; encoding::ASCIIString="utf-8")
	ret = ccall(xmlSaveFileEnc, Cint, (Ptr{Cchar}, Xptr, Ptr{Cchar}), 
		filename, xdoc.ptr, encoding)
	if ret < 0
		throw(XMLWriteError("Failed to save XML to file $filename"))
	end
	return int(ret)  # number of bytes written
end

function Base.string(xdoc::XMLDocument; encoding::ASCIIString="utf-8")	
	buf_out = Array(Xstr, 1)
	len_out = Array(Cint, 1)
	ccall(xmlDocDumpMemoryEnc, Void, (Xptr, Ptr{Xstr}, Ptr{Cint}, Ptr{Cchar}), 
		xdoc.ptr, buf_out, len_out, encoding)
	_xcopystr(buf_out[1])
end

Base.show(io::IO, xdoc::XMLDocument) = println(io, Base.string(xdoc))


