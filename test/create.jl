using MiniXML

xdoc = XMLDocument()

xroot = create_root(xdoc, "States")

xs1 = new_child(xroot, "State")
add_text(xs1, "Massachusetts")
set_attribute(xs1, "tag", "MA")

xs2 = new_child(xroot, "State")
add_text(xs2, "Illinois")
set_attribute(xs2, "tag", "MA")

show(xdoc)
