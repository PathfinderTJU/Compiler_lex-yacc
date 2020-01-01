rm lex.yy.c a.out y.tab.c
lex lex.l
yacc yacc.y
gcc -o compiler y.tab.c -ll
