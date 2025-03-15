#include "CosMat+-.h"
#include <fstream>
#include <stdio.h>
#include <stack>
using namespace std;
ofstream fout ("SymbolTable.txt");


SymTable *SymTable::addScope(string name)
{
    SymTable* child = new SymTable(name, this);
    children.push_back(child);
    return child;
}

void SymTable::addVar(string type, string name, string value)
{
    VarAtrib var;
    var.type = type;
    var.name = name;
    var.value = value;
    vars.push_back(var);
}

void SymTable::addFunc(string type, string name, vector<string> parameters)
{
    FuncAtrib func;
    func.type = type;
    func.name = name;
    func.parameters = parameters;
    funcs.push_back(func);
}

void SymTable::addClass(string name)
{
    ClassAtrib clas;
    clas.name = name;
    classes.push_back(clas);
}

string SymTable::getVarName(string msg)
{
    for (VarAtrib v : vars)
    {
        if(v.name == msg)
            return v.name;
    }
    return "NULL";
}

string SymTable::getVarType(string msg)
{
    for (VarAtrib v : vars)
    {
        if(v.name == msg)
            return v.type;
    }
    if(this->parent != nullptr)
        return parent->getVarType(msg);
    return "NULL";
}

string SymTable::getVarValue(string msg)
{
    for (VarAtrib v : vars)
    {
        if(v.name == msg)
            return v.value;
    }
    if(this->parent != nullptr)
        return parent->getVarValue(msg);
    return "NULL";
}

int SymTable::isDefinedVar(string s)
{
    for(auto& v : vars)
    {
        if(s == v.name)
            return 1;
    }
    if(this->parent != nullptr)
        return parent->isDefinedVar(s);
    return 0;
}

int SymTable::isDefinedFunc(string s)
{
    for(auto& f : funcs)
    {
        if(s == f.name)
            return 1;
    }
    if(this->parent != nullptr)
        return parent->isDefinedFunc(s);
    return 0;
}

int SymTable::isDefinedInScope(string s)
{
    for(auto& v : vars)
    {
        if(s == v.name)
            return 1;
    }
    if(this->name == "if_block" || this->name == "for_block" || this->name == "while_block")
        return parent->isDefinedInScope(s);
    return 0;
}

string SymTable::getFuncName(string msg)
{
    for (FuncAtrib f : funcs)
    {
        if(f.name == msg)
            return f.name;
    }
    return "NULL";
}

string SymTable::getFuncType(string msg)
{
    for (FuncAtrib f : funcs)
    {
        if(f.name == msg)
            return f.type;
    }
    return "NULL";
}

vector<string> SymTable::getFuncParam(string msg)
{
    for (FuncAtrib f : funcs)
    {
        if(f.name == msg)
            return f.parameters;
    }
    vector<string> v;
    v.push_back("NULL");
    return v;
}



string SymTable::getClassName(string msg)
{
    for (ClassAtrib c : classes)
    {
        if(c.name == msg)
            return c.name;
    }
    return "NULL";
}




void SymTable::printTable(FILE* file_ptr)
{
    
    fprintf(file_ptr, "Scope: %s\n",  name.c_str());
    fprintf(file_ptr, "Variables:\n");
    for (auto& v : vars) {
        fprintf(file_ptr, "%s %s = %s\n",  v.type.c_str(), v.name.c_str(), v.value.c_str());
    }

    fprintf(file_ptr, "Functions:\n");
    for (auto& f : funcs) {
        fprintf(file_ptr, "%s %s(",  f.type.c_str(), f.name.c_str());
        for (size_t i = 0; i < f.parameters.size(); ++i) {
            fprintf(file_ptr, "%s%s", f.parameters[i].c_str(), i < f.parameters.size() - 1 ? ", " : ")\n");
        }
    }

    fprintf(file_ptr, "Classes:\n");
    for (auto& c : classes) {
        fprintf(file_ptr, "%s\n",  c.name.c_str());
    }

    fprintf(file_ptr, "\n");
    for (auto& child : children) {
        // fprintf(file_ptr, "Child name: %s\n",child->name.c_str());
        child->printTable(file_ptr);
    }
    
}



stack <SymTable*> scopeStack;

// void enterScopeName(string scopeName)
// {
//     SymTable* newScope = new SymTable(scopeName, scopeStack.empty()? nullptr : scopeStack.top());
//     scopeStack.push(newScope);
// }

// void exitScopeName()
// {
//     if(!scopeStack.empty())
//     {
//         SymTable* currentScope = scopeStack.top();
//         currentScope->printTable(file_ptr);
//         scopeStack.pop();
//     }
// }
