@testset "XML Validation with XSD" begin
  
    @test validate("valid.xml", "valid.xsd")
    @test validate("invalid.xml", "valid.xsd") == false

    doc = parse_file("valid.xml")
    schema = XMLSchema("valid.xsd")

    @test validate("valid.xml", schema)
    @test validate("invalid.xml", schema) == false

    @test validate(doc, schema)

    @test validate(root(doc), schema)

end
