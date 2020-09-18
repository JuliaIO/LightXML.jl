"""
An XML Schema Document, produced by an XML document that is XML for the schema.
"""
mutable struct XMLSchema
    ptr::Xptr
    isvalid::Bool
end

"""
Create an XMLSchema from a C library schema context pointer
"""
function XMLSchema(context::Xptr)
    schema = ccall((:xmlSchemaParse, libxml2), Xptr, (Xptr,), context)
    schema != C_NULL || throw(XMLValidationError("Bad XML Schema in Document"))
    return XMLSchema(schema, true)
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
    NB:  There might be a memory leak from the ctxt pointer here, but calling the libxml2 free context function 
         to free ctxt causes a segfault in the library, so hopefully this is freed elsewhere by the C library
"""
function validate(xml::XMLDocument, schema::XMLSchema)
    ctxt = ccall((:xmlSchemaNewValidCtxt, libxml2), Xptr, (Xptr,), schema.ptr)
    err = ccall((:xmlSchemaValidateDoc, libxml2), 
        Cint, (Xptr, Xptr), ctxt, xml.ptr)
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
    return err == 0 ? true : false
end