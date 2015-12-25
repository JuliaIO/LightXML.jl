type XPathContext
    ptr::Xptr
    function XPathContext(doc::XMLDocument)
        ptr = ccall(
            (:xmlXPathNewContext, libxml2),
            Xptr,
            (Ptr{Void},),
            doc.ptr)
        if ptr == C_NULL
            error("failed to create an XPathContext")
        end
        return new(ptr)
    end
end

immutable _XMLNodeSet
    nodeNr::Cint
    nodeMax::Cint
    nodeTab::Ptr{Ptr{_XMLNodeStruct}}
end

immutable _XMLXPathObject
    _type::Cint  # is this OK?
    nodesetval::Ptr{_XMLNodeSet}
    boolval::Cint
    floatval::Cdouble
    stringval::Cstring
    user::Ptr{Void}
    index::Cint
    user2::Ptr{Void}
    index2::Cint
end

type XPathObject
    ptr::Ptr{_XMLXPathObject}
    function XPathObject(ptr::Ptr)
        return new(ptr)
    end
end

function Base.length(obj::XPathObject)
    return unsafe_load(unsafe_load(obj.ptr).nodesetval).nodeNr
end

function Base.endof(obj::XPathObject)
    return length(obj)
end

function Base.getindex(obj::XPathObject, i::Integer)
    struct = unsafe_load(unsafe_load(unsafe_load(obj.ptr).nodesetval).nodeTab, i)
    return XMLNode(reinterpret(Xptr, struct))
end

Base.start(obj::XPathObject)   = 1
Base.done(obj::XPathObject, i) = i > length(obj)
Base.next(obj::XPathObject, i) = obj[i], i + 1

function evalxpath(xpath::AbstractString, ctx::XPathContext)
    ptr = ccall(
        (:xmlXPathEvalExpression, libxml2),
        Ptr{_XMLXPathObject},
        (Cstring, Xptr),
        xpath, ctx.ptr)
    if ptr == C_NULL
        error("failed to evaluate the XPath expression")
    end
    return XPathObject(ptr)
end

function evalxpath(xpath::AbstractString, doc::XMLDocument)
    return evalxpath(xpath, XPathContext(doc))
end
