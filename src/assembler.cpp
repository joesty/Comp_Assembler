#include <iostream>
#include <string>
#include <fstream>
#include <sstream>
#include <vector>
#include "instruction.cpp"
#include "symboltable.cpp"
#include "fontcode.cpp"
#include "utils/tables.cpp"
using namespace std;

#define memorysize 1000

class Automato{
    private:
    POT pot;
    MOT mot;
    string type = "";
    public:
    pair<string, int> conversion(string input){
        pair<string, int> output = pot.potTable(input);
        if (output.first == "empty"){
            output = mot.motTable(input);
            if (output.first == "empty")
                return make_pair("Syntax Erro", 0);
            else
                type = "mot";
                return output;
        }
        else
            type = "pot";
            return output;
    };
    string getType(){
        return type;
    }
};


class Assembler{
    private:
    FontCode font;
    Automato automato;
    SymbolTable st;
    ofstream file;
    string input, output;
    int memory[memorysize];
    int pc, ac, sp, lc, pn;
    vector<string> translation;
    
    public:
    Assembler(string in, string out){
        initMemory();
        input = in;
        output = out;
        pc = ac = lc = pn = 0;
        sp = memorysize-1;
    }
    void print(){
        vector<string> splitedLine = font.splitLine();
        for(int i = 0; i < splitedLine.size(); i++){
            cout<<splitedLine[i]<<endl;
        }
    }
    void firstPass(){
        font.setFile(input);
        string word = "";
        pair<string, int> token;
        string label, operation, operand;
        vector<string> splitedLine;
        while(true){   
            splitedLine = font.splitLine();
            //cout<<splitedLine.size()<<endl;
            Instruction instruction = Instruction(splitedLine);
            label = instruction.getLabel();
            operation = instruction.getOperation();
            operand = instruction.getOperand();
            if (operation == "END"){
                break;
            }
            token = automato.conversion(operation);
            if (label != "empty"){
                if(automato.getType() == "mot" or automato.getType() == "pot"){
                    st.push(label, lc);
                }
            }
            lc = lc+token.second;
            //cout<<endl;
        }
        font.closeFile();
        //cout<<endl;
    }
    void doOperations(string op, int m){
        if (op == "LOAD"){
            ac = memory[m+pc];
        }else if (op == "STORE"){
            memory[m+pc] = ac;
        }else if (op == "ADD"){
            ac = ac+memory[m+pc];
        }else if (op == "SUB"){
            ac = ac-memory[m+pc];
        }else if (op == "JMP"){
            pc = m+pc;
        }else if (op == "JPG"){
            if(ac > 0){
                pc = m+pc;
            }
        }else if (op == "JPL"){
            if(ac < 0){
                pc = m+pc;
            }
        }else if (op == "JPE"){
            if(ac == 0){
                pc = m+pc;
            }
        }else if (op == "JPNE"){
            if(ac != 0){
                pc = m+pc;
            }
        }else if (op == "PUSH"){
            sp = sp-1;
            memory[sp] = memory[m+pc];
        }else if (op == "POP"){
            memory[m+pc] = memory[sp];
            sp = sp+1;
        }else if (op == "READ"){
            memory[m+pc] = memory[m+pc];
        }else if (op == "WRITE"){
            memory[m+pc] = memory[m+pc];
        }else if (op == "CALL"){
            sp = sp-1;
            memory[sp] = pc;
            pc = m+pc;
        }else if (op == "RET"){
            pc = memory[sp];
            sp = sp+1;
        }
    }
    void secondPass(){
        font.setFile(input);
        lc = 0;
        vector<string> splitedLine;
        string label, operation, operand;
        pair<string, int> token;
        while(true){
            splitedLine = font.splitLine();
            //cout<<splitedLine.size()<<endl;
            Instruction instruction = Instruction(splitedLine);
            label = instruction.getLabel();
            operation = instruction.getOperation();
            operand = instruction.getOperand();
            if (operation == "END"){
                break;
            }
            token = automato.conversion(operation);
            lc += token.second;
            if (st.find(operand)){
                //cout<<token.first<<" ";
                translation.push_back(token.first);
                pn+=1;
                int operandInt = st.getOperandValue(operand);
                string operandValue = to_string(operandInt-lc);
                //cout<<operandValue<<" ";
                translation.push_back(operandValue);
                doOperations(operation, operandInt-lc);
                pn+=1;
            }
            else{
                if (automato.getType() != "pot"){
                    
                    //cout<<token.first<<" ";
                    translation.push_back(token.first);
                    pn+=1;
                    if (operand != "empty"){
                        //cout<<operation<<endl;
                        //cout<<operand<<endl;
                        doOperations(operation, stoi(operand));
                    }
                }else{
                    if (operand != "empty"){
                        //cout<<stoi(operand)<<" ";
                        translation.push_back(operand);
                        //cout<<operand<<endl;
                        doOperations(operation, (stoi(operand)+1)*token.second);
                        pn+=1;
                    }
                }
            }
        }
        //cout<<endl;
        font.closeFile();
    }
    void printST(){
        st.print();
    }
    void printTranslation(){
        for (int i = 0; i < translation.size(); i++){
            cout<<translation[i]<<" ";
        }
        cout<<endl;
    }
    void saveFile(){
        file.open(output);
        file << "MV1 0 ";
        file << sp <<" ";
        file << to_string(pn)<<" ";
        for (int i = 0; i < translation.size(); i++){
            //cout<<translation[i]<<" ";
            file << translation[i]<<" ";
        }
        file << endl;
        file.close();
    }
    void initMemory(){
        for (int i = 0; i < memorysize; i++){
            memory[i] = -1;
        }
    }
    void run(){
        firstPass();
        secondPass();
        saveFile();
    }
};