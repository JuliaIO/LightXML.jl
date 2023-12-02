"""
An XML Schema Document, produced by an XML file or XMLDocument that is XML for the schema.
"""
mutable struct XMLSchema
    ptr::Xptr
    function XMLSchema(ctxt::Xptr)
        schema = ccall((:xmlSchemaParse, libxml2), Xptr, (Xptr,), ctxt)
        schema != C_NULL || throw(XMLValidationError("Bad XML Schema in Document"))
        ccall((:xmlSchemaFreeParserCtxt, libxml2), Cvoid, (Xptr,), ctxt)
        obj = new(schema)
        finalizer(x -> Libc.free(x.ptr), obj)
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
Use an existing XMLschema to validate
"""
function _schema_valid_ctxt(f::Function, schema::XMLSchema)
    ctxt = ccall((:xmlSchemaNewValidCtxt, libxml2), Xptr, (Xptr,), schema.ptr)
    err = try
        f(ctxt)
    finally
        Libc.free(ctxt)
    end
    return err
end

"""
Validate an XMLDocument with an XMLSchema
Returns true if valid
"""
function validate(xml::XMLDocument, schema::XMLSchema)
    err = _schema_valid_ctxt(schema) do ctxt
        ccall((:xmlSchemaValidateDoc, libxml2),
            Cint, (Xptr, Xptr), ctxt, xml.ptr)
    end
    return err == 0
end

"""
Validate an XML file or url with an XMLSchema
Returns true if valid
"""
function validate(url::String, schema::XMLSchema)
    err = _schema_valid_ctxt(schema) do ctxt
        ccall((:xmlSchemaValidateFile, libxml2),
            Cint, (Xptr, Cstring), ctxt, url)
    end
    return err == 0
end

"""
Validate an XMLElement of an XMLDocument with an XMLSchema
Returns true if valid
"""
function validate(elem::XMLElement, schema::XMLSchema)
    err = _schema_valid_ctxt(schema) do ctxt
        ccall((:xmlSchemaValidateOneElement, libxml2),
            Cint, (Xptr, Xptr), ctxt, elem.node.ptr)
    end
    return err == 0
end

"""
Validate an XML file or url with an XSD file or url
Returns true if valid
"""
function validate(url::String, schemafile::String)
    schema = XMLSchema(schemafile)
    return validate(url, schema)
end
