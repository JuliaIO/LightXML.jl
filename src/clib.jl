# C functions in the library

const libxml2 = dlopen("libxml2")

macro lx2func(fname)  # the macro to get functions from libxml2
	quote
		$(esc(fname)) = dlsym( libxml2, ($(string(fname))) )
	end
end

nullptr = convert(Ptr{Void}, 0)

# XML Documents

@lx2func xmlParseFile
@lx2func xmlFreeDoc

