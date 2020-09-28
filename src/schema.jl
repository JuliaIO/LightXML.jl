"""
An XML Schema Document, produced by an XML file or XMLDocument that is XML for the schema.
"""
mutable struct XMLSchema
    ptr::Xptr
    function XMLSchema(ctxt::Xptr)
        schema = ccall((:xmlSchemaParse, libxml2), Xptr, (Xptr,), ctxt)
        schema != C_NULL || throw(XMLValidationError("Bad XML Schema in Document"))
        obj = new(schema)
        finalizer((x) -> Libc.free(x.ptr), obj)
    end
end

"""
Create an XMLSchema from a file or url
"""
function XMLSchema(url::String)
    ctxt = ccall((:xmlSchemaNewParserCtxt, libxml2), Xptr, (Cstring,), url)
    ctxt != C_NULL || throw(XMLValidationError("Bad XML Schema at " * url))
    return XMLSchema(ctxt)
end

"""
Create an XMLSchema from an XMLDocument
"""
function XMLSchema(doc::XMLDocument)
    ctxt = ccall((:xmlSchemaNewDocParserCtxt, libxml2), Xptr, (Xptr,), doc.ptr)
    ctxt != C_NULL || throw(XMLValidationError("Bad XML Schema in Document"))
    return XMLSchema(ctxt)
end

"""
Validate an XMLDocument with an XMLSchema
Returns true if valid
"""
function validate(xml::XMLDocument, schema::XMLSchema)
    ctxt = ccall((:xmlSchemaNewValidCtxt, libxml2), Xptr, (Xptr,), schema.ptr)
    err = ccall((:xmlSchemaValidateDoc, libxml2), 
        Cint, (Xptr, Xptr), ctxt, xml.ptr)
    Libc.free(ctxt)
    return err == 0 ? true : false
end

"""
Validate an XML file or url with an XMLSchema
Returns true if valid
"""
function validate(url::String, schema::XMLSchema)
    ctxt = ccall((:xmlSchemaNewValidCtxt, libxml2), Xptr, (Xptr,), schema.ptr)
    err = ccall((:xmlSchemaValidateFile, libxml2), 
        Cint, (Xptr, Cstring), ctxt, url)
    Libc.free(ctxt)
    return err == 0 ? true : false
end

"""
Validate an XMLElement of an XMLDocument with an XMLSchema
Returns true if valid
"""
function validate(elem::XMLElement, schema::XMLSchema)
    ctxt = ccall((:xmlSchemaNewValidCtxt, libxml2), Xptr, (Xptr,), schema.ptr)
    err = ccall((:xmlSchemaValidateOneElement, libxml2), 
        Cint, (Xptr, Xptr), ctxt, elem.node.ptr)
   Libc.free(ctxt)
   return err == 0 ? true : false
end

"""
Validate an XML file or url with an XSD file or url
Returns true if valid
"""
function validate(url::String, schemafile::String)
    ctxt = ccall((:xmlSchemaNewParserCtxt, libxml2), Xptr, (Cstring,), schemafile)
    ctxt != C_NULL || throw(XMLValidationError("Bad XML Schema at " * schemafile))
    schema = ccall((:xmlSchemaParse, libxml2), Xptr, (Xptr,), ctxt)
    schema != C_NULL || throw(XMLValidationError("Bad XML Schema at " * url))
    ccall((:xmlSchemaFreeParserCtxt, libxml2), Cvoid, (Xptr,), ctxt)
    ctxt = ccall((:xmlSchemaNewValidCtxt, libxml2), Xptr, (Xptr,), schema)
    err = ccall((:xmlSchemaValidateFile, libxml2), 
        Cint, (Ptr{LightXML.xmlBuffer}, Cstring), ctxt, url)
    Libc.free(ctxt)
    return err == 0 ? true : false
end
