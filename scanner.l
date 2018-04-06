%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int line = 0;
char* temp_line = 0;
int temp_len = 0;
int source = 1;
int token = 1;
int error = 0;
int pragma_token = 1, pragma_source = 1;
%}

INT ([0-9])|([1-9][0-9]*)
DOUBLE ({INT}\.[0-9]*)|(\.[0-9]+)
CHAR '.'|'\\.'
ID [a-zA-Z_][a-zA-Z0-9_]*
STRING \".*\"
SCI ({INT}|{DOUBLE})[eE][+-]?{INT}
PUNC [:;,.\[\]\(\)\{\}]
FUNCTION fclose|clearerr|feof|ferror|fflush|fgetpos|fopen|fread|freopen|fseek|fsetpos|ftell|fwrite|remove|rename|rewind|setbuf|setvbuf|tmpfile|tmpnam|fprintf|printf|sprintf|vfprintf|vprintf|vsprintf|fscanf|scanf|sscanf|fgetc|fgets|fputc|fputs|getc|getchar|gets|putc|putchar|puts|ungetc|perror
KEY {FUNCTION}|void|int|double|bool|char|null|for|while|do|if|else|switch|return|break|continue|const|true|false|struct|case|default
CONST {INT}|{DOUBLE}|{CHAR}|{STRING}|{SCI}
ERR ({CONST}({CONST})+)|({CONST}({ID})+)|({ID}({CONST})+)|(#[ ]*pragma.*)

%x BIG_COMMENT
%x ERROR

%%

"+" {if(token)printf("#op:%s\n",yytext);}
"-" {if(token)printf("#op:%s\n",yytext);}
"*" {if(token)printf("#op:%s\n",yytext);}
"/" {if(token)printf("#op:%s\n",yytext);}
"%" {if(token)printf("#op:%s\n",yytext);}
"++" {if(token)printf("#op:%s\n",yytext);}
"--" {if(token)printf("#op:%s\n",yytext);}
"<" {if(token)printf("#op:%s\n",yytext);}
"<=" {if(token)printf("#op:%s\n",yytext);}
">" {if(token)printf("#op:%s\n",yytext);}
">=" {if(token)printf("#op:%s\n",yytext);}
"==" {if(token)printf("#op:%s\n",yytext);}
"!=" {if(token)printf("#op:%s\n",yytext);}
"=" {if(token)printf("#op:%s\n",yytext);}
"&&" {if(token)printf("#op:%s\n",yytext);}
"||" {if(token)printf("#op:%s\n",yytext);}
"!" {if(token)printf("#op:%s\n",yytext);}

#[ ]*pragma[ ]+source[ ]+on {source = 1;}
#[ ]*pragma[ ]+source[ ]+off {source = 0;}
#[ ]*pragma[ ]+token[ ]+on {token = 1;}
#[ ]*pragma[ ]+token[ ]+off {token = 0;}

{PUNC} {if(token)printf("#punc:%s\n",yytext);}
{KEY} {if(token)printf("#key:%s\n",yytext);}
{INT} {if(token)printf("#integer:%s\n",yytext);}
{DOUBLE} {if(token)printf("#double:%s\n",yytext);}
{CHAR} {if(token)printf("#char:%s\n",yytext);}
{ID} {if(token)printf("#id:%s\n",yytext);}
{STRING} {
	yytext[yyleng-1]=0;
	printf("#string:%s\n",yytext+1);
	}

" " {}
"\n" {if(source)printf("%d:%s",++line,temp_line);}
<BIG_COMMENT>"\n" {if(source)printf("%d:%s",++line,temp_line);}
{SCI} {if(token)printf("#sci:%s\n",yytext);}

{ERR} {
    printf("Error at line %d: %s",++line,yytext);
    BEGIN ERROR;
    }
<ERROR>"\n" {
    printf("\n");
    BEGIN 0;
}
<ERROR>. {
    ECHO;
}
. {
    printf("Error at line %d: %s",++line,yytext);
    BEGIN ERROR;
}


\/\/[^\n]* {
	
}

\/\* {
    BEGIN BIG_COMMENT;
}
<BIG_COMMENT>\*\/ {
    BEGIN 0;
}
<BIG_COMMENT>. {

}

^(.*)\n {
	if(yyleng>temp_len){
		temp_len = yyleng+1;
		free(temp_line);
		temp_line = (char*)malloc(sizeof(char)*(yyleng+1));
	}
	strcpy(temp_line,yytext);
	REJECT;
}
<BIG_COMMENT>^(.*)\n {
	if(yyleng>temp_len){
		temp_len = yyleng+1;
		free(temp_line);
		temp_line = (char*)malloc(sizeof(char)*(yyleng+1));
	}
	strcpy(temp_line,yytext);
	REJECT;
}

%%

int main(){
	yylex();
}