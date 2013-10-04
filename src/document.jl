
function parsefile(filename::ASCIIString)
	p = ccall(xmlParseFile, Ptr{Void}, (Ptr{Cchar},), filename)
	p != nullptr || throw(XMLParseError("Failure in parsing an XML file."))
	XMLDocument(p)
end

function free(xdoc::XMLDocument)
	ccall(xmlFreeDoc, Void, (Ptr{Void},), xdoc.ptr)
end

