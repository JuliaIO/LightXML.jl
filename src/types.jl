# Basic types

abstract AbstractXMLNode

const xmlnode_common_size = ptrsize * 8 + sizeof(Cint)

immutable XMLNode <: AbstractXMLNode
	ptr::Ptr{Void}

	# extracted fields
	nodetype::Int
	name::ASCIIString
	ptr_children::Ptr{Void}
	ptr_last::Ptr{Void}
	ptr_parent::Ptr{Void}
	ptr_next::Ptr{Void}
	ptr_prev::Ptr{Void}
	ptr_doc::Ptr{Void}

	function XMLNode(ptr::Ptr{Void})
		@assert sizeof(Uint) == sizeof(Ptr{Void})

		p = ptr
		p += ptrsize  #skip private

		# get node type
		ty = _pxtr_int(p)
		p += sizeof(Cint)

		# get node name
		name = _pxtr_str(p)
		p += ptrsize

		new(ptr, int(ty), name, 
			nullptr, nullptr, nullptr, nullptr, nullptr, nullptr)
	end
end

immutable XMLDocument
	ptr::Ptr{Void}
	node::XMLNode

	# doc-specific fields
	compression::Int
	standalone::Int
	version::ASCIIString
	encoding::ASCIIString	

	function XMLDocument(ptr::Ptr{Void})
		nd = XMLNode(ptr)

		p = ptr + xmlnode_common_size
		compres = _pxtr_int(p)
		p += sizeof(Cint)
		standal = _pxtr_int(p)
		p += sizeof(Cint)

		# p += ptrsize * 3  # skip intSubset, extSubset, and oldNs
		# ver = _pxtr_str(p)
		# p += ptrsize
		# enc = _pxtr_str(p)
		# p += ptrsize
 
		new(ptr, nd, compres, standal, "", "")
	end
end

