
OS = $(shell uname)

ifeq ($(OS), WINNT)
	SHLIB_EXT = dll 
else ifeq ($(OS), Darwin)
	SHLIB_EXT = dylib
else
	SHLIB_EXT = so
endif

CC = gcc
CFLAGS = -Wall -O2 -I/usr/include/libxml2

all: lxwrappers

.phony: all

lxwrappers: lxwrappers.$(SHLIB_EXT)	

lxwrappers.$(SHLIB_EXT): src/lxwrappers.c
	$(CC) $(CFLAGS) -fPIC -c $< -o $@

clean:
	rm -r usr

