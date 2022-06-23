#include <iostream>
#include "assembler.cpp"

using namespace std;

int main(){
    Assembler assembler("/home/joesty/Comp_Assembler/input.txt");
    //assembler.token();
    assembler.firstPass();
    cout<<endl<<"Print ST"<<endl;
    assembler.printST();
    assembler.secondPass("/home/joesty/Comp_Assembler/input.txt");
}