# Indexable Collection support

export xml_dict, dict_xml

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




if Pkg.installed("DataStructures") != nothing
    eval(Expr(:using,:DataStructures))
    const default_dict_type = OrderedDict
else
    const default_dict_type = Dict
end

# Convert XMLDocument to OrderedDict...

function xml_dict(x::AbstractString, dict_type::Type=default_dict_type; options...)
    xml_dict(parse_string(x), dict_type; options...)
end

function xml_dict(x::XMLDocument, dict_type::Type=default_dict_type; options...)
    r = dict_type()
    r[:version] = version(x)
    if encoding(x) != nothing
        r[:encoding] = encoding(x)
    end
    r[name(root(x))] = xml_dict(root(x), dict_type; options...)
    r
end


is_text(x::XMLNode) = is_textnode(x) || is_cdatanode(x)
Base.isempty(x::XMLNode) = isspace(content(x))
has_text(x::XMLNode) = is_text(x) && !isempty(x)


function xml_dict(x::XMLElement, dict_type::Type; strip_text=false)

    # Copy element attributes into dict...
    r = dict_type()
    for a in attributes(x)
        r[symbol(name(a))] = value(a)
    end

    # Check for non-empty text nodes under this element...
    element_has_text = any(has_text, child_nodes(x))
    if element_has_text
        r[:text] = Any[]
    end

    for c in child_nodes(x)

        if is_elementnode(c)

            # Get name and sub-dict for sub-element...
            c = XMLElement(c)
            n = name(c)
            v = xml_dict(c,dict_type;strip_text=strip_text)

            if haskey(r, :text)

                # If this is a text element, embed sub-dict in text vector...
                # "The <b>bold</b> tag" == ["The", Dict("b" => "bold"), "tag"]
                push!(r[:text], dict_type(n => v))

            elseif haskey(r, n)

                # Collect sub-elements with same tag into a vector...
                # "<item>foo</item><item>bar</item>" == "item" => ["foo", "bar"]
                a = isa(r[n], Array) ? r[n] : [r[n]]
                push!(a, v)
                r[n] = a
            else
                r[n] = v
            end

        elseif is_text(c) && haskey(r, :text)
            push!(r[:text], content(c))
        end
    end

    # Collapse text-only elements...
    if haskey(r, :text)
        if length(r[:text]) == 1
            r[:text] = r[:text][1]
            if strip_text
                r[:text] = strip(r[:text])
            end
        end
        if length(r) == 1
            r = r[:text]
        end
    end

    return r
end


# Convert Dict to XMLDocument.
# dict_xml(xml_dict(xml_string)) == xml_string

function dict_xml(root::Associative)
    xml = "<?xml"
    for (n,v) in root
        if isa(n, Symbol)
            xml *= " $n=\"$v\""
        end
    end
    xml *= "?>\n"
    xml *=_dict_xml(root)
end


function _dict_xml(node::Associative)

    xml = ""

    for (n,v) in node

        # Ignore attributes of parent element...
        if isa(n, Symbol) && n != :text
            continue
        end
        # Expand homogeneous array of elements...
        if (typeof(v) <: AbstractArray
        &&  all(i -> typeof(i) == typeof(v[1]), v))
            for i in v
                xml *= _dict_xml(Dict(n=>i))
            end
            continue
        end

        # Emmit <tag attrs...> for non text nodes...
        if n != :text
            xml *= "<$n"
            if typeof(v) <: Associative
                for (an,av) in v
                    if isa(an, Symbol) && an != :text
                        xml *= " $an=\"$av\""
                    end
                end
            end
            xml *= ">"
        end

        if typeof(v) <: Associative  

            # Recursive call for sub-dict...
            xml *= _dict_xml(v)

        elseif typeof(v) <: AbstractArray

            # Expand heterogeneous array...
            for i in v
                if typeof(i) <: AbstractString
                    xml *= i
                else
                    xml *= _dict_xml(i)
                end
            end
        else

            # Just plain text...
            xml *= escape(v)
        end

        # Close </tag>...
        if n != :text
            xml *= "</$n>"
        end
    end

    xml
end
