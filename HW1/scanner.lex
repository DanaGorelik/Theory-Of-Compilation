%{
    #include <stdio.h>
    #include "output.hpp"
    #include "tokens.hpp"
    void handleHexaMode();
    void addLexemaToResultString();
    void handleEscapeMode();
    void handleUndefinedEscape(bool isHexa, int numCharsToGoBack, int lenToPrint);
%}

%option yylineno
%option noyywrap

%x STR
%x HEXA
%x BACKSLASH

digit ([0-9])
letter ([a-zA-Z])
whitespace ([\t\n\r ])
vaild_chars ([ !#-\[\]-~ ])
quote (\")
whitespaceHexa (09|20|0D|0A|0d|0a)

%%

void                                                      {return VOID;}
int                                                       {return INT;}
byte                                                      {return BYTE;}
bool                                                      {return BOOL;}
and                                                       {return AND;}
or                                                        {return OR;}
not                                                       {return NOT;}
true                                                      {return TRUE;}
false                                                     {return FALSE;}
return                                                    {return RETURN;}
if                                                        {return IF;}
else                                                      {return ELSE;}
while                                                     {return WHILE;}
break                                                     {return BREAK;}
continue                                                  {return CONTINUE;}
;                                                         {return SC;}
,                                                         {return COMMA;}
\(                                                        {return LPAREN;}
\)                                                        {return RPAREN;}
\{                                                        {return LBRACE;}
\}                                                        {return RBRACE;}
=                                                         {return ASSIGN;}
!=|<=|>=|<|>|==                                           {return RELOP;}
[+\-\/*]                                                  {return BINOP;}
\/\/[^\n\r]*                                              {return COMMENT;}
{letter}[a-zA-Z0-9]*                                      {return ID;}
0|[1-9]{digit}*                                           {return NUM;}
0b|[1-9]{digit}*b                                         {return NUM_B;}
{quote}                                                   {BEGIN(STR);}                                                                                                                                                                                              
<STR>{vaild_chars}*                                       {addLexemaToResultString();}
<STR>\\[nrt0\"\\]                                         {handleEscapeMode();}           
<STR>\n|\r|\r\n                                           {output::errorUnclosedString();}  
<STR><<EOF>>                                              {output::errorUnclosedString();}        
<STR>{quote}                                              {BEGIN(INITIAL); return STRING;}
<STR>\\                                                   {BEGIN(BACKSLASH);}
<BACKSLASH>x                                              {BEGIN(HEXA);}
<BACKSLASH>[^nrt0\"\\]                                    {BEGIN(INITIAL); handleUndefinedEscape(false, 1, 1);}
<HEXA>([2-6][0-9A-Fa-f]|7[0-9A-Ea-e]|{whitespaceHexa})    {handleHexaMode(); BEGIN(STR);}
<HEXA>{quote}                                             {BEGIN(INITIAL); handleUndefinedEscape(true, 0, 0);}
<HEXA>.{quote}                                            {BEGIN(INITIAL); handleUndefinedEscape(true, 2, 1);}
<HEXA>..                                                  {BEGIN(INITIAL); handleUndefinedEscape(true, 2, 2);}
<HEXA>.                                                   {BEGIN(INITIAL); handleUndefinedEscape(true, 1, 1);}
{whitespace}                                              ;
.                                                         {output::errorUnknownChar(yytext[0]);}

%%
