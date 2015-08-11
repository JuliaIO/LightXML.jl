# Utilities

##### Buffer

immutable XBuffer
    ptr::Xptr

    function XBuffer(bytes::Integer)
        p = ccall((:xmlBufferCreateSize,libxml2), Xptr, (Csize_t,), bytes)
        p != C_NULL || error("Failed to create buffer of $bytes bytes.")
        new(p)
    end
end

free(buf::XBuffer) = ccall((:xmlBufferFree,libxml2), Void, (Xptr,), buf.ptr)

Base.length(buf::XBuffer) = int(ccall((:xmlBufferLength,libxml2), Cint, (Xptr,), buf.ptr))

content(buf::XBuffer) = bytestring(ccall((:xmlBufferContent,libxml2), Xstr, (Xptr,), buf.ptr))
