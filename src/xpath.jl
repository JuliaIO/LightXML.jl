type XPathContext
    ptr::Xptr
    function XPathContext(doc::XMLDocument)
        ptr = ccall(
            (:xmlXPathNewContext, libxml2),
            Xptr,
            (Xptr,),
            doc.ptr)
        if ptr == C_NULL
            error("failed to create an XPathContext object")
        end
        ctx = new(ptr)
        finalizer(ctx, free)
        return ctx
    end
end

function free(ctx::XPathContext)
    ccall((:xmlXPathFreeContext, libxml2), Void, (Xptr,), ctx.ptr)
end

# register a namespace
function registerns!(ctx::XPathContext, prefix::AbstractString, uri::AbstractString)
    ret = ccall(
        (:xmlXPathRegisterNs, libxml2),
        Cint,
        (Xptr, Cstring, Cstring),
        ctx.ptr, prefix, uri)
    if ret != 0
        error("failed to register the namespace")
    end
    return
end

# C struct: _xmlNodeSet
immutable _xmlNodeSet
    # number of nodes in the set
    nodeNr::Cint
    # size of the array as allocated
    nodeMax::Cint
    # array of nodes in no particular order
    nodeTab::Ptr{Ptr{_XMLNodeStruct}}
end

# C enum: xmlXPathObjectType
const XPATH_UNDEFINED = 0
const XPATH_NODESET = 1
const XPATH_BOOLEAN = 2
const XPATH_NUMBER = 3
const XPATH_STRING = 4
const XPATH_POINT = 5
const XPATH_RANGE = 6
const XPATH_LOCATIONSET = 7
const XPATH_USERS = 8
const XPATH_XSLT_TREE = 9

# C struct: _xmlXPathObject
immutable _xmlXPathObject
    _type::Cint  # xmlXPathObjectType
    nodesetval::Ptr{_xmlNodeSet}
    boolval::Cint
    floatval::Cdouble
    stringval::Cstring
    user::Ptr{Void}
    index::Cint
    user2::Ptr{Void}
    index2::Cint
end

type XPathObject
    ptr::Ptr{_xmlXPathObject}
    function XPathObject(ptr::Ptr)
        xpath = new(ptr)
        finalizer(xpath, free)
        return xpath
    end
end

function free(xpath::XPathObject)
    ccall((:xmlXPathFreeObject, libxml2), Void, (Xptr,), xpath.ptr)
end

function nodesetval(xpath::XPathObject)
    return unsafe_load(unsafe_load(xpath.ptr).nodesetval)
end

function Base.length(xpath::XPathObject)
    return nodesetval(xpath).nodeNr
end

function Base.isempty(xpath::XPathObject)
    return length(xpath) == 0
end

function Base.endof(xpath::XPathObject)
    return length(xpath)
end

function Base.getindex(xpath::XPathObject, i::Integer)
    if !(1 ≤ i ≤ endof(xpath))
        throw(BoundsError(i))
    end
    @assert nodesetval(xpath).nodeTab != C_NULL
    struct = unsafe_load(nodesetval(xpath).nodeTab, i)
    return XMLNode(reinterpret(Xptr, struct))
end

Base.start(xpath::XPathObject)   = 1
Base.done(xpath::XPathObject, i) = i > endof(xpath)
Base.next(xpath::XPathObject, i) = xpath[i], i + 1

function evalxpath(xpath::AbstractString, ctx::XPathContext)
    ptr = ccall(
        (:xmlXPathEvalExpression, libxml2),
        Ptr{_xmlXPathObject},
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
