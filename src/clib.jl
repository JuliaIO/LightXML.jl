# C functions in the library

@unix_only libxml2 = dlopen("libxml2", RTLD_GLOBAL)
@windows_only libxml2 = dlopen(joinpath(Pkg.dir("LightXML"),"deps","usr","lib","libxml2"))

macro lx2func(fname)  # the macro to get functions from libxml2
	quote
		$(esc(fname)) = dlsym( libxml2, ($(string(fname))) )
	end
end

const nullptr = convert(Ptr{Void}, 0)
const ptrsize = sizeof(Ptr{Void})

@assert ptrsize == sizeof(Uint)

typealias Xchar Uint8
typealias Xstr Ptr{Xchar}
typealias Xptr Ptr{Void}

# supporting functions

#
# After tests, it seems that free in libc instead of xmlFree 
# should be used here
#
@lx2func xmlFree
_xmlfree{T}(p::Ptr{T}) = ccall(:free, Void, (Ptr{T},), p)  

# pre-condition: p is not null
_xcopystr(p::Xstr) = (r = bytestring(p); _xmlfree(p); r)

# buffer

@lx2func xmlBufferCreateSize
@lx2func xmlBufferFree
@lx2func xmlBufferLength
@lx2func xmlBufferContent

# functions for nodes

@lx2func xmlNodeGetContent
@lx2func xmlHasProp
@lx2func xmlGetProp
@lx2func xmlFirstElementChild
@lx2func xmlNextElementSibling
@lx2func xmlNodeDump
@lx2func xmlIsBlankNode

@lx2func xmlNewNode
@lx2func xmlAddChild
@lx2func xmlNewText
@lx2func xmlNewCDataBlock
@lx2func xmlSetProp

# functions for documents

@lx2func xmlDocGetRootElement
@lx2func xmlDocSetRootElement
@lx2func xmlNewDoc
@lx2func xmlFreeDoc
@lx2func xmlParseFile
@lx2func xmlParseMemory
@lx2func xmlDocDumpMemoryEnc
@lx2func xmlDocDumpFormatMemoryEnc
@lx2func xmlSaveFileEnc
@lx2func xmlSaveFormatFileEnc

