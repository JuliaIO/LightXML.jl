using LightXML
using Base.Test

# document

docstr = """
<?xml version="1.0" encoding="UTF-8"?>
<bookstore>
  <book category="COOKING" tag="first">
    <title lang="en">Everyday Italian</title>
    <author>Giada De Laurentiis</author>
    <year>2005</year>
    <price>30.00</price>
  </book>
  <book category="CHILDREN">
    <title lang="en">Harry Potter</title>
    <author>J K. Rowling</author>
    <year>2005</year>
    <price>29.99</price>
  </book>
</bookstore>
"""

for xdoc = (parse_string(docstr),
            parse_file(joinpath(dirname(@__FILE__), "ex1.xml")),
            parse_file(joinpath(dirname(@__FILE__), "ex1.xml"), C_NULL, 64), # 64 == XML_PARSE_NOWARNING
            parse_file(joinpath(dirname(@__FILE__), "ex1.xml"), "UTF-8", 64))

@test version(xdoc) == "1.0"
@test encoding(xdoc) == "UTF-8"
@test standalone(xdoc) == -2


# root node

xroot = root(xdoc)

@test isa(xroot, XMLElement)
@test is_elementnode(xroot)
@test name(xroot) == "bookstore"
@test nodetype(xroot) == 1
@test !has_attributes(xroot)
@test has_children(xroot)

ras = collect(attributes(xroot))
@test isempty(ras)


# children of root (text nodes and books)

rcs = collect(child_nodes(xroot))
@test length(rcs) == 5  # text, book[1], text, book[1], text

@test is_textnode(rcs[1])
@test is_textnode(rcs[3])
@test is_textnode(rcs[5])

@test is_blanknode(rcs[1])
@test is_blanknode(rcs[3])
@test is_blanknode(rcs[5])

@test is_elementnode(rcs[2])
@test is_elementnode(rcs[4])

@test !is_blanknode(rcs[2])
@test !is_blanknode(rcs[4])

xb1 = XMLElement(rcs[2])

@test name(xb1) == "book"
@test nodetype(xb1) == 1
@test has_attributes(xb1)
@test has_children(xb1)
@test attribute(xb1, "category") == "COOKING"
@test attribute(xb1, "tag") == "first"

b1as = collect(attributes(xb1))
@test length(b1as) == 2

b1a1 = b1as[1]
@test isa(b1a1, XMLAttr)
@test name(b1a1) == "category"
@test value(b1a1) == "COOKING"

b1a2 = b1as[2]
@test isa(b1a2, XMLAttr)
@test name(b1a2) == "tag"
@test value(b1a2) == "first"

adct = attributes_dict(xb1)
@test length(adct) == 2
@test adct["category"] == "COOKING"
@test adct["tag"] == "first"

xb2 = XMLElement(rcs[4])

@test name(xb2) == "book"
@test nodetype(xb2) == 1
@test has_attributes(xb2)
@test has_children(xb2)
@test has_attribute(xb2, "category")
@test attribute(xb2, "category") == "CHILDREN"

@test !has_attribute(xb2, "wrongattr")
@test is(attribute(xb2, "wrongattr"), nothing)
@test_throws LightXML.XMLAttributeNotFound attribute(xb2, "wrongattr"; required=true)

rces = get_elements_by_tagname(xroot, "book")
@test length(rces) == 2
@test isa(rces, Vector{XMLElement})
@test attribute(rces[1], "category") == "COOKING"
@test attribute(rces[2], "category") == "CHILDREN"

# child elements of book[1]

ces = collect(child_elements(xb1))

@test length(ces) == 4
c1, c2, c3, c4 = ces[1], ces[2], ces[3], ces[4]

@test isa(c1, XMLElement)
@test name(c1) == "title"
@test has_attributes(c1)
@test attribute(c1, "lang") == "en"
@test content(c1) == "Everyday Italian"

@test has_children(c1)
c1cs = collect(child_nodes(c1))
@test length(c1cs) == 1
c1c = c1cs[1]
@test is_textnode(c1c)
@test content(c1c) == "Everyday Italian"

@test isa(c2, XMLElement)
@test name(c2) == "author"
@test !has_attributes(c2)
@test content(c2) == "Giada De Laurentiis"

@test isa(c3, XMLElement)
@test name(c3) == "year"
@test !has_attributes(c3)
@test content(c3) == "2005"

@test isa(c4, XMLElement)
@test name(c4) == "price"
@test !has_attributes(c4)
@test content(c4) == "30.00"

cy = find_element(xb1, "year")
@test isa(cy, XMLElement)
@test name(cy) == "year"
@test content(cy) == "2005"

cz = find_element(xb1, "abc")
@test is(cz, nothing)

free(xdoc)
end
