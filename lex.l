%{
    #include <stdio.h>
	#include <stdlib.h> 
	int count = 1;
%} 
%option yylineno

whitespace [ \t]+
enter \n
type int|float
identifier [a-zA-Z_][a-zA-Z0-9_]*
bin_integer (-|\+)?0b(0|1[0-1]*)
oct_integer (-|\+)?0(0|[1-7][0-7]*)
hex_integer (-|\+)?0x(0|(([1-9]|[a-f])([0-9]|[a-f])*))
dec_integer (-|\+)?0|([1-9][0-9]*)
floating_num (-|\+)?[0-9]+\.[0-9]+[E|e]?(-)?[1-9]?[0-9]*
integer {bin_integer}|{hex_integer}|{oct_integer}|{dec_integer}
easy break|continue
relop >=|==|<=|=
note \/\/.*

%%

{type} {
	return TYPE;
}
{note}	{}

{integer}	{return INT;}

floating_num return FLOAT;

while return WHILE;

easy return EASY;

for return FOR;

if return IF;

else return ELSE;

return return RETURN;

void return VOID;

main return MAIN;

; return SEMI;

= return ASSIGNOP;

{relop} return RELOP;

"+" return PLUS;

"-" return MINUS;

"*" return STAR;

"/" return DIV;

"(" return LP;

")" return RP;

"{" return LC;

"}" return RC;

{whitespace} {

}

{enter} {
	count++;	
}

{identifier} {return ID;}

. {
	printf("line %d error未识别符号：%s\n", count, yytext);
}

%% 
 
int yywrap() 
{ 
	return 1; 
}

