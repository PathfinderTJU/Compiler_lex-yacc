%{
#include <stdio.h>
#include <math.h>
#include <malloc.h>
#include <stdlib.h>

extern FILE *fp;
extern int yylineno;

//树节点
typedef struct TreeNode{
    int type;
    int length;
    struct TreeNode* leaves[9];
    char* data;
}TreeNode, *Tree;

//链表节点
typedef struct ListNode{
    struct TreeNode* data;
    struct ListNode* next;
}ListNode, *LinkList;

//报错函数
void yyerror(const char* msg)
{
    printf("Error: %s 行号:%d\n", msg, yylineno);
}

//创建链表头节点（指向第一个节点）
LinkList createLinkList(){
    ListNode* L = (ListNode*)malloc(sizeof(ListNode));
    if ( L == NULL ){
        exit(-1);
    }
    L -> next = NULL;
    return L;
}

//链表头插入节点
LinkList linkListInset(LinkList L, TreeNode* newNode){
    ListNode* temp = (ListNode*)malloc(sizeof(ListNode));
    if ( temp == NULL ){
        exit(-1);
    }
    temp -> data = newNode;
    temp -> next = L -> next;
    L -> next = temp;
    return L;
}

//创建叶子节点
Tree createLeaf(char* rootData){
	int i = 0;
    Tree T = (Tree)malloc(sizeof(TreeNode));
    if (T != NULL){
        T -> type = 1;
        T -> data = rootData;
        T -> length = 0;
		for (i = 0 ; i < 9 ; i++){
			T -> leaves[i] = NULL;		
		}
    }else{
        exit(-1);
    }
    return T;
}

//链接叶子节点和根节点
Tree createTree(char* root, TreeNode** leaves, int length){
	int i = 0;
    Tree T = (Tree)malloc(sizeof(TreeNode));
    if (T == NULL){
        exit(-1);
    }else{
        T -> type = 0;
        T -> data = root;
        T -> length = length;
        for (i = 0 ; i < 9 ; i++){
			T -> leaves[i] = leaves[i];
		}
    }
}


//后序遍历
void traverseTree(Tree T, int level){
	int i = 0;
    if (T == NULL){
        return;
    }else{
        if (T -> type == 1){
            if (T -> data != ""){
                for ( i = 0 ; i < level ; i++){
                    printf("%-4s", " ");
                }
                printf("%d: %s\n", level, T -> data);
            }
        }else{
            for (i = 0 ; i < T -> length ; i++){
                traverseTree(T -> leaves[i], level + 1);
            }
            if (T -> data != ""){
                for ( i = 0 ; i < level ; i++){
                    printf("%-4s", " ");
                }
                printf("%d: %s\n", level, T -> data);
            }
        }
    } 
}

//为child分配内存空间
void alloc(TreeNode** child){
	int i;
	for (i = 0 ; i < 9 ; i++){
		child[i] = (TreeNode*)malloc(sizeof(TreeNode));
        if(child[i] == NULL){
            exit(-1);
        }
	}
}

LinkList list = NULL;
LinkList head = NULL;
Tree T;
TreeNode* child[9];
int level = 0;

%}

%token INT FLOAT ID SEMI ASSIGNOP RELOP PLUS MINUS STAR DIV 
%token LP RP LC RC WHILE ELSE IF RETURN TYPE VOID MAIN EASY FOR


%left DIV STAR
%left MINUS PLUS
%left RELOP 
%right ASSIGNOP
%left LP RP

%%
Program: ExtDefList {   printf("Program -> ExtDefList\n");
                        head = list -> next;
                        alloc(child);
                        child[0] = head -> data;
                        T = createTree("Program", child, 1);
                        list -> next = head -> next;
                        linkListInset(list, T);
                        head = list -> next;
                        T = head -> data;
                        printf("Traverse Tree: \n");
                        level = 0;
                        traverseTree(T, level);
                        printf("------------------Tree End.--------------\n");   }
;

ExtDefList: ExtDef ExtDefList  {   printf("ExtDefList -> ExtDef ExtDefList\n");
                                head = list -> next;
								alloc(child);
                                child[0] = (head->next) -> data;
                                child[1] = head -> data;
                                T = createTree("ExtDefList", child, 2);
                                list -> next = (head -> next) -> next;
                                linkListInset(list, T);}
| {   printf("ExtDefList -> EPSILON\n");
    head = list -> next;
    alloc(child);
    child[0] = createLeaf("");
    T = createTree("ExtDefList", child, 1);
    linkListInset(list, T);}
;

ExtDef: Specifier Dec SEMI {   printf("ExtDef -> Specifier Dec SEMI\n");
                                head = list -> next;
                                alloc(child);
                                child[0] = (head->next) -> data;
                                child[1] = head -> data;
                                child[2] = createLeaf("SEMI");
                                T = createTree("ExtDef", child, 3);
                                list -> next = (head -> next) -> next;
                                linkListInset(list, T);}
        | Specifier FunDec CompSt {   printf("ExtDef -> Specifier FunDec CompSt\n");
                                head = list -> next;
                                alloc(child);
                                child[0] = ((head->next) -> next) -> data;
                                child[1] = (head->next) -> data;
                                child[2] = head -> data;
                                T = createTree("ExtDef", child, 3);
                                list -> next = ((head -> next) -> next) -> next;
                                linkListInset(list, T);}
        | VOID FunDec CompSt {   printf("ExtDef -> VOID FunDec CompSt\n");
                                head = list -> next;
                                alloc(child);
                                child[0] = createLeaf("void");
                                child[1] = (head->next) -> data;
                                child[2] = head -> data;
                                T = createTree("ExtDef", child, 3);
                                list -> next = (head -> next) -> next;
                                linkListInset(list, T);}
;

Specifier: TYPE {     printf("Specifier -> TYPE\n");
                    head = list -> next;
                    alloc(child);
                    child[0] = createLeaf("TYPE");
                    T = createTree("Specifier", child, 1);
                    linkListInset(list, T);}
;


VarDec: ID {     printf("VarDec -> ID\n");
                head = list -> next;
                alloc(child);
                child[0] = createLeaf("ID");
                T = createTree("VarDec", child, 1);
                linkListInset(list, T);}
;

FunDec: ID LP VarList RP {   printf("FunDec -> ID LP VarList RP\n");
                            head = list -> next;
                            alloc(child);
                            child[0] = createLeaf("ID");
                            child[1] = createLeaf("LP");
                            child[2] = head -> data;
                            child[3] = createLeaf("RP");
                            T = createTree("FunDec", child, 4);
                            list -> next = head -> next;
                            linkListInset(list, T);}
        | ID LP RP {          printf("FunDec -> ID LP RP\n");
                            head = list -> next;
                            alloc(child);
                            child[0] = createLeaf("ID");
                            child[1] = createLeaf("LP");
                            child[2] = createLeaf("RP");
                            T = createTree("FunDec", child, 3);
                            linkListInset(list, T);}
        | MAIN LP RP {        printf("FunDec -> MAIN LP RP\n");
                            head = list -> next;
                            alloc(child);
                            child[0] = createLeaf("MAIN");
                            child[1] = createLeaf("LP");
                            child[2] = createLeaf("RP");
                            T = createTree("FunDec", child, 3);
                            linkListInset(list, T);}
        ;

VarList: ParamDec {       printf("VarList -> ParamDec\n");
                        head = list -> next;
                        alloc(child);
                        child[0] = head -> data;
                        T = createTree("VarList", child, 1);
                        list -> next = head -> next;
                        linkListInset(list, T);}
        ;

ParamDec: Specifier VarDec {       printf("ParamDec -> Specifier VarDec\n");
                                head = list -> next;
                                alloc(child);
                                child[0] = (head -> next) -> data;
                                child[1] = head -> data;
                                T = createTree("ParamDec", child, 2);
                                list -> next = (head -> next) -> next;
                                linkListInset(list, T);}
          ;

CompSt: LC DeflistAndStmtList RC {       printf("CompSt -> LC DeflistAndStmtList RC\n");
                                        head = list -> next;
                                        alloc(child);
                                        child[0] = createLeaf("LC");
                                        child[1] = head -> data;
                                        child[2] = createLeaf("RC");
                                        T = createTree("ParamDec", child, 3);
                                        list -> next = head -> next;
                                        linkListInset(list, T);}
        ;

DeflistAndStmtList: Def DeflistAndStmtList {       printf("DeflistAndStmtList -> Def DeflistAndStmtList\n");
                                                head = list -> next;
                                                alloc(child);
                                                child[0] = (head -> next) -> data;
                                                child[1] = head -> data;
                                                T = createTree("DeflistAndStmtList", child, 2);
                                                list -> next = (head -> next) -> next;
                                                linkListInset(list, T);}
                    | Stmt DeflistAndStmtList {       printf("DeflistAndStmtList -> Stmt DeflistAndStmtList\n");
                                                head = list -> next;
                                                alloc(child);
                                                child[0] = (head -> next) -> data;
                                                child[1] = head -> data;
                                                T = createTree("DeflistAndStmtList", child, 2);
                                                list -> next = (head -> next) -> next;
                                                linkListInset(list, T);}
                    | {   printf("DeflistAndStmtList -> EPSILON\n");
                        head = list -> next;
                        alloc(child);
                        child[0] = createLeaf("");
                        T = createTree("DeflistAndStmtList", child, 1);
                        linkListInset(list, T);}
                    ;

Stmt: Exp SEMI {       printf("Stmt -> Exp SEMI\n");
                    head = list -> next;
                    alloc(child);
                    child[0] = head -> data;
                    child[1] = createLeaf("SEMI");
                    T = createTree("Stmt", child, 2);
                    list -> next = head -> next;
                    linkListInset(list, T);}
      | CompSt {       printf("Stmt -> CompSt\n");
                    head = list -> next;
                    alloc(child);
                    child[0] = head -> data;
                    T = createTree("Stmt", child, 1);
                    list -> next = head -> next;
                    linkListInset(list, T);}
      | RETURN Exp SEMI {       printf("Stmt -> RETURN Exp SEMI\n");
                            head = list -> next;
                            alloc(child);
                            child[0] = createLeaf("RETURN");
                            child[1] = head -> data;
                            child[2] = createLeaf("SEMI");
                            T = createTree("Stmt", child, 3);
                            list -> next = head -> next;
                            linkListInset(list, T);}
      | IF LP Exp RP Stmt {       printf("Stmt -> IF LP Exp RP Stmt\n");
                            head = list -> next;
                            alloc(child);
                            child[0] = createLeaf("IF");
                            child[1] = createLeaf("LP");
                            child[2] = (head -> next) -> data;
                            child[3] = createLeaf("RP");
                            child[4] = head -> data;
                            T = createTree("Stmt", child, 5);
                            list -> next = (head -> next) -> next;
                            linkListInset(list, T);}
      | IF LP Exp RP Stmt ELSE Stmt {       printf("Stmt -> IF LP Exp RP Stmt ELSE Stmt\n");
                                        head = list -> next;
                                        alloc(child);
                                        child[0] = createLeaf("IF");
                                        child[1] = createLeaf("LP");
                                        child[2] = ((head -> next) -> next) -> data;
                                        child[3] = createLeaf("RP");
                                        child[4] = (head -> next) -> data;
                                        child[5] = createLeaf("ELSE");
                                        child[6] = head -> data;
                                        T = createTree("Stmt", child, 7);
                                        list -> next = ((head -> next) -> next) -> next;
                                        linkListInset(list, T);}
      | WHILE LP Exp RP Stmt {        printf("Stmt -> WHILE LP Exp RP Stmt\n");
                                    head = list -> next;
                                    alloc(child);
                                    child[0] = createLeaf("WHILE");
                                    child[1] = createLeaf("LP");
                                    child[2] = (head -> next) -> data;
                                    child[3] = createLeaf("RP");
                                    child[4] = head -> data;
                                    T = createTree("Stmt", child, 5);
                                    list -> next = (head -> next) -> next;
                                    linkListInset(list, T);}
      | FOR LP Exp SEMI Exp SEMI Exp RP Stmt {    printf("Stmt -> FOR LP Exp SEMI Exp SEMI Exp RP Stmt\n");
                                                head = list -> next;
                                                alloc(child);
                                                child[0] = createLeaf("FOR");
                                                child[1] = createLeaf("LP");
                                                child[2] = (((head -> next) -> next) -> next) -> data;
                                                child[3] = createLeaf("SEMI");
                                                child[4] = ((head -> next) -> next) -> data;
                                                child[5] = createLeaf("SEMI");
                                                child[6] = (head -> next) -> data;
                                                child[7] = createLeaf("RP");
                                                child[8] = head -> data;
                                                T = createTree("Stmt", child, 9);
                                                list -> next = (((head -> next) -> next) -> next) -> next;
                                                linkListInset(list, T);}
      | FOR LP SEMI Exp SEMI Exp RP Stmt {    printf("Stmt -> FOR LP SEMI Exp SEMI Exp RP Stmt\n");
                                            head = list -> next;
                                            alloc(child);
                                            child[0] = createLeaf("FOR");
                                            child[1] = createLeaf("LP");
                                            child[2] = createLeaf("SEMI");
                                            child[3] = ((head -> next) -> next) -> data;
                                            child[4] = createLeaf("SEMI");
                                            child[5] = (head -> next) -> data;
                                            child[6] = createLeaf("RP");
                                            child[7] = head -> data;
                                            T = createTree("Stmt", child, 8);
                                            list -> next = ((head -> next) -> next) -> next;
                                            linkListInset(list, T);}
      | FOR LP Exp SEMI SEMI Exp RP Stmt {    printf("Stmt -> FOR LP Exp SEMI SEMI Exp RP Stmt\n");
                                            head = list -> next;
                                            alloc(child);
                                            child[0] = createLeaf("FOR");
                                            child[1] = createLeaf("LP");
                                            child[2] = ((head -> next) -> next) -> data;
                                            child[3] = createLeaf("SEMI");
                                            child[4] = createLeaf("SEMI");
                                            child[5] = (head -> next) -> data;
                                            child[6] = createLeaf("RP");
                                            child[7] = head -> data;
                                            T = createTree("Stmt", child, 8);
                                            list -> next = ((head -> next) -> next) -> next;
                                            linkListInset(list, T);}
      | FOR LP Exp SEMI Exp SEMI RP Stmt {    printf("Stmt -> FOR LP Exp SEMI Exp SEMI RP Stmt\n");
                                            head = list -> next;
                                            alloc(child);
                                            child[0] = createLeaf("FOR");
                                            child[1] = createLeaf("LP");
                                            child[2] = ((head -> next) -> next) -> data;
                                            child[3] = createLeaf("SEMI");
                                            child[4] = (head -> next) -> data;
                                            child[5] = createLeaf("SEMI");
                                            child[6] = createLeaf("RP");
                                            child[7] = head -> data;
                                            T = createTree("Stmt", child, 8);
                                            list -> next = ((head -> next) -> next) -> next;
                                            linkListInset(list, T);}
      | FOR LP SEMI Exp SEMI RP Stmt  {       printf("Stmt -> FOR LP SEMI Exp SEMI RP Stmt\n");
                                            head = list -> next;
                                            alloc(child);
                                            child[0] = createLeaf("FOR");
                                            child[1] = createLeaf("LP");
                                            child[2] = createLeaf("SEMI");
                                            child[3] = (head -> next) -> data;
                                            child[4] = createLeaf("SEMI");
                                            child[5] = createLeaf("RP");
                                            child[6] = head -> data;
                                            T = createTree("Stmt", child, 7);
                                            list -> next = (head -> next) -> next;
                                            linkListInset(list, T);}
      | FOR LP SEMI SEMI RP Stmt {       printf("Stmt -> FOR LP SEMI SEMI RP Stmt\n");
                                        head = list -> next;
                                        alloc(child);
                                        child[0] = createLeaf("FOR");
                                        child[1] = createLeaf("LP");
                                        child[2] = createLeaf("SEMI");
                                        child[3] = createLeaf("SEMI");
                                        child[4] = createLeaf("RP");
                                        child[5] = head -> data;
                                        T = createTree("Stmt", child, 6);
                                        list -> next = head -> next;
                                        linkListInset(list, T);}
      | EASY SEMI {       printf("Stmt -> EASY SEMI\n");
                        head = list -> next;
                        alloc(child);
                        child[0] = createLeaf("FOR");
                        child[1] = createLeaf("LP");
                        child[2] = createLeaf("SEMI");
                        child[3] = createLeaf("SEMI");
                        child[4] = createLeaf("RP");
                        child[5] = head -> data;
                        T = createTree("Stmt", child, 6);
                        linkListInset(list, T);}

Def: Specifier Dec SEMI {     printf("Def -> Specifier DecList SEMI\n");
                                head = list -> next;
                                alloc(child);
                                child[0] = (head -> next) -> data;
                                child[1] = head -> data;
                                child[2] = createLeaf("SEMI");
                                T = createTree("Def", child, 3);
                                list -> next = (head -> next) -> next;
                                linkListInset(list, T);}
;

Dec: VarDec {     printf("Dec -> VarDec\n");
                head = list -> next;
                alloc(child);
                child[0] = head -> data;
                T = createTree("Dec", child, 1);
                list -> next = head -> next;
                linkListInset(list, T);}
     | VarDec ASSIGNOP Exp {     printf("Dec -> VarDec ASSIGNOP Exp\n");
                                head = list -> next;
                                alloc(child);
                                child[0] = (head -> next) -> data;
                                child[1] = createLeaf("ASSIGNOP");
                                child[2] = head -> data;
                                T = createTree("Dec", child, 3);
                                list -> next = (head -> next) -> next;
                                linkListInset(list, T);}
    ;

Exp: Exp ASSIGNOP Exp {       printf("Exp -> Exp ASSIGNOP Exp\n");
                            head = list -> next;
                            alloc(child);
                            child[0] = (head -> next) -> data;
                            child[1] = createLeaf("ASSIGNOP");
                            child[2] = head -> data;
                            T = createTree("Exp", child, 3);
                            list -> next = (head -> next) -> next;
                            linkListInset(list, T);}
    | Exp RELOP Exp {     printf("Exp -> Exp RELOP Exp\n");
                        head = list -> next;
                        alloc(child);
                        child[0] = (head -> next) -> data;
                        child[1] = createLeaf("RELOP");
                        child[2] = head -> data;
                        T = createTree("Exp", child, 3);
                        list -> next = (head -> next) -> next;
                        linkListInset(list, T);}
    | Exp PLUS Exp {      printf("Exp -> Exp PLUS Exp\n");
                        head = list -> next;
                        alloc(child);
                        child[0] = (head -> next) -> data;
                        child[1] = createLeaf("PLUS");
                        child[2] = head -> data;
                        T = createTree("Exp", child, 3);
                        list -> next = (head -> next) -> next;
                        linkListInset(list, T);}
    | Exp MINUS Exp {      printf("Exp -> Exp MINUS Exp\n");
                        head = list -> next;
                        alloc(child);
                        child[0] = (head -> next) -> data;
                        child[1] = createLeaf("MINUS");
                        child[2] = head -> data;
                        T = createTree("Exp", child, 3);
                        list -> next = (head -> next) -> next;
                        linkListInset(list, T);}
    | Exp STAR Exp {      printf("Exp -> Exp STAR Exp\n");
                        head = list -> next;
                        alloc(child);
                        child[0] = (head -> next) -> data;
                        child[1] = createLeaf("STAR");
                        child[2] = head -> data;
                        T = createTree("Exp", child, 3);
                        list -> next = (head -> next) -> next;
                        linkListInset(list, T);}
    | Exp DIV Exp {      printf("Exp -> Exp DIV Exp\n");
                        head = list -> next;
                        alloc(child);
                        child[0] = (head -> next) -> data;
                        child[1] = createLeaf("DIV");
                        child[2] = head -> data;
                        T = createTree("Exp", child, 3);
                        list -> next = (head -> next) -> next;
                        linkListInset(list, T);}
    | ID LP Exp RP {      printf("Exp -> ID LP Exp RP\n");
                        head = list -> next;
                        alloc(child);
                        child[0] = createLeaf("ID");
                        child[1] = createLeaf("LP");
                        child[2] = head -> data;
                        child[3] = createLeaf("RP");
                        T = createTree("Exp", child, 4);
                        list -> next = head -> next;
                        linkListInset(list, T);}
    | ID LP RP  {           printf("Exp -> ID LP RP\n");
                        head = list -> next;
                        alloc(child);
                        child[0] = createLeaf("ID");
                        child[1] = createLeaf("LP");
                        child[2] = createLeaf("RP");
                        T = createTree("Exp", child, 3);
                        linkListInset(list, T);}
    | ID {        printf("Exp -> ID\n");
                head = list -> next;
                alloc(child);
                child[0] = createLeaf("ID");
                T = createTree("Exp", child, 1);
                linkListInset(list, T);}
    | INT {        printf("Exp -> INT\n");
                head = list -> next;
                alloc(child);
                child[0] = createLeaf("INT");
                T = createTree("Exp", child, 1);
                linkListInset(list, T);}
    | FLOAT {     printf("Exp -> FLOAT\n");
                head = list -> next;
                alloc(child);
                child[0] = createLeaf("FLOAT");
                T = createTree("Exp", child, 1);
                linkListInset(list, T);}
    | MINUS Exp {     printf("Exp -> MINUS Exp\n");
                    head = list -> next;
                    alloc(child);
                    child[0] = createLeaf("minus");
                    child[1] = head -> data;
                    T = createTree("Exp", child, 2);
                    list -> next = head -> next;
                    linkListInset(list, T);}
;

%%
#include"lex.yy.c"
#include<ctype.h>

int main(int argc, char *argv[])
{
    int count = 50;
    int i = 0;
    list = createLinkList();
    T = NULL;
    for (i = 0 ; i < 9 ; i++){
        child[i] = NULL;
    }
	yyin = fopen(argv[1], "r");
	
    if(!yyparse())
		printf("\nParsing complete\n");
	else
		printf("\nParsing failed\n");
	
	fclose(yyin);
    return 0;
}  

