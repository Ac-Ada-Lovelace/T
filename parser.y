%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <glib.h>
void yyerror(const char*);
#define YYSTYPE char *
int yylex(void);
#include "y.tab.h"

// 符号表
GHashTable *symbol_table;

const char* LastType = NULL;

void insertSymbol(const char *name, const char *type) {
    g_hash_table_insert(symbol_table, g_strdup(name), g_strdup(type));
    LastType = type;
}

const char* lookupSymbol(const char *name) {
    return g_hash_table_lookup(symbol_table, name);
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
    /* empty */             { /* empty */ }
|   Program FuncDecl        { /* empty */ }
;

FuncDecl:
    RetType FuncName '(' Args ')' '{' VarDecls Stmts '}'
                            { printf("ENDFUNC\n\n"); }
;

RetType:
    T_Int                   { /* empty */ }
|   T_Flt                   { /* empty */ }
|   T_Void                  { /* empty */ }
;

FuncName:
    T_Identifier            { printf("FUNC @%s:\n", $1); }
;

Args:
    /* empty */             { /* empty */ }
|   _Args                   { printf("\n\n"); }
;

_Args:
    T_Int T_Identifier      { printf("\targ %s", $2); }
|   _Args ',' T_Int T_Identifier
                            { printf(", %s", $4); }
|   T_Flt T_Identifier      { printf("\targ %s", $2); }
|   _Args ',' T_Flt T_Identifier
                            { printf(", %s", $4); }
;

VarDecls:
    /* empty */             { /* empty */ }
|   VarDecls VarDecl ';'    { printf("\n\n"); }
;


VarDecl:
    T_Int T_Identifier      {   
                                const char* exists = lookupSymbol($2);
                                if (exists) {
                                    fprintf(stderr ,"Error: %s already exists\n", $2);
                                    exit(1);
                                }
                                insertSymbol($2, "int");
                                printf("\tvar %s", $2);
                            }
|   T_Flt T_Identifier      {   
                                const char* exists = lookupSymbol($2);
                                if (exists) {
                                    fprintf(stderr ,"Error: %s already exists\n", $2);
                                    exit(1);
                                }
                                insertSymbol($2, "flt");
                                printf("\tvar %s", $2); }
|   VarDecl ',' T_Identifier
                            {   
                                const char* exists = lookupSymbol($3);
                                if (exists) {
                                    fprintf(stderr ,"Error: %s already exists\n", $3);
                                    exit(1);
                                }
                                printf(", %s", $3);
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
                            { printf("\tpop %s\n\n", $1); }
;

PrintStmt:
    T_Print '(' T_StringConstant PActuals ')' ';'
                            { printf("\tprint %s\n\n", $3); }
;

PActuals:
    /* empty */             { /* empty */ }
|   PActuals ',' Expr       { /* empty */ }
;

CallStmt:
    CallExpr ';'            { printf("\tpop\n\n"); }
;

CallExpr:
    T_Identifier '(' Actuals ')'
                            { printf("\t$%s\n", $1); }
;

Actuals:
    /* empty */             { /* empty */ }
|   Expr PActuals           { /* empty */ }
;

ReturnStmt:
    T_Return Expr ';'       { printf("\tret ~\n\n"); }
|   T_Return ';'            { printf("\tret\n\n"); }
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
    T_If            { _BEG_IF; printf("_begIf_%d:\n", _i); }
;

Then:
    /* empty */     { printf("\tjz _elIf_%d\n", _i); }
;

EndThen:
    /* empty */     { printf("\tjmp _endIf_%d\n_elIf_%d:\n", _i, _i); }
;

Else:
    T_Else          { /* empty */ }
;

EndIf:
    /* empty */     { printf("_endIf_%d:\n\n", _i); _END_IF; }
;

WhileStmt:
    While TestExpr Do StmtsBlock EndWhile
                    { /* empty */ }
;

While:
    T_While         { _BEG_WHILE; printf("_begWhile_%d:\n", _w); }
;

Do:
    /* empty */     { printf("\tjz _endWhile_%d\n", _w); }
;

EndWhile:
    /* empty */     { printf("\tjmp _begWhile_%d\n_endWhile_%d:\n\n", 
                                _w, _w); _END_WHILE; }
;

BreakStmt:
    T_Break ';'     { printf("\tjmp _endWhile_%d\n", _w); }
;

ContinueStmt:
    T_Continue ';'  { printf("\tjmp _begWhile_%d\n", _w); }
;

Expr:
    Expr '+' Expr           { printf("\tadd\n"); }
|   Expr '-' Expr           { printf("\tsub\n"); }
|   Expr '*' Expr           { printf("\tmul\n"); }
|   Expr '/' Expr           { printf("\tdiv\n"); }
|   Expr '%' Expr           { printf("\tmod\n"); }
|   Expr '>' Expr           { printf("\tcmpgt\n"); }
|   Expr '<' Expr           { printf("\tcmplt\n"); }
|   Expr T_Ge Expr          { printf("\tcmpge\n"); }
|   Expr T_Le Expr          { printf("\tcmple\n"); }
|   Expr T_Eq Expr          { printf("\tcmpeq\n"); }
|   Expr T_Ne Expr          { printf("\tcmpne\n"); }
|   Expr T_Or Expr          { printf("\tor\n"); }
|   Expr T_And Expr         { printf("\tand\n"); }
|   '-' Expr %prec '!'      { printf("\tneg\n"); }
|   '!' Expr                { printf("\tnot\n"); }
|   T_IntConstant           { printf("\tpush %s\n", $1); }
|   T_Identifier            { printf("\tpush %s\n", $1); }
|   T_FltConstant           { printf("\tpush %s\n", $1); }
|   ReadInt                 { /* empty */ }
|   CallExpr                { /* empty */ }
|   '(' Expr ')'            { /* empty */ }
;

ReadInt:
    T_ReadInt '(' T_StringConstant ')'
                            { printf("\treadint %s\n", $3); }
;

%%

int main() {
      symbol_table = g_hash_table_new_full(g_str_hash, g_str_equal, g_free, g_free);
    yyparse();
    g_hash_table_destroy(symbol_table);
    return 0;
}
