using LightXML

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

xdoc = parse_string(docstr)

println("Document:")
println("=====================")
show(xdoc)

# save_file(xdoc, "tt.xml")

println("Root Element:")
println("=====================")
xroot = root(xdoc)
show(xroot)

free(xdoc)

