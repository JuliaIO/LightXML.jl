# C functions in the library

const libxml2 = dlopen("libxml2")

macro lx2func(fname)  # the macro to get functions from libxml2
	quote
		$(esc(fname)) = dlsym( libxml2, ($(string(fname))) )
	end
end

const nullptr = convert(Ptr{Void}, 0)
const nullsz = convert(Ptr{Cchar}, 0)

const ptrsize = sizeof(Ptr{Void})

@assert ptrsize == sizeof(Uint)

# XML Documents

@lx2func xmlParseFile
@lx2func xmlFreeDoc

# content extraction from pointer

_pxtr_int(p::Ptr{Void}) = int(unsafe_load(convert(Ptr{Cint}, p)))

function _pxtr_str(p::Ptr{Void})
	sz = unsafe_load(convert(Ptr{Ptr{Cchar}}, p))
	return (sz == nullsz ? "" : bytestring(sz))::ASCIIString
end

_pxtr_ptr(p::Ptr{Void}) = unsafe_load(convert(Ptr{Ptr{Void}}, p))
