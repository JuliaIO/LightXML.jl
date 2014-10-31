# Utilities

##### Buffer

immutable XBuffer
    ptr::Xptr

    function XBuffer(bytes::Integer)
        p = ccall(xmlBufferCreateSize, Xptr, (Csize_t,), bytes)
        p != nullptr || error("Failed to create buffer of $bytes bytes.")
        new(p)
    end
end

free(buf::XBuffer) = ccall(xmlBufferFree, Void, (Xptr,), buf.ptr)

Base.length(buf::XBuffer) = int(ccall(xmlBufferLength, Cint, (Xptr,), buf.ptr))

content(buf::XBuffer) = bytestring(ccall(xmlBufferContent, Xstr, (Xptr,), buf.ptr))
