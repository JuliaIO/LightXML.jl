
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

	function XMLDocument()
		# create an empty document
		ptr = ccall(xmlNewDoc, Xptr, (Ptr{Cchar},), "1.0")
		XMLDocument(ptr)	
	end
end

version(xdoc::XMLDocument) = bytestring(xdoc._struct.version)
encoding(xdoc::XMLDocument) = bytestring(xdoc._struct.encoding)
compression(xdoc::XMLDocument) = int(xdoc._struct.compression)
standalone(xdoc::XMLDocument) = int(xdoc._struct.standalone)

function root(xdoc::XMLDocument)
	pr = ccall(xmlDocGetRootElement, Ptr{Void}, (Ptr{Void},), xdoc.ptr)
	pr != nullptr || throw(XMLNoRootError())
	XMLElement(pr)
end


#### construction & free

function free(xdoc::XMLDocument)
	ccall(xmlFreeDoc, Void, (Ptr{Void},), xdoc.ptr)
	xdoc.ptr = nullptr
end

function set_root(xdoc::XMLDocument, xroot::XMLElement)
	ccall(xmlDocSetRootElement, Xptr, (Xptr, Xptr), xdoc.ptr, xroot.node.ptr)
end

function create_root(xdoc::XMLDocument, name::String)
	xroot = new_element(name)
	set_root(xdoc, xroot)
	return xroot
end

#### parse and free

function parse_file(filename::String)
	p = ccall(xmlParseFile, Xptr, (Ptr{Cchar},), filename)
	p != nullptr || throw(XMLParseError("Failure in parsing an XML file."))
	XMLDocument(p)
end

function parse_string(s::String)
	p = ccall(xmlParseMemory, Xptr, (Ptr{Cchar}, Cint), s, length(s) + 1)
	p != nullptr || throw(XMLParseError("Failure in parsing an XML string."))
	XMLDocument(p)
end


#### output

function save_file(xdoc::XMLDocument, filename::String; encoding::String="utf-8")
	ret = ccall(xmlSaveFormatFileEnc, Cint, (Ptr{Cchar}, Xptr, Ptr{Cchar}, Cint), 
		filename, xdoc.ptr, encoding, 1)
	if ret < 0
		throw(XMLWriteError("Failed to save XML to file $filename"))
	end
	return int(ret)  # number of bytes written
end

function Base.string(xdoc::XMLDocument; encoding::String="utf-8")	
	buf_out = Array(Xstr, 1)
	len_out = Array(Cint, 1)
	ccall(xmlDocDumpFormatMemoryEnc, Void, (Xptr, Ptr{Xstr}, Ptr{Cint}, Ptr{Cchar}, Cint), 
		xdoc.ptr, buf_out, len_out, encoding, 1)
	_xcopystr(buf_out[1])
end

Base.show(io::IO, xdoc::XMLDocument) = println(io, Base.string(xdoc))


