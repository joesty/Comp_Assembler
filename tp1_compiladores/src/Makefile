CC = g++

CPPFLAGS += -g -std=c++11 -Wall
LDLIBS += -lm

.PHONY: all clean

all: 
	g++ src/main.cpp -o assembler

execute:
	./assembler ./input.txt ./output.txt

clean:
	rm -f assembler
