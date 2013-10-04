// libxml2 wrappers for accessing fields

#include <libxml/tree.h>

const xmlChar* getNodeName(xmlNode* n) { 
	return n->name; 
}

int getNodeType(xmlNode* n) { 
	return (int)(n->type); 
} 

const xmlDoc* getNodeDoc(xmlNode* n) { 
	return n->doc; 
}

const xmlNode* getNodeChildren(xmlNode* n) { 
	return n->children; 
}

const xmlNode* getNodeLast(xmlNode* n) { 
	return n->last; 
}

const xmlNode* getNodeParent(xmlNode* n) { 
	return n->parent; 
}

const xmlNode* getNodeNext(xmlNode* n) { 
	return n->next; 
}

const xmlNode* getNodePrev(xmlNode* n) { 
	return n->prev; 
}

const xmlAttr* getNodeAttrs(xmlNode* n) { 
	return n->properties; 
}

