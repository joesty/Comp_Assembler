#include <iostream>
#include <string>

using namespace std;

class MOT{
    public:
    pair<string, int> motTable(string input){
        if(input == "LOAD")
            return make_pair("1", 2);
        if(input == "STORE")
            return make_pair("2", 2);
        if(input == "ADD")
            return make_pair("3", 2);
        if(input == "SUB")
            return make_pair("4", 2);;
        if(input == "JMP")
            return make_pair("5", 2);
        if(input == "JPG")
            return make_pair("6", 2);
        if(input == "JPL")
            return make_pair("7", 2);
        if(input == "JPE")
            return make_pair("8", 2);
        if(input == "JPNE")
            return make_pair("9", 2);
        if(input == "PUSH")
            return make_pair("10", 2);
        if(input == "POP")
            return make_pair("11", 2);
        if(input == "READ")
            return make_pair("12", 2);
        if(input == "WRITE")
            return make_pair("13", 2);
        if(input == "CALL")
            return make_pair("14", 2);
        if(input == "RET")
            return make_pair("15", 1);
        if(input == "HALT")
            return make_pair("16", 1);
        else
            return make_pair("empty", 0);
    }
};

class POT{  
    public:
    pair<string, int> potTable(string input){
        if(input == "WORD")
            return make_pair("WORD", 1);
        if(input == "END")
            return make_pair("END", 0);
        else
            return make_pair("empty", 0);
    }
};