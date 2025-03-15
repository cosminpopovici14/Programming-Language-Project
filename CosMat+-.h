#include <iostream>
#include <string>
#include <vector>
using namespace std;



class VarAtrib
{
    public:
    string name;
    string value;
    string type;;
};

class FuncAtrib
{
    public:
    string name;
    string type;
    vector<string> parameters;;
};
class ClassAtrib
{
    public:
    string name;;
};

class SymTable
{
public:
    string name;
    vector<VarAtrib> vars;
    vector<FuncAtrib> funcs;
    vector<ClassAtrib> classes;
    SymTable* parent;
    vector<SymTable*> children;
    SymTable(string name, SymTable* parent = nullptr)
    {
    this->name = name;
    this->vars = {};
    this->funcs = {};
    this->classes = {};
    this->parent = parent;  
    }

    ~SymTable() = default;
    SymTable* addScope(string name);
    void addVar(string type, string name, string value);
    void addClass(string name);
    void addFunc(string type, string name, vector<string>parameters);

    string getVarName(string msg);
    string getVarType(string msg);
    string getVarValue(string msg);

    int isDefinedVar(string s);
    int isDefinedFunc(string s);
    int isDefinedInScope(string s);

    string getFuncName(string msg);
    string getFuncType(string msg);
    vector<string> getFuncParam(string msg);
  

    string getClassName(string msg);
   

    void printTable(FILE* file_ptr);

};

void yyerror(const string &s);