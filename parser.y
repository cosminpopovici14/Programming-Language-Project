%{
#include <iostream>
#include <string>
#include <vector>
#include <cstdio>
#include "CosMat+-.cpp"
#include "AST.cpp"
using namespace std;
SymTable* globalScope = new SymTable("global");
SymTable* currentScope = globalScope;
vector<string> parameters;
string currentOperationType = "";
class AST ast;


bool isInt(string s) {
    for (size_t i = 0; i < s.length(); i++) {
        if (!isdigit(s[i])) {
            return false;
        }
    }
    return true;
}

bool isFloat(string s) 
{
    int dots = 0;
    for (size_t i = 0; i < s.length(); i++) {
        if (!isdigit(s[i])) 
        {
            if (s[i] == '.' && dots == 0) 
            {
                dots++;
            } 
            else 
            {
                return false;
            }
        }
    }
    if (dots == 0 ){
        return false;
    }
    return true;
}

bool isBool(string s) {
    if (s == "true" || s == "false") {
        return true;
    }
    return false;
}

bool isChar(string s) {
    if (s.length() == 3 && s[0] == '?' && s[2] == '?') {
        return true;
    }
    return false;
}



extern int yylex();
void yyerror(const char *s) {
    std::cerr << "Error: " << s << std::endl;
}
%}

%union {
    int integer;
    float floating;
    bool boolean;
    char characters;
    char* string;
    struct Node* node;
}

// Declararea tokenilor

%type <node> operation
%token <integer> INT 
%token <string> STRING TYPE IDENTIFIER
%token <floating> FLOAT
%token <boolean> BOOL
%token IF FOR WHILE EQ NEQ LT GT GEQ LEQ CLASS METHOD CLASS_BEGIN CLASS_END VAR_BEGIN VAR_END FUNC_BEGIN FUNC_END MAIN_BEGIN MAIN_END AND OR NOT NEW
%token PLUSPLUS MINUSMINUS EQEQ 
%token PRINT TYPEOF 
%start file
%%

file : CLASS_BEGIN classes CLASS_END VAR_BEGIN variables VAR_END FUNC_BEGIN functions FUNC_END MAIN_BEGIN principal MAIN_END {cout<< "The program is correct!\n";}
     ;

principal : variables
          | functions
          | ecuations
          | principal ecuations
          | principal variables
          | principal functions
          ;

classes_use : IDENTIFIER EQ NEW IDENTIFIER '(' values ')' ';' {cout<< "Object initialised\n";}
            | IDENTIFIER METHOD method_call { cout << "Method called\n"; }
            ;

method_call : IDENTIFIER '(' values ')' ';'
              | IDENTIFIER '(' ')' ';'
              ;

values : INT
       | FLOAT
       | '?' IDENTIFIER '?'
       | STRING
       | BOOL
       | values ',' INT
       | values ',' FLOAT
       | values ',' '?' IDENTIFIER '?'
       | values ',' STRING
       | values ',' BOOL
       ;

classes : 
        | class
        | classes class
        ;

class : CLASS IDENTIFIER '{' {SymTable* classScope = currentScope->addScope($2); currentScope->addClass($2);currentScope = classScope;} variables functions '}' { currentScope = currentScope->parent; cout << "Class " << $2 << " has been defined.\n";}
      ;

variables : 
          | variable_declaration            {;}
          | variable_assignment             {;}
          | array_declaration               {;}
          | array_assignment                {;}
          | classes_use                     {;}
          | variables variable_declaration  {;}
          | variables array_declaration     {;}
          | variables array_assignment      {;}
          | variables classes_use           {;}
          | variables variable_assignment   {;}
          ;
        
functions : 
          | function
          | functions function 
          | function_call
          | functions function_call
          ;

function : TYPE IDENTIFIER '('  parameters 
                                {SymTable* funcScope = currentScope->addScope($2); currentScope->addFunc($1,$2,parameters); currentScope = funcScope;}  
                                ')' '{' ecuations '}' {   cout << "Function " << $2 << " has been defined.\n";
                                for(int i = 0;i <parameters.size();i++){cout<<"parameter "<< i<< ":"<< parameters[i]<<endl;} parameters.clear(); currentScope = currentScope->parent;}
parameters: param
          | param ',' parameters

param :
           | function_call                                  {;}
           | TYPE IDENTIFIER                                {parameters.push_back(string($1));}
           | TYPE IDENTIFIER '[' INT ']' ';'                {parameters.push_back(string($1));}
           ;

function_call : PRINT '('  operation  ')' ';' { cout<< "Print() value: "<<ast.evaluateTree()<<endl; 
                                            ast.printTree();
                                            cout<< "Predefined function Print(expr) called.\n";}
              | TYPEOF  '(' operation ')' ';' { cout<< "TypeOf() value: ";
                                            string result = ast.evaluateTree();
                                            if(isInt(result)) cout<< "Integer\n";
                                            else if(isFloat(result)) cout<< "Float\n";
                                            else if(isBool(result)) cout<< "Boolean\n";
                                            else if(isChar(result)) cout<< "Char\n";
                                            else cout<< "String\n";

                                            
                                            
                                            cout<< "Predefined function TypeOf(expr) called.\n";}
              | IDENTIFIER '(' parameters ')' ';' { if(!currentScope->isDefinedFunc($1)) 
                                                      cout << "ERROR: Function " << $1 << " is not defined!" << endl;
                                                    else
                                                    {
                                                      vector<string> curr_params = currentScope->getFuncParam($1);
                                                      for (size_t i = 0; i < parameters.size(); i++) 
                                                      {
                                                        if(parameters[i]!=curr_params[i])
                                                          cout<<"ERROR: in Function "<<$1<<" the parameters don't have the correct type!\n";
                                                      } 
                                                    } 
                                                    }

if_declaraction:
      IF '(' operation ')'
      {
        if( ast.evaluateTree()!= "true" && ast.evaluateTree()!="false")
          cout << "ERROR: The condition in the if statement is not a boolean expression!\n";
        SymTable* blockScope = currentScope->addScope("if_block"); 
        currentScope = blockScope;
      }
        '{' ecuations '}'
      {
        currentScope = currentScope->parent;
        std::cout<<"Did IF statement"<<std::endl;
      }
      ;
while_declaration:
      WHILE '(' operation ')'
      {
        if( ast.evaluateTree()!= "true" && ast.evaluateTree()!="false")
          cout << "ERROR: The condition in the while statement is not a boolean expression!\n";
        SymTable* blockScope = currentScope->addScope("while_block");
         currentScope = blockScope;} '{' ecuations '}'
      {
        currentScope = currentScope->parent;
        std::cout<<"Did WHILE statement"<<std::endl;
      }
      ;
for_declaration:
      FOR '(' variable_declaration  operation ';' increment ')'
      {
        if( ast.evaluateTree()!= "true" && ast.evaluateTree()!="false")
          cout << "ERROR: The condition in the for statement is not a boolean expression!\n";
        SymTable* blockScope = currentScope->addScope("for_block");
         currentScope = blockScope;
      } 
         '{' ecuations '}'
      {
        currentScope = currentScope->parent;
        std::cout<<"Did FOR statement"<<std::endl;
      }
      ;


ecuations:
        variable_declaration
      | array_declaration
      | variable_assignment
      | array_assignment
      | if_declaraction
      | while_declaration
      | for_declaration
      | ecuations array_assignment
      | ecuations variable_assignment
      | ecuations array_declaration
      | ecuations if_declaraction
      | ecuations while_declaration
      | ecuations for_declaration 
      | ecuations variable_declaration
      ;


variable_assignment:

      IDENTIFIER EQ operation ';'
      {
        if(!currentScope->isDefinedVar($1)) 
          std::cout << "ERROR: Variable " << $1 << " is not defined!" << endl;
        else std::cout<<"Updated "<<$1<<", with the given expression result "<<std::endl;
        currentOperationType = "";
      }
    | increment
    ;

increment:
    | IDENTIFIER PLUSPLUS ';'
      {
        if(!currentScope->isDefinedVar($1)) 
          std::cout << "ERROR: Variable " << $1 << " is not defined!" << endl;
        else std::cout<<"Am incrementat valoarea variabilei "<<$1<<" cu 1"<<std::endl;
      }
    | IDENTIFIER MINUSMINUS ';'
      {
        if(!currentScope->isDefinedVar($1)) 
          std::cout << "ERROR: Variable " << $1 << " is not defined!" << endl;
        else std::cout<<"Am decrementat valoarea variabilei "<<$1<<" cu 1"<<std::endl;
      }
operation :
    operation '+' operation        {if($1->type != $3->type) cout << "ERROR: Operands of the expression don't have the same type!\n";
                                            else if($1->type == "bool") cout << "ERROR: Can't perform operations on boolean values!\n";
                                              else {
                                                $$ = new Node{$1, $3, "+", $1->type};
                                                ast.AddNode("+", $1, $3, $1->type);
                                              }}
    |operation '-' operation        {if($1->type != $3->type) cout << "ERROR: Operands of the expression don't have the same type!\n";
                                            else  if($1->type == "bool") cout << "ERROR: Can't perform operations on boolean values!\n";
                                              else {
                                                $$ = new Node{$1, $3, "-", $1->type};
                                                ast.AddNode("-", $1, $3, $1->type);
                                              }}
    |operation '*' operation        {if($1->type != $3->type) cout << "ERROR: Operands of the expression don't have the same type!\n";
                                            else  if($1->type == "bool") cout << "ERROR: Can't perform operations on boolean values!\n";
                                              else {
                                                $$ = new Node{$1, $3, "*", $1->type};
                                                ast.AddNode("*", $1, $3, $1->type);
                                              }}
    |operation '/' operation        {if($1->type != $3->type) cout << "ERROR: Operands of the expression don't have the same type!\n";
                                            else  if($1->type == "bool") cout << "ERROR: Can't perform operations on boolean values!\n";
                                              else {
                                                $$ = new Node{$1, $3, "/", $1->type};
                                                ast.AddNode("/", $1, $3, $1->type);
                                              }}
    | operation '%' operation        {if($1->type != $3->type) cout << "ERROR: Operands of the expression don't have the same type!\n";
                                            else if($1->type == "bool") cout << "ERROR: Can't perform operations on boolean values!\n";
                                              else {
                                                $$ = new Node{$1, $3, "%", $1->type};
                                                ast.AddNode("%", $1, $3, $1->type);
                                              }}
    | operation AND operation         {if($1->type != $3->type) cout << "ERROR: Operands of the expression don't have the same type!\n";
                                             else if($1->type != "bool") cout << "ERROR: Can't perform operations on non-boolean values!\n";
                                              else {
                                                $$ = new Node{$1, $3, "&&", $1->type};
                                                ast.AddNode("&&", $1, $3, $1->type);
                                              }}
    | operation OR operation          {if($1->type != $3->type) cout << "ERROR: Operands of the expression don't have the same type!\n";
                                             else if($1->type != "bool") cout << "ERROR: Can't perform operations on non-boolean values!\n";
                                              else {
                                                $$ = new Node{$1, $3, "||", $1->type};
                                                ast.AddNode("||", $1, $3, $1->type);
                                              }}
    | NOT operation                  {if($2->type != "bool") cout << "ERROR: Can't perform operations on non-boolean values!\n";
                                              else {         
                                                $$ = new Node{NULL, $2, "!", "bool"};
                                                ast.AddNode("!", NULL, $2, "bool");
                                              }}
    | operation LT operation         {cout<<"$3->type "<<$3->type<<endl; 
                                        if($1->type != $3->type) cout << "ERROR: Operands of the expression don't have the same type!\n";
                                        else      
                                         {$$ = new Node{$1, $3, "<", "bool"};
                                                ast.AddNode("<", $1, $3, "bool");}
                                      }
    | operation GT operation         {if($1->type != $3->type) cout << "ERROR: Operands of the expression don't have the same type!\n";
                                           else   
                                                {$$ = new Node{$1, $3, ">", "bool"};
                                                ast.AddNode(">", $1, $3, "bool");}
                                      }
    | operation LEQ operation        {if($1->type != $3->type) cout << "ERROR: Operands of the expression don't have the same type!\n";
                                              else
                                                {$$ = new Node{$1, $3, "<=", "bool"};
                                                ast.AddNode("<=", $1, $3, "bool");}
                                              }
    | operation GEQ operation        {if($1->type != $3->type) cout << "ERROR: Operands of the expression don't have the same type!\n";
                                                else        
                                                {$$ = new Node{$1, $3, ">=", "bool"};
                                                ast.AddNode(">=", $1, $3, "bool");}
                                              }
    | operation EQEQ operation       {if($1->type != $3->type) cout << "ERROR: Operands of the expression don't have the same type!\n";
                                              else        
                                                {$$ = new Node{$1, $3, "==", "bool"};
                                                ast.AddNode("==", $1, $3, "bool");}
                                              }
    | operation NEQ operation        {if($1->type != $3->type) cout << "ERROR: Operands of the expression don't have the same type!\n";
                                              else
                                                {$$ = new Node{$1, $3, "!=", "bool"};
                                                ast.AddNode("!=", $1, $3, "bool");}
                                              }
    |'(' operation ')' { $$ = $2; }
    |INT                                      {if(currentOperationType == "" or  currentOperationType == "int") 
                                                {
                                                  currentOperationType = "int";
                                                  $$ = new Node{NULL, NULL, to_string($1), "int"};
                                                  ast.AddNode(to_string($1), NULL, NULL, "int");
                                                }
                                                else cout << "ERROR: Operands of the expression don't have the same type!\n";
                                                 
                                              }
    |FLOAT                                    {if(currentOperationType == "" or  currentOperationType == "float") 
                                                {
                                                  currentOperationType = "float";
                                                  $$ = new Node{NULL, NULL, to_string($1), "float"};
                                                  ast.AddNode(to_string($1), NULL, NULL, "float");
                                                }
                                                else cout << "ERROR: Operands of the expression don't have the same type!\n";
                                                 
                                              }
    |'?' IDENTIFIER '?'                       {if(currentOperationType == "" or  currentOperationType == "char") 
                                                {
                                                  currentOperationType = "char";
                                                  $$ = new Node{NULL, NULL, $2, "char"};
                                                  ast.AddNode($2, NULL, NULL, "char");
                                                }
                                                else cout << "ERROR: Operands of the expression don't have the same type!\n";
                                                 
                                              }   
    |STRING                                   {if(currentOperationType == "" or currentOperationType == "string")  
                                              {
                                                currentOperationType = "string";
                                                $$ = new Node{NULL, NULL, $1, "string"};
                                                ast.AddNode($1, NULL, NULL, "string");
                                              }
                                              else 
                                                  {cout << "ERROR: Operands of the expression don't have the same type!\n";}
                                              
                                              }
    |BOOL                                     {if(currentOperationType == "" or  currentOperationType == "bool") 
                                                {
                                                  currentOperationType = "bool";
                                                  $$ = new Node{NULL, NULL, $1?"true":"false", "bool"};
                                                  ast.AddNode($1?"true":"false", NULL, NULL, "bool");
                                                }
                                                else cout << "ERROR: Operands of the expression don't have the same type!\n";
                                                 
                                              }
    |IDENTIFIER                               {if(!currentScope->isDefinedVar($1)) std::cout << "ERROR: Variable " << $1 << " is not defined!" << endl; 
                                              else if(currentOperationType == "" or currentOperationType == currentScope->getVarType($1)) 
                                              {
                                                currentOperationType = currentScope->getVarType($1);
                                                $$ = new Node{NULL, NULL, currentScope->getVarValue($1), currentScope->getVarType($1)};
                                                ast.AddNode(currentScope->getVarValue($1), NULL, NULL, currentScope->getVarType($1));                                              
                                              }
                                              else  cout << "ERROR: Operands of the expression don't have the same type!\n";
                                              }
    
 
    


array_declaration:
      TYPE IDENTIFIER '[' INT ']' ';'
      {
    
        if(currentScope->isDefinedInScope($2))
          cout << "ERROR: Variable " << $2 << " is already defined in this scope!\n";
        else if(!currentScope->isDefinedVar($4))
          std::cout << "ERROR: Variable " << $4 << " is not defined!" << endl;
        else
        {
          currentScope->addVar($1,$2, "NULL");
          std::cout << "Assigning value of variable \"" << $4 << "\" to variable \"" << $2 << "\"\n" ;
        }
        std::cout<<"Declaring array of type "<<$1<<", with name "<<$2<<", of size "<<$4<<std::endl; 
      }
array_assignment:
       IDENTIFIER '[' INT ']' EQ IDENTIFIER ';'
      {
        if(currentScope->getVarType($1) != currentScope->getVarType($6))
          cout << "ERROR: The left and right sides don't have the same type!\n";
        else if(!currentScope->isDefinedVar($6))
          std::cout << "ERROR: Variable " << $6 << " is not defined!" << endl;
        else
        {
          std::cout<<"Assigning value " << $6 << ", in array "<< $1 <<", at position "<< $3<<std::endl;
        }
      }
    |  IDENTIFIER '[' INT ']' EQ INT ';'
      {
        if(currentScope->getVarType($1) != "int")
          cout << "ERROR: The left and right sides don't have the same type!\n";
        else 
          cout<<"Assigning value " << $6 << ", in array "<< $1 <<", of type INT, at position "<< $3<<std::endl;
      }
    | IDENTIFIER '[' INT ']' EQ FLOAT ';'
      {
        if(currentScope->getVarType($1) != "float")
          cout << "ERROR: The left and right sides don't have the same type!\n";
        else
          std::cout<<"Assigning value " << $6 << ", in array "<< $1 << ", of type FLOAT, at position "<< $3<<std::endl;
      }
    | IDENTIFIER '[' INT ']' EQ STRING ';'
      {
        if(currentScope->getVarType($1) != "string")
          cout << "ERROR: The left and right sides don't have the same type!\n";
        else
          std::cout<<"Assigning value " << $6 << ", in array "<< $1 << ", of type STRING, at position "<< $3<<std::endl;
      }
    | IDENTIFIER '[' INT ']' EQ '?' IDENTIFIER '?' ';'
      {
        if(currentScope->getVarType($1) != "char")
          cout << "ERROR: The left and right sides don't have the same type!\n";
        else
          std::cout<<"Assigning value " << $7 << ", in array "<< $1 << ", of type CHAR, at position "<< $3<<std::endl;
      }
    | IDENTIFIER '[' INT ']' EQ BOOL ';'
      {
        if(currentScope->getVarType($1) != "bool")
          cout << "ERROR: The left and right sides don't have the same type!\n";
        else
          std::cout<<"Assigning value " << $6 << ", in array "<< $1 << ", of type BOOL, at position "<< $3<<std::endl;
      }
variable_declaration:
      TYPE IDENTIFIER EQ IDENTIFIER ';'
      {
        if(string($1) != currentScope->getVarType($4))
          cout << "ERROR: The left and right sides don't have the same type!\n";
        else if(currentScope->isDefinedInScope($2))
          cout << "ERROR: Variable " << $2 << " is already defined in this scope!\n";
        else if(!currentScope->isDefinedVar($4))
          std::cout << "ERROR: Variable " << $4 << " is not defined!" << endl;
        else
        {
          currentScope->addVar($1,$2, currentScope->getVarValue($4));
          std::cout << "Assigning value of variable \"" << $4 << "\" to variable \"" << $2 << "\"\n" ;
        }
               
      }
    
    | TYPE IDENTIFIER EQ STRING ';' 
      {
        if(string($1) != "string")
          cout << "ERROR: The left and right sides don't have the same type!\n";
        else if(currentScope->isDefinedInScope($2))
          cout << "ERROR: Variable " << $2 << " is already defined in this scope!\n";
        else
        {
          currentScope->addVar($1, $2, $4);
          std::cout << "Assigning value \"" << $4 << "\" to variable \"" << $2 << "\" of type \"" << $1 << "\"" << std::endl;
        }
        
      }
    | TYPE IDENTIFIER EQ INT ';' 
      {
        if(string($1) != "int")
          cout << "ERROR: The left and right sides don't have the same type!\n";
        else if(currentScope->isDefinedInScope($2))
          cout << "ERROR: Variable " << $2 << " is already defined in this scope!\n";
        else
        {
          currentScope->addVar($1, $2, to_string($4));
          std::cout << "Assigning value " << $4 << " to variable \"" << $2 << "\" of type \"" << $1 << "\"" << std::endl;
        }
      }
    | TYPE IDENTIFIER EQ FLOAT ';' 
      {
        if(string($1) != "float")
          cout << "ERROR: The left and right sides don't have the same type!\n";
        else if(currentScope->isDefinedInScope($2))
          cout << "ERROR: Variable " << $2 << " is already defined in this scope!\n";
        else
        {
          currentScope->addVar($1, $2, to_string($4));
          std::cout << "Assigning value " << $4 << " to variable \"" << $2 << "\" of type \"" << $1 << "\"" << std::endl;
        }
      }
    | TYPE IDENTIFIER EQ '?' IDENTIFIER '?' ';' 
      {
        if(string($1) != "char")
          cout << "ERROR: The left and right sides don't have the same type!\n";
        else if(currentScope->isDefinedInScope($2))
          cout << "ERROR: Variable " << $2 << " is already defined in this scope!\n";
        else
        {
          currentScope->addVar($1, $2, $5);
          std::cout << "Assigning value '" << $5 << "' to variable \"" << $2 << "\" of type \"" << $1 << "\"" << std::endl;
        }
      }
    | TYPE IDENTIFIER EQ BOOL ';' 
      {
        if(string($1) != "bool")
          cout << "ERROR: The left and right sides don't have the same type!\n";
        else if(currentScope->isDefinedInScope($2))
          cout << "ERROR: Variable " << $2 << " is already defined in this scope!\n";
        else
        {
          currentScope->addVar($1, $2, to_string($4));
          std::cout << "Assigning value '" << $4 << "' to variable \"" << $2 << "\" of type \"" << $1 << "\"" << std::endl;
        }
      }
    | TYPE IDENTIFIER ';' 
      {
        if(currentScope->isDefinedInScope($2))
          cout << "ERROR: Variable " << $2 << " is already defined in this scope!\n";
        else
        {
          currentScope->addVar($1, $2, "NULL");
          std::cout << "Declared variable \"" << $2 << "\" of type \"" << $1 << "\" without initialization" << std::endl;
        }
      }
    | error ';' {
        yyerrok; // Resetăm starea de eroare
        std::cerr << "Invalid statement. Skipping." << std::endl;
    }
    ;

%%

extern void yyrestart(FILE *input_file); 
extern int yyparse(); 

int main(int argc, char *argv[]) {
    if (argc != 2) { 
        cerr << "Usage: " << argv[0] << " <input_file>" << endl;
        return 1;
    }

    FILE *file = fopen(argv[1], "r"); 
    if (!file) {
        cerr << "Error: Could not open file " << argv[1] << endl;
        return 1;
    }

    

    yyrestart(file); 
    if (yyparse() != 0) { 
        cerr << "Syntax errors found in the file." << endl;
    }

    fclose(file); 
      cout<<"TEST!!!!!!"<<endl;
      FILE *file_ptr = fopen("SymbolTable.txt", "w");
    if (!file_ptr)
    {
        perror("Error opening file");
        return 1;
    }
        globalScope->printTable(file_ptr);
        std::cout << "Symbol table has been saved to 'symbol_table.txt'." << std::endl;

    delete globalScope;

    return 0;
}