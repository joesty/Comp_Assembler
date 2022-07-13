#include <iostream>
#include <string>

using namespace std;

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