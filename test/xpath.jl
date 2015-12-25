using LightXML
using Base.Test

xdoc = parse_string("""
<?xml version="1.0" encoding="utf-8"?>
<wikimedia>
  <projects>
    <project name="Wikipedia" launch="2001-01-05">
      <editions>
        <edition language="English">en.wikipedia.org</edition>
        <edition language="German">de.wikipedia.org</edition>
        <edition language="French">fr.wikipedia.org</edition>
        <edition language="Polish">pl.wikipedia.org</edition>
        <edition language="Spanish">es.wikipedia.org</edition>
      </editions>
    </project>
    <project name="Wiktionary" launch="2002-12-12">
      <editions>
        <edition language="English">en.wiktionary.org</edition>
        <edition language="French">fr.wiktionary.org</edition>
        <edition language="Vietnamese">vi.wiktionary.org</edition>
        <edition language="Turkish">tr.wiktionary.org</edition>
        <edition language="Spanish">es.wiktionary.org</edition>
      </editions>
    </project>
  </projects>
</wikimedia>
""")

xpath = "/"
res = evalxpath(xpath, xdoc)
@test isa(res, LightXML.XPathObject)
@test length(res) == 1

xpath = "/wikimedia"
res = evalxpath(xpath, xdoc)
@test length(res) == 1
@test isa(res[1], XMLNode)
@test name(res[1]) == "wikimedia"

for xpath in ["/wikimedia/projects/project", "//project"]
    res = evalxpath(xpath, xdoc)
    @test length(res) == 2
    @test isa(res[1], XMLNode)
    @test isa(res[2], XMLNode)
    @test name(res[1]) == "project"
    @test name(res[2]) == "project"
end

for xpath in ["/wikimedia/projects/project/@name", "//projects//@name"]
    res = evalxpath(xpath, xdoc)
    @test length(res) == 2
    @test nodetype(res[1]) == LightXML.XML_ATTRIBUTE_NODE
    @test nodetype(res[2]) == LightXML.XML_ATTRIBUTE_NODE
    @test name(res[1]) == "name"
    @test name(res[2]) == "name"
    @test content(res[1]) == "Wikipedia"
    @test content(res[2]) == "Wiktionary"
end

xpath = """/wikimedia/projects/project/editions/edition[@language="English"]/text()"""
res = evalxpath(xpath, xdoc)
@test length(res) == 2
@test is_textnode(res[1])
@test is_textnode(res[2])
@test name(res[1]) == "text"
@test name(res[2]) == "text"
@test content(res[1]) == "en.wikipedia.org"
@test content(res[2]) == "en.wiktionary.org"
