type XPathContext
    ptr::Ptr{Void}
    function XPathContext(doc::XMLDocument)
        ctx = ccall(
            (:xmlXPathNewContext, libxml2),
            Ptr{Void},
            (Ptr{Void},),
            doc.ptr)
        if ctx == C_NULL
            error()
        end
        return new(ctx)
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
    function XPathObject(ptr)
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

function evalxpath(xpath, ctx::XPathContext)
    ptr = ccall(
        (:xmlXPathEvalExpression, libxml2),
        Ptr{Void},
        (Cstring, Ptr{Void}),
        xpath, ctx.ptr)
    if ptr == C_NULL
        error()
    end
    return XPathObject(ptr)
end

function evalxpath(xpath, doc::XMLDocument)
    return evalxpath(xpath, XPathContext(doc))
end
