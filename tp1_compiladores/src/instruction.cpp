#include <iostream>
#include <string>
#include <fstream>
#include <sstream>
#include <vector>
using namespace std;

class Instruction{
    private:
    string label;
    string operation;
    string operand;
    public:
    Instruction(vector<string> instruction){
        if (instruction[0].back() == ':'){
            string aux = instruction[0];
            label = aux.erase(aux.find(':'));
            operation = instruction[1];
            if (instruction.size() >= 3){
                operand = instruction[2];
            }else{
                operand = "empty";
            }
        }else{
            
            operation = instruction[0];
            if (instruction.size() >= 2 and instruction[1].front() != ';'){
                operand = instruction[1];
            }else{
                operand = "empty";
            }
            label = "empty";
            /*
            label = "joao";
            operation = "joao";
            operand = "joao";
            */
        }
    }
    string getLabel(){
        return label;
    }
    string getOperation(){
        return operation;
    }
    string getOperand(){
        return operand;    
    }
};
