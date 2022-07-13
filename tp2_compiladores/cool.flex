/*
 *  The scanner definition for COOL.
 */

/*
 *  Stuff enclosed in %{ %} in the first section is copied verbatim to the
 *  output, so headers and global definitions are placed here to be visible
 * to the code in the file.  Don't remove anything that was here initially
 */
%{
#include <cool-parse.h>
#include <stringtab.h>
#include <utilities.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
/* The compiler assumes these identifiers. */
#define yylval cool_yylval
#define yylex  cool_yylex

/* Max size of string constants */
#define MAX_STRING_CONST 1025
#define YY_NO_UNPUT   /* keep g++ happy */

extern FILE *fin; /* we read from this file */

/* define YY_INPUT so we read from the FILE fin:
 * This change makes it possible to use this scanner in
 * the Cool compiler.
 */
#undef YY_INPUT
#define YY_INPUT(buf,result,max_size) \
	if ( (result = fread( (char*)buf, sizeof(char), max_size, fin)) < 0) \
		YY_FATAL_ERROR( "read() in flex scanner failed");

char string_buf[MAX_STRING_CONST]; /* to assemble string constants */
char *string_buf_ptr;

extern int curr_lineno;
extern int verbose_flag;

extern YYSTYPE cool_yylval;

/*
 *  Add Your own definitions here
 */
  int commflag = 0;
  int stringflag = 0;
  int unstarted_comment_err(int);
  int eof_comment_err(int);
  int string_size_err(int);
  int unterminated_string_err(int);
  int invalid_character_err(int);
%}

%x STRING
%x COMMENT
/*
 * Define names for regular expressions here.
 */

DARROW        =>
ASSIGN        <-
LE            <=


/*
* Keywords
*/

CLASS         [cC][lL][aA][sS][sS]
IF            [iI][fF]
ELSE          [eE][lL][sS][eE]
FI            [fF][iI]
IN            [iI][nN]
INHERITS      [iI][nN][hH][eE][rR][iI][tT][sS]
ISVOID        [iI][sS][vV][oO][iI][dD]
LET           [lL][eE][tT]
LOOP          [lL][oO][[oO][pP]
POOL          [pP][oO][oO][lL]
THEN          [tT][hH][eE][nN]
WHILE         [wW][hH][iI][lL][eE]
CASE          [cC][aA][sS][eE]
ESAC          [eE][sS][aA][cC]
SELF          [sS][eE][lL][fF]
OF            [oO][fF]
NEW           [nN][eE][wW]
NOT           [nN][oO][tT]
TRUE          [t][rR][uU][eE]
FALSE         [f][aA][lL][sS][eE]

NUMBERS       [0-9]+
TYPEID        [A-Z][a-zA-Z_0-9]*
OBJECTID      [a-z][a-zA-Z_0-9]*
ENDLINE       [\n]

%%

 /*
  *  Nested comments
  */

"--"(.)*                {}

"*)"			              {
                            if (commflag == 0){
                                return unstarted_comment_err(curr_lineno);
                            }
                        }
"(*"			              {
			                  	  commflag = 1;
                  				  BEGIN(COMMENT);
			                  }

<COMMENT>.              {}


<COMMENT>"(*"		        { commflag = 1; }

<COMMENT>"*)"		        {
                            if(commflag){
                                BEGIN(INITIAL);
                            }
                            else{
                                unstarted_comment_err(curr_lineno);
                            }
                        }
<COMMENT><<EOF>>	      {
                            BEGIN(INITIAL);
                            if(commflag > 0){
                              return eof_comment_err(curr_lineno);
                            }
                        }

<COMMENT>\n		++curr_lineno;



 /*
  *  The multiple-character operators.
  */

{DARROW}		  { return (DARROW); }
{ASSIGN}      { return (ASSIGN); }
{LE}          { return (LE); }
"="           { return ('='); }
"<"           { return ('<'); }
">"           { return ('<'); }
"+"           { return ('+'); }
"-"           { return ('-'); }
"/"           { return ('/'); }
"*"           { return ('*'); }
":"           { return (':'); }
";"           { return (';'); }
"{"           { return ('{'); }
"}"           { return ('}'); }
"["           { return ('['); }
"]"           { return (']'); }
"("           { return ('('); }
")"           { return (')'); }
"@"           { return ('@'); }
"."           { return ('.'); }
","           { return (','); }

 /*
  * Keywords are case-insensitive except for the values true and false,
  * which must begin with a lower-case letter.
  */

{CLASS}       { return (CLASS); }
{IF}          { return (IF); }
{ELSE}        { return (ELSE); }  
{FI}          { return (FI); }
{IN}          { return (IN); }
{INHERITS}    { return (INHERITS); }
{ISVOID}      { return (ISVOID); }
{LET}         { return (LET); }
{LOOP}        { return (LOOP); }
{POOL}        { return (POOL); }
{THEN}        { return (THEN); }  
{WHILE}       { return (WHILE); }
{CASE}        { return (CASE); }
{ESAC}        { return (ESAC); }
{OF}          { return (OF); }
{NEW}         { return (NEW); }
{NOT}         { return (NOT); }

{TRUE}        {
  cool_yylval.boolean = true;
  return BOOL_CONST;
}

{FALSE}       {
  cool_yylval.boolean = false;
  return BOOL_CONST;
}

[\ \t\r\v\f]+ {}


{ENDLINE}     {curr_lineno++;}

{OBJECTID}    { 
                  cool_yylval.symbol = idtable.add_string(yytext); 
                  return (OBJECTID); 
              }
{TYPEID}      { 
                  cool_yylval.symbol = idtable.add_string(yytext); 
                  return (TYPEID);
              }

{NUMBERS}     {
                  cool_yylval.symbol = inttable.add_string(yytext);
                  return (INT_CONST);
              }

 /*
  *  String constants (C syntax)
  *  Escape sequence \c is accepted for all characters c. Except for 
  *  \n \t \b \f, the result is c.
  *
  */

"\""                      {
                              BEGIN(STRING);
                              string_buf_ptr = string_buf;  
                          }

<STRING>"\""              {
                            BEGIN(INITIAL);
                            if ((string_buf_ptr - string_buf) + 1 > MAX_STRING_CONST){
                                return string_size_err(curr_lineno);
                            }
                            else{
                                string_buf_ptr = 0;
                                cool_yylval.symbol = stringtable.add_string(string_buf);
                                return (STR_CONST);
                            }
                        }

<STRING>.               {
                            if ((string_buf_ptr - string_buf) + 1 > MAX_STRING_CONST){
                                return string_size_err(curr_lineno);
                            }
                            *string_buf_ptr++ = *yytext;
                        }

<STRING><<EOF>>         { 
                            return unterminated_string_err(curr_lineno);
                        }

<STRING>"\\\n"          { curr_lineno++; }



<STRING>"\n"            {
                            curr_lineno++;
                            return unterminated_string_err(curr_lineno);
                        }

<STRING>\0              {
                            strcpy(cool_yylval.error_msg, "String contains null character");
                            return (ERROR);
                        }

<STRING>"\\n"|"\\t"|"\\b"|"\\f"   {
                                      if ((string_buf_ptr - string_buf) + 1 > MAX_STRING_CONST) {
                                          return (string_buf_ptr - string_buf) + 1 > MAX_STRING_CONST;
                                      }
                                      *string_buf_ptr++ = *yytext;
                                  }

.             {
                  return invalid_character_err(curr_lineno);
              }
%%

int yywrap(){
  return 1;
}

int string_size_err(int a) { 
    BEGIN(INITIAL);
    strcpy(cool_yylval.error_msg, "String constant too long");
    return ERROR;
}

int unterminated_string_err(int a){
    BEGIN(INITIAL);
    strcpy(cool_yylval.error_msg, "Unterminated string constant");
    return ERROR;
}

int eof_comment_err(int a){
    commflag = 0;
    strcpy(cool_yylval.error_msg, "Unterminated comment");
    return ERROR;
}

int unstarted_comment_err(int a){
    BEGIN(INITIAL);
    strcpy(cool_yylval.error_msg, ("Unstarted comment"));
    return ERROR;
}

int invalid_character_err(int a){
    strcpy(cool_yylval.error_msg, ("Invalid character")); 
	  return ERROR;
}
