# Make the C++ file

CXX = g++
CXXFLAGS = -Wall -O2 -I/usr/include/libxml2

.phony: all executables
	
all: executables
	
executables: ex1
	
ex1: ex1.cpp
	$(CXX) $(CXXFLAGS) ex1.cpp -o $@ -lxml2

