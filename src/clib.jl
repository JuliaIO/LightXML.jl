# C functions in the library

const libxml2 = dlopen("libxml2", RTLD_GLOBAL)

macro lx2func(fname)  # the macro to get functions from libxml2
	quote
		$(esc(fname)) = dlsym( libxml2, ($(string(fname))) )
	end
end

const nullptr = convert(Ptr{Void}, 0)
const ptrsize = sizeof(Ptr{Void})

@assert ptrsize == sizeof(Uint)

# supporting functions

#
# After tests, it seems that free in libc instead of xmlFree 
# should be used here
#
@lx2func xmlFree
_xmlfree{T}(p::Ptr{T}) = ccall(:free, Void, (Ptr{T},), p)  

function _xcopystr(p::Ptr{Uint8}) 
	if p != nullptr
		r = bytestring(p)
		_xmlfree(p)
		return r
	else
		return ""
	end
end

# functions for nodes

@lx2func xmlNodeGetContent

# functions for documents

@lx2func xmlParseFile
@lx2func xmlFreeDoc
@lx2func xmlDocGetRootElement


