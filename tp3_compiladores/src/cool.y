/*
 *  cool.y
 *              Parser definition for the COOL language.
 *
 */
%{
#include <iostream>
#include "cool-tree.h"
#include "stringtab.h"
#include "utilities.h"

extern char *curr_filename;

void yyerror(char *s);        /*  defined below; called for each parse error */
extern int yylex();           /*  the entry point to the lexer  */

/************************************************************************/
/*                DONT CHANGE ANYTHING IN THIS SECTION                  */

Program ast_root;	      /* the result of the parse  */
Classes parse_results;        /* for use in semantic analysis */
int omerrs = 0;               /* number of errors in lexing and parsing */
%}

/* A union of all the types that can be the result of parsing actions. */
%union {
	Boolean boolean;
	Symbol symbol;
	Program program;
	Class_ class_;
	Classes classes;
	Feature feature;
	Features features;
	Formal formal;
	Formals formals;
	Case case_;
	Cases cases;
	Expression expression;
	Expressions expressions;
	char *error_msg;
}

/* 
   Declare the terminals; a few have types for associated lexemes.
   The token ERROR is never used in the parser; thus, it is a parse
   error when the lexer returns it.

   The integer following token declaration is the numeric constant used
   to represent that token internally.  Typically, Bison generates these
   on its own, but we give explicit numbers to prevent version parity
   problems (bison 1.25 and earlier start at 258, later versions -- at
   257)
*/
%token CLASS 258 ELSE 259 FI 260 IF 261 IN 262 
%token INHERITS 263 LET 264 LOOP 265 POOL 266 THEN 267 WHILE 268
%token CASE 269 ESAC 270 OF 271 DARROW 272 NEW 273 ISVOID 274
%token <symbol>  STR_CONST 275 INT_CONST 276 
%token <boolean> BOOL_CONST 277
%token <symbol>  TYPEID 278 OBJECTID 279 
%token ASSIGN 280 NOT 281 LE 282 ERROR 283

/*  DON'T CHANGE ANYTHING ABOVE THIS LINE, OR YOUR PARSER WONT WORK       */
/**************************************************************************/
 
   /* Complete the nonterminal list below, giving a type for the semantic
      value of each non terminal. (See section 3.6 in the bison 
      documentation for details). */

/* Declare types for the grammar's non-terminals. */
%type <program> program
%type <classes> class_list
%type <class_> class
%type <features> features_list
%type <feature> feature
%type <formals> formal_list
%type <formal> formal
%type <cases> case_list 
%type <case_> case
%type <expressions> expr_list
%type <expressions> param_expr
%type <expression> expr
%type <expression> op_expr
%type <expression> disp_expr
%type <expression> const_expr
%type <expression> let_expr
/* Precedence declarations go here. */

%right ASSIGN
%left NOT
%nonassoc LE '<' '='
%left '+' '-'
%left '*' '/'
%left ISVOID
%left '~'
%left '@'
%left '.'

%%
/* 
   Save the root of the abstract syntax tree in a global variable.
*/
program  	
	: class_list { 
		@$ = @1;
		ast_root = program($1); }
	;
    
class_list  
	: class { 
		@$ = @1;
		$$ = single_Classes($1);
		parse_results = $$; }
	| class_list class {
		@$ = @2;
		$$ = append_Classes($1, single_Classes($2));
		parse_results = $$; }
	;

class     
	: CLASS TYPEID '{' features_list '}' ';' {
		@$ = @6;
		$$ = class_($2, idtable.add_string("Object"), 
					$4, stringtable.add_string(curr_filename)); }
	| CLASS TYPEID INHERITS TYPEID '{' features_list '}' ';' {
		@$ = @8;
		$$ = class_($2, $4, $6, stringtable.add_string(curr_filename)); }
	| CLASS TYPEID '{' error '}' ';' { 
		yyclearin; 
		$$ = NULL; }
	| CLASS error '{' features_list '}' ';' { 
		yyclearin; 
		$$ = NULL; }
	| CLASS error '{' error '}' ';' { 
		yyclearin; 
		$$ = NULL; }
	;

features_list   
	: features_list feature { 
		@$ = @1;
		$$ = append_Features($1, single_Features($2)); }
	| feature {
		@$ = @1;
		$$ = single_Features($1); }
	| /*nothing*/ { 
		$$ = nil_Features(); }
	;

feature     
	: OBJECTID '(' formal_list ')' ':' TYPEID '{' expr '}' ';' { 
		@$ = @9;
		$$ = method($1, $3, $6, $8); }
	| OBJECTID ':' TYPEID ';' { 
		@$ = @3;
		$$ = attr($1, $3, no_expr()); }
	| OBJECTID ':' TYPEID ASSIGN expr ';' { 
		@$ = @5;
		$$ = attr($1, $3, $5); }
	| OBJECTID ':' TYPEID ASSIGN '{' expr '}' ';' { 
		@$ = @7;
		$$ = attr($1, $3, $6); }
	| error ';' { 
		yyclearin; $$ = NULL; }
	;

formal_list     
	: formal { 
		@$ = @1;
		$$ = single_Formals($1); }
	| formal_list ',' formal { 
		@$ = @2;
		$$ = append_Formals($1, single_Formals($3)); }
	| /*nothing*/ { 
		$$ = nil_Formals(); }
	;

formal      
	: OBJECTID ':' TYPEID { 
		@$ = @3;
		$$ = formal($1, $3); }
	;

case_list    
	: case { 
		@$ = @1;
		$$ = single_Cases($1); }
	| case_list case { 
		@$ = @2;
		$$ = append_Cases($1, single_Cases($2)); }
	;

case         
	: OBJECTID ':' TYPEID DARROW expr ';' {
		@$ = @6;
		$$ = branch($1, $3, $5); }

expr        
	: const_expr {
		@$ = @1;
		$$ = $1; } 
	| OBJECTID { 
		@$ = @1;
		$$ = object($1); }
	| OBJECTID ASSIGN expr { 
		@$ = @3;
		$$ = assign($1, $3); }
	| disp_expr {
		@$ = @1;
		$$ = $1; }
	| IF expr THEN expr ELSE expr FI { 
		@$ = @4;
		$$ = cond($2, $4, $6); }
	| CASE expr OF case_list ESAC { 
		@$ = @5;
		$$ = typcase($2, $4); }
	| WHILE expr LOOP expr POOL { 
		@$ = @5;
		$$ = loop($2, $4); }
	| '{' expr_list '}' { 
		@$ = @2;
		$$ = block($2); }
	| LET let_expr { 
		@$ = @2;
		$$ = $2; }
	| NEW TYPEID { 
		@$ = @2;
		$$ = new_($2); }
	| ISVOID expr { 
		@$ = @2;
		$$ = isvoid($2); }
	| '(' expr ')' { 
		@$ = @2;
		$$ = $2; }
	| op_expr {
		@$ = @1;
		$$ = $1; } 
	;

disp_expr
	: expr '.' OBJECTID '(' param_expr ')' { 
		@$ = @6;
		$$ = dispatch($1, $3, $5); }
	| expr '@' TYPEID '.' OBJECTID '(' param_expr ')' {
		@$ = @8;
		$$ = static_dispatch($1, $3, $5, $7); }
	| OBJECTID '(' param_expr ')' { 
		@$ = @3;
		$$ = dispatch(object(idtable.add_string("self")), $1, $3); }

const_expr
	: INT_CONST { 
		@$ = @1;
		$$ = int_const($1); }
	| STR_CONST {
		@$ = @1; 
		$$ = string_const($1); }
	| BOOL_CONST {
		@$ = @1; 
		$$ = bool_const(true); }
	;

op_expr
	: expr '+' expr { 
		@$ = @3;
		$$ = plus($1, $3); }
	| expr '-' expr {
		@$ = @3; 
		$$ = sub($1, $3); }
	| expr '*' expr {
		@$ = @3; 
		$$ = mul($1, $3); }
	| expr '/' expr {
		@$ = @3; 
		$$ = divide($1, $3); }
	| '~' expr {
		@$ = @2; 
		$$ = neg($2); }
	| expr '<' expr { 
		@$ = @3;
		$$ = lt($1, $3); }
	| expr LE expr { 
		@$ = @3;
		$$ = leq($1, $3); }
	| expr '=' expr {
		@$ = @3; 
		$$ = eq($1, $3); }
	| NOT expr { 
		@$ = @2;
		$$ = comp($2); }
	| expr error expr{
		@$ = @2;
		yyclearin;
		$$ = NULL; }
	;

let_expr    
	: OBJECTID ':' TYPEID IN expr { 
		@$ = @5;
		$$ = let($1, $3, no_expr(), $5); }
	| OBJECTID ':' TYPEID ASSIGN expr IN expr { 
		@$ = @7;
		$$ = let($1, $3, $5, $7); }
	| OBJECTID ':' TYPEID ',' let_expr { 
		@$ = @5;
		$$ = let($1, $3, no_expr(), $5); }
	| OBJECTID ':' TYPEID ASSIGN expr ',' let_expr { 
		@$ = @7;
		$$ = let($1, $3, $5, $7); }
	| error IN expr { 
		yyclearin; 
		$$ = NULL; }
	| error ',' let_expr { 
		yyclearin; 
		$$ = NULL; }
	;

expr_list    
	: expr ';' { 
		@$ = @1;
		$$ = single_Expressions($1); }
	| expr_list expr ';' {
		@$ = @2; 
		$$ = append_Expressions($1, single_Expressions($2)); }
	/* recover from an expression inside a block */
	| error ';' { 
		yyclearin; 
		$$ = NULL; }
	;

param_expr          
	: expr { 
		@$ = @1;
		$$ = single_Expressions($1); }
	| param_expr ',' expr { 
		@$ = @3;
		$$ = append_Expressions($1, single_Expressions($3)); }
	| /*nothing*/ { 
		$$ = nil_Expressions(); }
	;
					;
/* end of grammar */
%%

/* This function is called automatically when Bison detects a parse error. */
void yyerror(char *s)
{
  extern int curr_lineno;

  cerr << "\"" << curr_filename << "\", line " << curr_lineno << ": " \
    << s << " at or near ";
  print_cool_token(yychar);
  cerr << endl;
  omerrs++;

  if(omerrs>50) {fprintf(stdout, "More than 50 errors\n"); exit(1);}
}

