
#### Document type

struct _XMLDocStruct  # use the same layout as C
    # common part
    _private::Ptr{Cvoid}
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

    ids::Ptr{Cvoid}
    refs::Ptr{Cvoid}
    url::Xstr
    charset::Cint
    dict::Xstr
    psvi::Ptr{Cvoid}
    parseflags::Cint
    properties::Cint
end

mutable struct XMLDocument
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

version(xdoc::XMLDocument) = unsafe_string(xdoc._struct.version)
encoding(xdoc::XMLDocument) = unsafe_string(xdoc._struct.encoding)
compression(xdoc::XMLDocument) = Int(xdoc._struct.compression)
standalone(xdoc::XMLDocument) = Int(xdoc._struct.standalone)

function root(xdoc::XMLDocument)
    pr = ccall((:xmlDocGetRootElement,libxml2), Xptr, (Xptr,), xdoc.ptr)
    pr != C_NULL || throw(XMLNoRootError())
    XMLElement(pr)
end


#### construction & free

function free(xdoc::XMLDocument)
    ccall((:xmlFreeDoc,libxml2), Cvoid, (Xptr,), xdoc.ptr)
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

function _check_result(p)
    p != C_NULL || throw(XMLParseError("Failure in parsing an XML file."))
    XMLDocument(p)
end

parse_file(filename::AbstractString) =
    _check_result(ccall((:xmlParseFile,libxml2), Xptr, (Cstring,), filename))

parse_file(filename::AbstractString, encoding, options::Integer) =
    _check_result(ccall((:xmlReadFile,libxml2), Xptr, (Cstring, Ptr{Cchar}, Cint),
        filename, encoding, options))

parse_string(s::AbstractString) =
    _check_result(ccall((:xmlParseMemory,libxml2), Xptr, (Xstr, Cint), s, sizeof(s) + 1))


#### output

function save_file(xdoc::XMLDocument, filename::AbstractString; encoding::AbstractString="utf-8")
    ret = ccall((:xmlSaveFormatFileEnc,libxml2), Cint,
                (Cstring, Xptr, Cstring, Cint),
                filename, xdoc.ptr, encoding, 1)
    ret < 0 && throw(XMLWriteError("Failed to save XML to file $filename"))
    Int(ret)  # number of bytes written
end

function Base.string(xdoc::XMLDocument; encoding::AbstractString="utf-8")
    buf_out = Vector{Xstr}(undef, 1)
    len_out = Vector{Cint}(undef, 1)
    ccall((:xmlDocDumpFormatMemoryEnc,libxml2), Cvoid,
          (Xptr, Ptr{Xstr}, Ptr{Cint}, Cstring, Cint),
          xdoc.ptr, buf_out, len_out, encoding, 1)
    _xcopystr(buf_out[1])
end

Base.show(io::IO, xdoc::XMLDocument) = print(io, string(xdoc))

function find_element(xdoc::XMLDocument, n::AbstractString)
    x = root(xdoc)
    find_element(x, n)
end

function get_elements_by_tagname(xdoc::XMLDocument, n::AbstractString)
    x = root(xdoc)
    get_elements_by_tagname(x, n)
end
