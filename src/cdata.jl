function new_cdatanode(xdoc::XMLDocument, txt::ASCIIString)
        p = ccall((:xmlNewCDataBlock,libxml2), Xptr, (Xptr, Xstr, Cint), xdoc.ptr, txt, length(txt)+1)
        XMLNode(p)
end

add_cdata(xdoc::XMLDocument, x::XMLElement, txt::ASCIIString) = add_child(x, new_cdatanode(xdoc,txt))
