using LightXML

xdoc = XMLDocument()

xroot = create_root(xdoc, "States")

xs1 = new_child(xroot, "State")
add_cdata(xdoc, xs1, "Massachussetts")

rtxt = """
<?xml version="1.0" encoding="utf-8"?>
<States>
  <State><![CDATA[Massachussetts]]></State>
</States>
"""

@assert strip(string(xdoc)) == strip(rtxt)

free(xdoc)
