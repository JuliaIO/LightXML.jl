using MiniXML

xdoc = XMLDocument()

xroot = create_root(xdoc, "States")

xs1 = new_child(xroot, "State")
add_text(xs1, "Massachusetts")
set_attribute(xs1, "tag", "MA")

xs2 = new_child(xroot, "State")
add_text(xs2, "Illinois")
set_attribute(xs2, "tag", "MA")

rtxt = """
<?xml version="1.0" encoding="utf-8"?>
<States>
  <State tag="MA">Massachusetts</State>
  <State tag="MA">Illinois</State>
</States>
"""

@assert strip(string(xdoc)) == strip(rtxt)

free(xdoc)
