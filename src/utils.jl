# Utilities

##### Buffer

struct XBuffer
    ptr::Xptr

    function XBuffer(bytes::Integer)
        p = ccall((:xmlBufferCreateSize,libxml2), Xptr, (Csize_t,), bytes)
        p != C_NULL || error("Failed to create buffer of $bytes bytes.")
        new(p)
    end
end

free(buf::XBuffer) = ccall((:xmlBufferFree,libxml2), Cvoid, (Xptr,), buf.ptr)

length(buf::XBuffer) = int(ccall((:xmlBufferLength,libxml2), Cint, (Xptr,), buf.ptr))

content(buf::XBuffer) = unsafe_string(ccall((:xmlBufferContent,libxml2), Xstr, (Xptr,), buf.ptr))
