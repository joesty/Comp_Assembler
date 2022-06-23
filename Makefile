CC = g++

CPPFLAGS += -g -std=c++11 -Wall
LDLIBS += -lm

.PHONY: all clean

all: 
	g++ src/main.cpp -o assembler

clean:
	rm -f assembler
