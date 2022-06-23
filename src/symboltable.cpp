#include <iostream>
#include <vector>
#include <string>
#include "symbol.cpp"

using namespace std;


class SymbolTable{
    private:
    vector<Symbol> symbolTable;
    public:
    void push(string label, int value){
        Symbol symb(label, value);
        symbolTable.push_back(symb);
    }
    void print(){
        for (int i = 0; i < symbolTable.size(); i++){
            symbolTable[i].print();
        }
    }
    bool find(string label){
        for(int i = 0; i < symbolTable.size(); i++){
            if (symbolTable[i].getLabel() == label){
                return true;
            }
        }
        return false;
    }
    int getOperandValue(string label){
        for(int i = 0; i < symbolTable.size(); i++){
            if(symbolTable[i].getLabel() == label){
                return symbolTable[i].getValue();
            }
        }
        return 0;
    }
};
