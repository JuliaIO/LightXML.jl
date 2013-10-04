using MiniDOM

# document

xdoc = parsefile("ex1.xml")

@assert version(xdoc) == "1.0"
@assert encoding(xdoc) == "UTF-8"
@assert compression(xdoc) == 0
@assert standalone(xdoc) == -2


# root node

xroot = docelement(xdoc)

@assert isa(xroot, XMLElement)
@assert is_elementnode(xroot)
@assert name(xroot) == "bookstore"
@assert nodetype(xroot) == 1
@assert !has_attributes(xroot)
@assert has_children(xroot)

ras = collect(attributes(xroot))
@assert isempty(ras)


# children of root (text nodes and books)

rcs = collect(children(xroot))
@assert length(rcs) == 5  # text, book[1], text, book[1], text

@assert is_textnode(rcs[1])
@assert is_textnode(rcs[3])
@assert is_textnode(rcs[5])

@assert is_elementnode(rcs[2])
@assert is_elementnode(rcs[4])

xb1 = XMLElement(rcs[2])

@assert name(xb1) == "book"
@assert nodetype(xb1) == 1
@assert has_attributes(xb1)
@assert has_children(xb1)
@assert attribute(xb1, "category") == "COOKING"
@assert attribute(xb1, "tag") == "first"

b1as = collect(attributes(xb1))
@assert length(b1as) == 2

b1a1 = b1as[1]
@assert isa(b1a1, XMLAttr)
@assert name(b1a1) == "category"
@assert value(b1a1) == "COOKING"

b1a2 = b1as[2]
@assert isa(b1a2, XMLAttr)
@assert name(b1a2) == "tag"
@assert value(b1a2) == "first"

xb2 = XMLElement(rcs[4])

@assert name(xb2) == "book"
@assert nodetype(xb2) == 1
@assert has_attributes(xb2)
@assert has_children(xb2)
@assert attribute(xb2, "category") == "CHILDREN"


# child elements of book[1]

ces = collect(child_elements(xb1))

@assert length(ces) == 4
c1, c2, c3, c4 = ces[1], ces[2], ces[3], ces[4]

@assert isa(c1, XMLElement)
@assert name(c1) == "title"
@assert has_attributes(c1)
@assert attribute(c1, "lang") == "en"
@assert content(c1) == "Everyday Italian"

@assert has_children(c1)
c1cs = collect(children(c1))
@assert length(c1cs) == 1
c1c = c1cs[1]
@assert is_textnode(c1c)
@assert content(c1c) == "Everyday Italian"

@assert isa(c2, XMLElement)
@assert name(c2) == "author"
@assert !has_attributes(c2)
@assert content(c2) == "Giada De Laurentiis"

@assert isa(c3, XMLElement)
@assert name(c3) == "year"
@assert !has_attributes(c3)
@assert content(c3) == "2005"

@assert isa(c4, XMLElement)
@assert name(c4) == "price"
@assert !has_attributes(c4)
@assert content(c4) == "30.00"

free(xdoc)

