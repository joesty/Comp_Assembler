#include <iostream>
#include "assembler.cpp"
#include "utils/convert.cpp"

using namespace std;

int main(int argc, char **argv){
    //string input = "/home/joesty/Comp_Assembler/input.txt"; 
    string input = "/home/joesty/Comp_Assembler/input.txt"; 
    string output = "./utils/output.txt";
    string in;
    string out;
    vector<string> args;
    if(argc > 2){
        args.push_back(argv[1]);
        args.push_back(argv[2]);
        input = convertArgvToString(args[0]);
        output = convertArgvToString(args[1]);
        //pair<string, string> io(convertArgvToString(argc, args));
        //out = io.second;
        //cout<<out<<endl;
    }
    Assembler assembler(input, output);
    //assembler.token();
    assembler.run();
}