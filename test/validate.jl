@test validate("valid.xml", "valid.xsd") == true

@test validate("valid.xml", "valid.xsd") == true

doc = parse_file("valid.xml")
schema = XMLSchema("valid.xsd")

@test validate("valid.xml", schema) == true

@test validate(doc, schema) == true

@test validate(root(doc), schema) == true

