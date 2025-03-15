%{
#include "y.tab.h"
#include <string>
#include <iostream>
#include <cstring>
%}
%option noyywrap
%%
"int"|"float"|"bool"|"char"|"string" {
    yylval.string = strdup(yytext);
    return TYPE;
}
"%begin class" return CLASS_BEGIN;
"%end class"   return CLASS_END;
"%begin variables" return VAR_BEGIN;
"%end variables"   return VAR_END;
"%begin functions" return FUNC_BEGIN;
"%end functions"   return FUNC_END;
"%begin main" return MAIN_BEGIN;
"%end main"   return MAIN_END;
"obiecte"          return CLASS;
"method"       return METHOD;
"new"          return NEW;
"if"           return IF;
"while"        return WHILE;
"for"          return FOR ;
"="            return EQ;
"!="           return NEQ;
"<"            return LT;
">"            return GT;
">="           return GEQ;
"<="           return LEQ;
"--"           return MINUSMINUS;
"++"           return PLUSPLUS;
"=="           return EQEQ;
"&&"            { return AND; }
"||"            { return OR; }
"!"             { return NOT; }
"true"  { yylval.boolean = true; return BOOL; }
"false" { yylval.boolean = false; return BOOL; }
"Print"     { return PRINT;}
"TypeOf"    { return TYPEOF;}
\"[0-9a-zA-Z ]*\" { yylval.string = strdup(yytext); return STRING; }
[a-zA-Z_][a-zA-Z0-9_]* {
    yylval.string = strdup(yytext);
    return IDENTIFIER;
}
[1-9]+[1-9]*[.][0-9]+[0-9]* {    yylval.floating = atof(yytext);return FLOAT;}
[0].[0-9]+[0-9]* {   yylval.floating = atof(yytext);return FLOAT;}
[1-9][0-9]* { yylval.integer = atoi(yytext); return INT; }
0 { yylval.integer = 0; return INT; } 

[ \t] ;
\n {yylineno++;}

. {
    return yytext[0];
}

%%
