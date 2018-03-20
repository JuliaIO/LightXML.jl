xdoc = XMLDocument()

xroot = create_root(xdoc, "States")

add_pi(xroot, "State", "Massachusetts")
add_pi(xroot, "State", "New Jersey")
add_pi(xroot, "State", "New York")

rtxt = """
<?xml version="1.0" encoding="utf-8"?>
<States>
  <?State Massachusetts?>
  <?State New Jersey?>
  <?State New York?>
</States>
"""

@test strip(string(xdoc)) == strip(rtxt)

free(xdoc)
