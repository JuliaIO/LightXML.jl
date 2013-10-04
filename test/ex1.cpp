/**********************************************************
 *
 *  ex1.cpp
 * 
 *  a C++ example of parsing ex1.xml
 *
 **********************************************************/

#include <cstdio>
#include <string>
#include <assert.h>
#include <libxml/tree.h>

using std::printf;

inline const char* safe_str(const char *s)
{
    return s == 0 ? "(NULL)" : s;
}


inline void print_indent(int level)
{
    std::string blanks(level * 4, ' ');
    printf("%s", blanks.c_str());
}

void print_xmltree(xmlNodePtr xroot, int level)
{    
    print_indent(level);
    
    printf("%s ", xroot->name);    
    if (xroot->properties)
    {
        printf("[");
        for (xmlAttrPtr a = xroot->properties; a != 0; a = a->next)
        {
            printf("%s=%s", a->name, xmlNodeGetContent(a->children));  // or one can write xmlGetProp(xroot, a->name)
            if (a->next) printf(", ");
        }
        printf("]");
    }
    
    if (xroot->children && xroot->children->next == 0 && xroot->children->type == XML_TEXT_NODE)
    {
        printf("{%s}", xmlNodeGetContent(xroot->children));
    }
    printf("\n");

    for (xmlNodePtr c = xroot->children; c != 0; c = c->next)
    {   
        if (c->type == XML_ELEMENT_NODE)     
            print_xmltree(c, level + 1);
    } 
}


inline unsigned long pdiff(const void *p0, const void *p1)
{
    return (unsigned long)((const char*)p0 - (const char*)p1);
}


int main(int argc, char *argv[])
{    
    // parse the file into a tree
    xmlDocPtr xdoc = xmlParseFile("ex1.xml");
    
    // print document information
    printf("XML document:\n");
    printf("struct size = %lu\n", sizeof(*xdoc));
    assert(xdoc->doc == xdoc);

    printf("\ttype = %d\n", xdoc->type);
    printf("\tname = %s\n", safe_str(xdoc->name));
    printf("\tversion = %s\n", xdoc->version);
    printf("\tencoding = %s\n", xdoc->encoding);
    printf("\tcompression = %d\n", xdoc->compression);
    printf("\tstandalone = %d\n", xdoc->standalone);
    printf("\n");
    
    // print xml tree
    printf("XML Tree:\n");
    xmlNodePtr xroot = xmlDocGetRootElement(xdoc);
    assert(xroot == xdoc->children);
    print_xmltree(xroot, 0);
    printf("\n");
    
    // write XML file to a buffer & print
    xmlBufferPtr buf = xmlBufferCreateSize(1024);
    xmlOutputBufferPtr outbuf = xmlOutputBufferCreateBuffer(buf, NULL);
    xmlSaveFileTo(outbuf, xdoc, "utf-8"); 
    printf("Buffered XML:\n");
    printf("%s\n", xmlBufferContent(buf));
    xmlBufferFree(buf);
    printf("\n");
                            
    // release the document
    xmlFreeDoc(xdoc);
    
    return 0;
}

