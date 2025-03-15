#include <iostream>
using namespace std;

struct Node {
    Node *left;
    Node *right;
    string content; // 2-numar + -operator
    string type;
};

class AST {

    Node *root;

    public:
    AST();
    void AddNode(string content,Node*left,Node*right,string type);
    void printTree();
    string evaluateTree();
    
    ~AST();
};