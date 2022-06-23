#include <iostream>
#include <fstream>
#include <string>
using namespace std;

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