## LightXML.jl

This package is a light-weight Julia wrapper of [Libxml2](http://www.xmlsoft.org), which provides a minimal interface that covers functionalities that are commonly needed:

* Parse a XML file or string into a tree
* Access XML tree structure
* Create an XML tree 
* Export an XML tree to a string or an XML file

### Setup

Like other Julia packages, you may checkout *LightXML* from METADATA repo, as

```julia
Pkg.add("LightXML")
```

**Node:** This package relies on the library *libxml2* to work, which is shipped with Mac OS X and many Linux systems. So this package may work out of the box. If not, you may check whether *libxml2* has been in your system and whether *libxml2.so* (for Linux) or *libxml2.dylib* (for Mac) is on your library search path.

### Examples

The following examples show how you may use this package to accomplish common tasks.

##### Read an XML file

Suppose you have an XML file ``ex1.xml`` as below

```xml
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
```

Here is the code to parse this file:

```julia
using MiniXML

# parse ex1.xml:
# xdoc is an instance of XMLDocument, which maintains a tree structure  
xdoc = parse_file("ex1.xml")

# get the root element
xroot = root(xdoc)   # an instance of XMLElement
# print its name
println(name(xroot))  # this should print: bookstore

# traverse all its child nodes and print element names
for c in child_nodes(xroot)  # c is an instance of XMLNode
    println(nodetype(c))
    if is_elementnode(c)
        e = XMLElement(c)  # this makes an XMLElement instance
        println(name(e))
    end
end
```

There are actually five child nodes under ``<bookstore>``: the 1st, 3rd, 5th children are text nodes (any space between node elements are captured by text nodes), while the 2nd and 4th nodes are element nodes corresponding to the ``<book>`` elements. 

One may use the function ``nodetype`` to determine the type of a node, which returns an integer following the table [here](http://www.w3schools.com/dom/dom_nodetype.asp). In particular, 1 indicates element node and 3 indicates text node.

If you only care about child elements, you may use ``child_elements`` instead of ``child_nodes``. 

```julia
ces = collect(child_elements(xroot))  # get a list of all child elements
@assert length(ces) == 2 

# if you know the child element tagname, you can instead get a list as
ces = get_elements_by_tagname(xroot, "book")

e1 = ces[1]  # the first book element

# print the value of an attribute
println(attribute(e1, "category"))

# find the first title element under e1
t = find_element(e1, "title")

# retrieve the value of lang attribute of t
a = attribute(t, "lang")   # a <- "en"

# retrieve the text content of t
r = content(t)  # r <- "Everyday Italian"
```

One can also traverse all attributes of an element ``e`` as

```julia
for a in attributes(e)  # a is an instance of 
	n = name(a)
	v = value(a)
	println("$n = $v")
end
```

**Node:** The functions ``child_nodes``, ``child_elements``, and ``attributes`` return light weight iterators -- so that one can use them with for-loop. To get an array of all items, one may use the ``collect`` function provided by Julia.

