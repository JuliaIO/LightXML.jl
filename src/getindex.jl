# Indexable Collection support


function Base.getindex(x::XMLElement, tag::AbstractString)
    l = get_elements_by_tagname(x, tag)
    if isempty(l)
        return nothing
    end
    if isempty(child_elements(l[1]))
        l = [strip(content(i)) for i in l]
    end
    return length(l) == 1 ? l[1] : l
end

Base.getindex(x::XMLElement, name::Symbol) = attribute(x, string(name))

function Base.get(x::XMLElement, tag, default)
    r = getindex(x, tag)
    r != nothing ? r : default
end

Base.haskey(x::XMLElement, tag) = getindex(x, tag) != nothing


Base.getindex(x::XMLDocument, tag) = getindex(root(x), tag)
Base.haskey(x::XMLDocument, tag) = haskey(root(x), tag)
Base.get(x::XMLDocument, tag, default) = get(root(x), tag, default)
