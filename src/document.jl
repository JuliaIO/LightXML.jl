
#### Document type

immutable _XMLDocStruct  # use the same layout as C
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
        ptr = ccall((:xmlNewDoc,libxml2), Xptr, (Cstring,), "1.0")
        XMLDocument(ptr)
    end
end

version(xdoc::XMLDocument) = bytestring(xdoc._struct.version)
function encoding(xdoc::XMLDocument)
    if xdoc._struct.encoding == C_NULL
        nothing
    else
        bytestring(xdoc._struct.encoding)
    end
end
compression(xdoc::XMLDocument) = @compat Int(xdoc._struct.compression)
standalone(xdoc::XMLDocument) = @compat Int(xdoc._struct.standalone)

function root(xdoc::XMLDocument)
    pr = ccall((:xmlDocGetRootElement,libxml2), Xptr, (Xptr,), xdoc.ptr)
    pr != C_NULL || throw(XMLNoRootError())
    XMLElement(pr)
end


#### construction & free

function free(xdoc::XMLDocument)
    ccall((:xmlFreeDoc,libxml2), Void, (Xptr,), xdoc.ptr)
    xdoc.ptr = C_NULL
end

function set_root(xdoc::XMLDocument, xroot::XMLElement)
    ccall((:xmlDocSetRootElement,libxml2), Xptr, (Xptr, Xptr), xdoc.ptr, xroot.node.ptr)
end

function create_root(xdoc::XMLDocument, name::AbstractString)
    xroot = new_element(name)
    set_root(xdoc, xroot)
    return xroot
end

#### parse and free

function parse_file(filename::AbstractString)
    p = ccall((:xmlParseFile,libxml2), Xptr, (Cstring,), filename)
    p != C_NULL || throw(XMLParseError("Failure in parsing an XML file."))
    XMLDocument(p)
end

function parse_file(filename::AbstractString, encoding, options::Integer)
    p = ccall((:xmlReadFile,libxml2), Xptr, (Cstring, Ptr{Cchar}, Cint),
        filename, encoding, options)
    p != C_NULL || throw(XMLParseError("Failure in parsing an XML file."))
    XMLDocument(p)
end

function parse_string(s::AbstractString)
    p = ccall((:xmlParseMemory,libxml2), Xptr, (Xstr, Cint), s, sizeof(s) + 1)
    p != C_NULL || throw(XMLParseError("Failure in parsing an XML string."))
    XMLDocument(p)
end


#### output

function save_file(xdoc::XMLDocument, filename::AbstractString; encoding::AbstractString="utf-8")
    ret = ccall((:xmlSaveFormatFileEnc,libxml2), Cint, (Cstring, Xptr, Cstring, Cint),
        filename, xdoc.ptr, encoding, 1)
    if ret < 0
        throw(XMLWriteError("Failed to save XML to file $filename"))
    end
    return @compat Int(ret)  # number of bytes written
end

function Base.string(xdoc::XMLDocument; encoding::AbstractString="utf-8")
    buf_out = Array(Xstr, 1)
    len_out = Array(Cint, 1)
    ccall((:xmlDocDumpFormatMemoryEnc,libxml2), Void, (Xptr, Ptr{Xstr}, Ptr{Cint}, Cstring, Cint),
        xdoc.ptr, buf_out, len_out, encoding, 1)
    _xcopystr(buf_out[1])
end

Base.show(io::IO, xdoc::XMLDocument) = println(io, string(xdoc))
