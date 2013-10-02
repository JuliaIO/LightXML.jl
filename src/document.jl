
function parsefile(filename::ASCIIString)
	p = ccall(xmlParseFile, Ptr{Void}, (Ptr{Cchar},), filename)
	XMLDocument(p)
end

function free(xdoc::XMLDocument)
	ccall(xmlFreeDoc, Void, (Ptr{Void},), xdoc.ptr)
	xdoc.ptr = nullptr
end

