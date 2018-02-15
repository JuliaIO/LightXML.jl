function new_cdatanode(xdoc::XMLDocument, txt::AbstractString)
    p = ccall((:xmlNewCDataBlock,libxml2), Xptr,
              (Xptr, Xstr, Cint),
              xdoc.ptr, txt, length(txt) + 1)
    XMLNode(p)
end

add_cdata(xdoc::XMLDocument, x::XMLElement, txt::AbstractString) =
    add_child(x, new_cdatanode(xdoc, txt))
