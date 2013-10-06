using LightXML

xdoc = XMLDocument()

xroot = create_root(xdoc, "States")

xs1 = new_child(xroot, "State")
add_text(xs1, "Massachusetts")
set_attribute(xs1, "tag", "MA")

xs2 = new_child(xroot, "State")
add_text(xs2, "Illinois")
set_attributes(xs2, {"tag"=>"IL", "cap"=>"Springfield"})

xs3 = new_child(xroot, "State")
add_text(xs3, "California")
set_attributes(xs3; tag="CA", cap="Sacramento")

rtxt = """
<?xml version="1.0" encoding="utf-8"?>
<States>
  <State tag="MA">Massachusetts</State>
  <State tag="IL" cap="Springfield">Illinois</State>
  <State tag="CA" cap="Sacramento">California</State>
</States>
"""

@assert strip(string(xdoc)) == strip(rtxt)

free(xdoc)
