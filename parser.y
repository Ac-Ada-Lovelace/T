%{
#include <iostream>
#include <cstdlib>
#include <cstring>
#include <unordered_map>
void yyerror(const char*);
#define YYSTYPE char *
int yylex(void);
#include "y.tab.h"

// 符号表
std::unordered_map<std::string, std::string> symbol_table;

std::stack<std::unordered_map<std::string, std::string>> symbol_table_stack;

void enterScope() {
    symbol_table_stack.push(std::unordered_map<std::string, std::string>());
}

void exitScope() {
    if (!symbol_table_stack.empty()) {
        symbol_table_stack.pop();
    }
}


const char* LastType = NULL;

void insertSymbol(const char *name, const char *type) {
    symbol_table[name] = type;
    LastType = type;
}

const char* lookupSymbol(const char *name) {
    auto it = symbol_table.find(name);
    if (it != symbol_table.end()) {
        return it->second.c_str();
    }
    return NULL;
}

const char* getSymbolType(const char *name) {
    return lookupSymbol(name);
}

const char* isSymbolInt(const char *name) {
    return strcmp(lookupSymbol(name), "int") == 0 ? "int" : NULL;
}

const char* isSymbolFlt(const char *name) {
    return strcmp(lookupSymbol(name), "flt") == 0 ? "flt" : NULL;
}

int ii = 0, itop = -1, istack[100];
int ww = 0, wtop = -1, wstack[100];

#define _BEG_IF     {istack[++itop] = ++ii;}
#define _END_IF     {itop--;}
#define _i          (istack[itop])

#define _BEG_WHILE  {wstack[++wtop] = ++ww;}
#define _END_WHILE  {wtop--;}
#define _w          (wstack[wtop])

%}

%token T_Int T_Void T_Flt T_Return T_Print T_ReadInt T_While
%token T_If T_Else T_Break T_Continue T_Le T_Ge T_Eq T_Ne
%token T_And T_Or T_IntConstant T_FltConstant T_StringConstant T_Identifier

%left '='
%left T_Or
%left T_And
%left T_Eq T_Ne
%left '<' '>' T_Le T_Ge
%left '+' '-'
%left '*' '/' '%'
%left '!'


%%

Program:
    /* empty */             { enterScope(); }
|   Program FuncDecl        { exitScope(); }
;

FuncDecl:
    RetType FuncName '(' Args ')' '{' VarDecls Stmts '}'
                            { std::cout << "ENDFUNC\n\n"; }
;

RetType:
    T_Int                   { /* empty */ }
|   T_Flt                   { /* empty */ }
|   T_Void                  { /* empty */ }
;

FuncName:
    T_Identifier            { std::cout << "FUNC @" << $1 << ":\n"; }
;

Args:
    /* empty */             { /* empty */ }
|   _Args                   { std::cout << "\n\n"; }
;

_Args:
    T_Int T_Identifier      { std::cout << "\targ " << $2; }
|   _Args ',' T_Int T_Identifier
                            { std::cout << ", " << $4; }
|   T_Flt T_Identifier      { std::cout << "\targ " << $2; }
|   _Args ',' T_Flt T_Identifier
                            { std::cout << ", " << $4; }
;

VarDecls:
    /* empty */             { /* empty */ }
|   VarDecls VarDecl ';'    { std::cout << "\n\n"; }
;

VarDecl:
    T_Int T_Identifier      {
                                const char* exists = lookupSymbol($2);
                                if (exists) {
                                    std::cerr << "Error: " << $2 << " already exists\n";
                                    exit(1);
                                }
                                insertSymbol($2, "int");
                                std::cout << "\tvar " << $2;
                            }
|   T_Flt T_Identifier      {
                                const char* exists = lookupSymbol($2);
                                if (exists) {
                                    std::cerr << "Error: " << $2 << " already exists\n";
                                    exit(1);
                                }
                                insertSymbol($2, "flt");
                                std::cout << "\tvar " << $2;
                            }
|   VarDecl ',' T_Identifier {
                                const char* exists = lookupSymbol($3);
                                if (exists) {
                                    std::cerr << "Error: " << $3 << " already exists\n";
                                    exit(1);
                                }
                                insertSymbol($3, LastType);
                                std::cout << ", " << $3;
                            }
;

Stmts:
    /* empty */             { /* empty */ }
|   Stmts Stmt              { /* empty */ }
;

Stmt:
    AssignStmt              { /* empty */ }
|   PrintStmt               { /* empty */ }
|   CallStmt                { /* empty */ }
|   ReturnStmt              { /* empty */ }
|   IfStmt                  { /* empty */ }
|   WhileStmt               { /* empty */ }
|   BreakStmt               { /* empty */ }
|   ContinueStmt            { /* empty */ }
;

AssignStmt:
    T_Identifier '=' Expr ';'
                            { std::cout << "\tpop " << $1 << "\n\n"; }
;

PrintStmt:
    T_Print '(' T_StringConstant PActuals ')' ';'
                            { std::cout << "\tprint " << $3 << "\n\n"; }
;

PActuals:
    /* empty */             { /* empty */ }
|   PActuals ',' Expr       { /* empty */ }
;

CallStmt:
    CallExpr ';'            { std::cout << "\tpop\n\n"; }
;

CallExpr:
    T_Identifier '(' Actuals ')'
                            { std::cout << "\t$" << $1 << "\n"; }
;

Actuals:
    /* empty */             { /* empty */ }
|   Expr PActuals           { /* empty */ }
;

ReturnStmt:
    T_Return Expr ';'       { std::cout << "\tret ~\n\n"; }
|   T_Return ';'            { std::cout << "\tret\n\n"; }
;

IfStmt:
    If TestExpr Then StmtsBlock EndThen EndIf
                            { /* empty */ }
|   If TestExpr Then StmtsBlock EndThen Else StmtsBlock EndIf
                            { /* empty */ }
;

TestExpr:
    '(' Expr ')'            { /* empty */ }
;

StmtsBlock:
    '{' Stmts '}'           { /* empty */ }
;

If:
    T_If            { _BEG_IF; std::cout << "_begIf_" << _i << ":\n"; }
;

Then:
    /* empty */     { std::cout << "\tjz _elIf_" << _i << "\n"; }
;

EndThen:
    /* empty */     { std::cout << "\tjmp _endIf_" << _i << "\n_elIf_" << _i << ":\n"; }
;

Else:
    T_Else          { enterScope(); }
;

EndIf:
    /* empty */     { std::cout << "_endIf_" << _i << ":\n\n"; _END_IF; }
;

WhileStmt:
    While TestExpr Do StmtsBlock EndWhile
                    { /* empty */ }
;

While:
    T_While         { _BEG_WHILE; std::cout << "_begWhile_" << _w << ":\n"; }
;

Do:
    /* empty */     { std::cout << "\tjz _endWhile_" << _w << "\n"; }
;

EndWhile:
    /* empty */     { std::cout << "\tjmp _begWhile_" << _w << "\n_endWhile_" << _w << ":\n\n"; _END_WHILE; }
;

BreakStmt:
    T_Break ';'     { std::cout << "\tjmp _endWhile_" << _w << "\n"; }
;

ContinueStmt:
    T_Continue ';'  { std::cout << "\tjmp _begWhile_" << _w << "\n"; }
;

Expr:
    Expr '+' Expr           { std::cout << "\tadd\n"; }
|   Expr '-' Expr           { std::cout << "\tsub\n"; }
|   Expr '*' Expr           { std::cout << "\tmul\n"; }
|   Expr '/' Expr           { std::cout << "\tdiv\n"; }
|   Expr '%' Expr           { std::cout << "\tmod\n"; }
|   Expr '>' Expr           { std::cout << "\tcmpgt\n"; }
|   Expr '<' Expr           { std::cout << "\tcmplt\n"; }
|   Expr T_Ge Expr          { std::cout << "\tcmpge\n"; }
|   Expr T_Le Expr          { std::cout << "\tcmple\n"; }
|   Expr T_Eq Expr          { std::cout << "\tcmpeq\n"; }
|   Expr T_Ne Expr          { std::cout << "\tcmpne\n"; }
|   Expr T_Or Expr          { std::cout << "\tor\n"; }
|   Expr T_And Expr         { std::cout << "\tand\n"; }
|   '-' Expr %prec '!'      { std::cout << "\tneg\n"; }
|   '!' Expr                { std::cout << "\tnot\n"; }
|   T_IntConstant           {
                                
                                std::cout << "; T_IntConstant: " << $1  << "\n";
                                std::cout << "\tpush " << $1 << "\n"; 
                            }
|   T_FltConstant           { 
                                std::cout << "; T_FltConstant: " << $1 << "\n";
                                std::cout << "\tpushf " << $1 << "\n"; 
                            }
|   T_Identifier            { 
                                std::cout << "; T_Identifier: " << $1 << "Type: " << getSymbolType($1) << "\n";
                                std::cout << "\tpush " << $1 << "\n";
                            }
|   ReadInt                 { /* empty */ }
|   CallExpr                { /* empty */ }
|   '(' Expr ')'            { /* empty */ }
;

ReadInt:
    T_ReadInt '(' T_StringConstant ')'
                            { std::cout << "\treadint " << $3 << "\n"; }
;

%%

int main() {
    enterScope();

    symbol_table.clear();
    yyparse();

    while(!symbol_table_stack.empty()) {
        symbol_table_stack.pop();
    }

    return 0;
}