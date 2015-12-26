type XPathContext
    ptr::Xptr
    function XPathContext(doc::XMLDocument)
        ptr = ccall(
            (:xmlXPathNewContext, libxml2),
            Xptr,
            (Xptr,),
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

# enum xmlXPathObjectType
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

immutable _XMLXPathObject
    _type::Cint  # xmlXPathObjectType
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

function nodesetval(obj::XPathObject)
    return unsafe_load(unsafe_load(obj.ptr).nodesetval)
end

function Base.length(obj::XPathObject)
    return nodesetval(obj).nodeNr
end

function Base.isempty(obj::XPathObject)
    return length(obj) == 0
end

function Base.endof(obj::XPathObject)
    return length(obj)
end

function Base.getindex(obj::XPathObject, i::Integer)
    struct = unsafe_load(nodesetval(obj).nodeTab, i)
    return XMLNode(reinterpret(Xptr, struct))
end

Base.start(obj::XPathObject)   = 1
Base.done(obj::XPathObject, i) = i > endof(obj)
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
