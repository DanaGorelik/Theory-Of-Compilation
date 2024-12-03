#include "tokens.hpp"
#include "output.hpp"
#include <iostream>
#include <sstream>
#include <string.h>
#include <string>
using namespace std;

void handleHexaMode();
void addLexemaToResultString();
void handleEscapeMode();
void handleUndefinedEscape(bool isHexa, int numCharsToGoBack, int lenToPrint);

string result_string;

int main() {
    enum tokentype token;

    while ((token = static_cast<tokentype>(yylex())))
    {
        if(token == STRING){
            string copy(result_string);
            result_string = "";
            output::printToken(yylineno, token, copy.c_str());
        }
        else{
            output::printToken(yylineno, token, yytext);
        }
    }
    return 0;
}

void handleHexaMode(){
    int hex_val = stoul(yytext, nullptr, 16);
    char str_val = static_cast<char>(hex_val);   
    result_string += str_val;
}

void handleEscapeMode(){
    switch(yytext[(int)strlen(yytext)-1])
    {
        case 'n': result_string += '\n'; break;
        case 't': result_string += '\t'; break;
        case 'r': result_string += '\r'; break;
        case '"': result_string += '\"'; break;
        case '\\': result_string += '\\'; break;
        case '0': result_string += '\0'; break;
    }
            
}

void addLexemaToResultString(){
    result_string += string(yytext);
}

void handleUndefinedEscape(bool isHexa, int numCharsToGoBack, int lenToPrint){
    string result(yytext), sequence="";
    int startIndex = result.length()-numCharsToGoBack;
    if(isHexa)
    {
        sequence = "x";
        if(numCharsToGoBack == 1){
            sequence += result.substr(startIndex, 1);
        }
        else if(numCharsToGoBack == 2){
            if(lenToPrint == 1){
                sequence += result.substr(startIndex, 1);
            }
            else if(lenToPrint == 2){
                sequence += result.substr(startIndex, 2);
            }
        }
    }
    else
    {
        sequence = result.substr(startIndex, 1);
    }
    output::errorUndefinedEscape(sequence.c_str());
}