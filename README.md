## LightXML.jl

[![Build Status](https://travis-ci.org/JuliaIO/LightXML.jl.svg?branch=master)](https://travis-ci.org/JuliaIO/LightXML.jl)
[![Build status](https://ci.appveyor.com/api/projects/status/14l097yi92frqkqm/branch/master?svg=true)](https://ci.appveyor.com/project/tkelman/lightxml-jl/branch/master)
[![LightXML](http://pkg.julialang.org/badges/LightXML_0.6.svg)](http://pkg.julialang.org/?pkg=LightXML&ver=0.6)

This package is a light-weight Julia wrapper of [libxml2](http://www.xmlsoft.org), which provides a minimal interface that covers functionalities that are commonly needed:

* Parse a XML file or string into a tree
* Access XML tree structure
* Create an XML tree
* Export an XML tree to a string or an XML file

### Setup

Like other Julia packages, you may checkout *LightXML* from the General registry, as

```julia
Pkg.add("LightXML")
```

**Note:** This package relies on the library *libxml2* to work, which is shipped with Mac OS X and many Linux systems. So this package may work out of the box. If not, you may check whether *libxml2* has been in your system and whether *libxml2.so* (for Linux) or *libxml2.dylib* (for Mac) is on your library search path.


### Examples

The following examples show how you may use this package to accomplish common tasks.

#### Read an XML file

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
using LightXML

# parse ex1.xml:
# xdoc is an instance of XMLDocument, which maintains a tree structure
xdoc = parse_file("ex1.xml")

# get the root element
xroot = root(xdoc)  # an instance of XMLElement
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

#=
If the remainder of the script does not use the document or any of its children,
you can call free here to deallocate the memory. The memory will only get
deallocated by calling free or by exiting julia -- i.e., the memory allocated by
libxml2 will not get freed when the julia variable wrapping it goes out of
scope.
=#
free(xdoc)
```

There are actually five child nodes under ``<bookstore>``: the 1st, 3rd, 5th children are text nodes (any space between node elements are captured by text nodes), while the 2nd and 4th nodes are element nodes corresponding to the ``<book>`` elements.

One may use the function ``nodetype`` to determine the type of a node, which returns an integer following the table [here](https://www.w3schools.com/jsref/prop_node_nodetype.asp). In particular, 1 indicates element node and 3 indicates text node.

If you only care about child elements, you may use ``child_elements`` instead of ``child_nodes``.

```julia
ces = collect(child_elements(xroot))  # get a list of all child elements
@assert length(ces) == 2

# if you know the child element tagname, you can instead get a list as
ces = get_elements_by_tagname(xroot, "book")
# or shorthand:
ces = xroot["book"]

e1 = ces[1]  # the first book element

# print the value of an attribute
println(attribute(e1, "category"))

# find the first title element under e1
t = find_element(e1, "title")

# retrieve the value of lang attribute of t
a = attribute(t, "lang")  # a <- "en"

# retrieve the text content of t
r = content(t)  # r <- "Everyday Italian"
```

One can also traverse all attributes of an element (``e1``) as

```julia
for a in attributes(e1)  # a is an instance of XMLAttr
    n = name(a)
    v = value(a)
    println("$n = $v")
end
```

Another way to access attributes is to turn them into a dictionary using ``attributes_dict``, as

```julia
ad = attributes_dict(e1)
v = ad["category"]  # v <-- "COOKING"
```

**Note:** The functions ``child_nodes``, ``child_elements``, and ``attributes`` return light weight iterators -- so that one can use them with for-loop. To get an array of all items, one may use the ``collect`` function provided by Julia.


#### Create an XML Document

This package allows you to construct an XML document programmatically. For example, to create an XML document as

```xml
<?xml version="1.0" encoding="utf-8"?>
<States>
  <State tag="MA">Massachusetts</State>
  <State tag="IL" cap="Springfield">Illinois</State>
  <State tag="CA" cap="Sacramento">California</State>
</States>
```

You may write:

```julia
# create an empty XML document
xdoc = XMLDocument()

# create & attach a root node
xroot = create_root(xdoc, "States")

# create the first child
xs1 = new_child(xroot, "State")

# add the inner content
add_text(xs1, "Massachusetts")

# set attribute
set_attribute(xs1, "tag", "MA")

# likewise for the second child
xs2 = new_child(xroot, "State")
add_text(xs2, "Illinois")
# set multiple attributes using a dict
set_attributes(xs2, Dict("tag"=>"IL", "cap"=>"Springfield"))

# now, the third child
xs3 = new_child(xroot, "State")
add_text(xs3, "California")
# set attributes using keyword arguments
set_attributes(xs3; tag="CA", cap="Sacramento")
```

**Note:** When you create XML documents and elements directly you need to take care not to leak memory; memory management in the underlying libxml2 library is complex and LightXML currently does not integrate well with Julia's garbage collection system. You can call ``free`` on an XMLDocument, XMLNode or XMLElement but you must take care not to reference any child elements after they have been manually freed.

#### Export an XML file

With this package, you can easily export an XML file to a string or a file, or show it on the console, as

```julia
# save to an XML file
save_file(xdoc, "f1.xml")

# output to a string
s = string(xdoc)

# print to the console (in a pretty format as in an XML file)
print(xdoc)
```

**Note:** the ``string`` and ``show`` functions are specialized for both ``XMLDocument`` and ``XMLElement``.


### Types

Main types of this package

* ``XMLDocument``: represent an XML document (in a tree)
* ``XMLElement``: represent an XML element (``child_elements`` give you this)
* ``XMLNode``: represent a generic XML node (``child_nodes`` give you this)
* ``XMLAttr``: represent an XML attribute

**Note:** If an ``XMLNode`` instance ``x`` is actually an element node, one may construct an ``XMLElement`` instance by ``XMLElement(x)``.


### API Functions

A list of API functions:


##### Functions to access an XML tree

```julia
# Let xdoc be a document, x be a node/element, e be an element

root(xdoc)   # get the root element of a document

nodetype(x)  # get an integer indicating the node type
name(x)      # get the name of a node/element
content(x)   # get text content of a node/element
             # if x is an element, this returns all text (concatenated) within x

is_elementnode(x)       # whether x is an element node
is_textnode(x)          # whether x is a text node
is_cdatanode(x)         # whether x is a CDATA node
is_commentnode(x)       # whether x is a comment node

has_children(e)         # whether e has child nodes
has_attributes(e)       # whether e has attributes

child_nodes(x)          # iterator of all child nodes of a node/element x
child_elements(e)       # iterator of all child elements of e
attributes(e)           # iterator of all attributes of e

attributes_dict(e)      # a dictionary of all attributes of e,
                        # which maps names to corresponding values

has_attribute(e, name)  # whether a named attribute exists for e

# get the value of a named attribute
# when the attribute does not exist, it either
# throws an exception (when required is true)
# or returns nothing (when required is false)
attribute(e, name; required=false)

find_element(e, name)   # the first element of specified name under e
                        # return nothing is no such an element is found

get_elements_by_tagname(e, name)  # a list of all child elements of e with
                                  # the specified name. Equivalent to e[name]

string(e)               # format an XML element into a string
show(io, e)             # output formatted XML element

unlink(x)               # remove a node or element from its current context
                        # (unlink does not free the memory for the node/element)
free(xdoc)              # release memory for a document and all its children
free(x)                 # release memory for a node/element and all its children
```

##### Functions to create an XML document

```julia
xdoc = XMLDocument()           # create an empty XML document

e = new_element(name)          # create a new XML element
                               # this does not attach e to a tree

t = new_textnode(content)      # create a new text node
                               # this does not attach t to a tree

set_root(xdoc, e)              # set element e as the root of xdoc
add_child(parent, x)           # add x as a child of a parent element

e = create_root(xdoc, name)    # create a root element and set it as root
                               # equiv. to new_element + set_root

e = new_child(parent, name)    # create a new element and add it as a child
                               # equiv. to new_element + add_child

add_text(e, text)              # add text content to an element
                               # equiv. to new_textnode + add_child

set_content(e, text)           # replace text content of an element

add_cdata(xdoc, e, text)       # add cdata content to an element
                               # equiv. to new_cdatanode + add_child

set_attribute(e, name, value)  # set an attribute of an element
                               # this returns the added attribute
                               # as an instance of XMLAttr

set_attributes(e, attrs)       # set multiple attributes in one call
                               # attrs can be a dictionary or
                               # a list of pairs as (name, value)

# one can also use keyword arguments to set attributes to an element
set_attributes(e, key1="val1", key2="val2", ...)
```

##### Functions to work with a document

```julia
xdoc = parse_file(filename)  # parse an XML file
xdoc = parse_file(filename,  # parse an XML file with a specified encoding and parser options,
         encoding, options)  # see http://xmlsoft.org/html/libxml-parser.html#xmlReadFile
                             # and http://xmlsoft.org/html/libxml-parser.html#xmlParserOption
xdoc = parse_string(str)     # parse an XML doc from a string
save_file(xdoc, filename)    # save xdoc to an XML file

string(xdoc)                 # formatted XML doc to a string
show(io, xdoc)               # output formatted XML document
```

##### Functions to validate a document

```julia
xsd = XMLSchema(url)                 # parse an XSD schema file or URL

isvalid = validate(xmlfile, schema)  # validate an XML file against a previously loaded XSD schema 
isvalid = validate(doc, schema)      # validate a LightXML XML Document against a previously loaded XSD schema 
isvalid = validate(url, schema)      # validate a URI or file against an XSD Schema document
isvalid = validate(element, schema)  # validate a LightXML XML Node (a subtree) against an XSD Schema document
isvalid = validate(xmlfile, schemafile)  # validate an XML file or URL against a XSD schem file or URL
```


