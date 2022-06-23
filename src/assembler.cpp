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

class Symbol{
    private:
    string label;
    int value;
    public:
    Symbol(string lab, int val){
        label = lab;
        value = val;
    }
    pair<string, int> getData(){
        pair<string, int> result(label, value);
        return result;
    }
    string getLabel(){
        return label;
    }
    int getValue(){
        return value;
    }
    void print(){
        cout<<label<<" "<<value<<endl;
    }
};

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

class FontCode{
    private:
    ifstream file;
    public:
    void setFile(string filename){
        file.open(filename);
    }
    void closeFile(){
        file.close();
    }
    string readLine(){
        string line;
        getline(file, line);
        return line;
    }
    vector<string> splitLine(){
        vector<string> splitString;
        string line = readLine();
        //cout<<line<<endl;
        stringstream ss(line);
        string word;
        while(ss >> word){
            splitString.push_back(word);
        }
        return splitString;
    }
};


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
    int pc, ac, sp, lc;
    public:
    Assembler(string fontfile){
        font.setFile(fontfile);
        pc = 0;
        ac = 0;
        sp = 0;
        lc = 0;
    }
    /*
    string token(string word){
        string result = automato.conversion(word);
        return result;
    }*/
    void print(){
        vector<string> splitedLine = font.splitLine();
        for(int i = 0; i < splitedLine.size(); i++){
            cout<<splitedLine[i]<<endl;
        }
    }
    /*
    void firstPass(){
        string word = "";
        pair<string, int> token;
        string label, instruction, value;
        vector<string> splitedLine;
        while(true){   
            splitedLine = font.splitLine();
            //cout<<splitedLine.size()<<endl;
            if(splitedLine[0].back() == ':'){
                label = splitedLine[0];  //[label:]   [instruction]   [operand]
                instruction = splitedLine[1];
                token = automato.conversion(splitedLine[1]);
                cout<<"label"<<" "<<token.first<<" ";
                if (splitedLine.size() >= 3){
                    value = splitedLine[2];
                    cout<<value;
                }
                if(automato.getType() == "mot"){
                    st.push(label, lc);
                }
                else if(automato.getType() == "pot"){
                    st.push(label, lc);
                }
            }   
            else{
                instruction = splitedLine[0];
                token = automato.conversion(splitedLine[0]);
                cout<<token.first<<" ";
                if (splitedLine.size() > 1){
                    value = splitedLine[1];
                    cout<<value;
                }
            }
            if (instruction == "END"){
                break;
            }
            lc = lc+token.second;
            cout<<endl;
        }
        font.closeFile();
        cout<<endl;
    }*/

    void firstPass(){
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
        cout<<endl;
    }

    void secondPass(string inputfile){
        lc = 0;
        font.setFile(inputfile);
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
                cout<<token.first<<" ";
                cout<<st.getOperandValue(operand)-lc<<endl;
            }
            else{
                if (automato.getType() != "pot")
                    cout<<token.first<<" ";
                if (operand != "empty")
                    cout<<stoi(operand);
                cout<<endl;
            }
        }
    }
    void printST(){
        st.print();
    }
};