%{ 
//Blake Flores, SID: 862016674 Email: Bflor019@ucr.edu
//#include <string.h>
//#include <stdio.h>
//#include <stdlib.h>
//void yyerror(const char *msg);
//extern int line;
//extern int col;
//FILE * yyin;
%}



%skeleton "lalr1.cc"
%require "3.0.4"
%defines
%define api.token.constructor
%define parse.error verbose
%define api.value.type variant
%locations

%code requires
{
#include <list>
#include <string>
#include <functional>
/* types definitions */
	struct big_type{
		int value;

		std::string identifier = "";
		std::string idCode = "";
		std::string op = "";
		std::string result = "";
		bool isArray = false;
		std::string arrayName = "";
		std::string arrayIndex = "";
		
		std::string varName = "";
		bool leftArray=false;
		bool mutiplelVars = false;
		std::string rvars = "";
		std::string wvars = "";

		std::string compare_op= "";

		int number = 0;
		std::string num = "";
		bool contFlag = false;
		std::string loop_lable = "";

	};
};



%code 
{
	#include "parser.tab.hh"
	#include <sstream>
	#include <map>
	#include <regex>
	#include <set>
	#include <string>
	#include <vector>
	#include <iterator>

	yy::parser::symbol_type yylex();

	int tmpCnt = 0;
	int lblCnt = 0;
	int paramCnt = 0;

	map<string, int> varTable; /* 0 is a var, 1 is an array*/
	vector<string> tmpTable;
	vector<string> funTable;


	string make_tmp_name()
	{
		string tmp_name = "tmp";
		tmp_name = tmp + to_string(tmpCnt);
		tmpTable.push_back(tmp_name);
		tmpCnt++;
		return tmp_name
	}

	string make_lable()
	{
		string tmp_lable = "lable";
		tmp_lable = tmp_lable + to_string(lblCnt);
		lblCnt++;
	}
	
	string get_tmps()
	{
		string listOfTmps="";
		for( int i = 0; i < tmpTable.size(); i++)
		{
			listOfTmps=listOfTmps + ". " + tmpTable[i] + "\n";
		}
		return listOfTmps;
	}

	string loopLable = make_lable();

}

%start program;

%token END 0 "end of file";
%type <std::string> IDENT;
%type <std::string> NUMBER;

%type <big_type> function;

%token FUNCTION;
%token BEGIN_PARAMS;
%token END_PARAMS;
%token BEGIN_LOCALS;
%token END_LOCALS;
%token BEGIN_BODY;
%token END_BODY;
%token BEGIN_LOOP;
%token END_LOOP;

%left L_PAREN;
%left R_PAREN;
%left L_SQUARE_BRACKET;
%left R_SQUARE_BRACKET;

%left IF;
%left THEN;
%left ELSE;
%left ENDIF;
%left DO;
%token WHILE;

%token READ;
%token WRITE;
%token CONTINUE;
%token RETURN;
%token ASSIGN;
%token ARRAY;
%token OF;
%token INTEGER;

%token TRUE;
%token FALSE;

%token AND;
%token OR;
%token NOT;

%token COMMA;
%token SEMICOLON;
%token COLON;

%token GT;
%token LT;
%token LTE;
%token GTE;
%token EQ;
%token NEQ;
%left SUB;
%left MULT;
%left ADD;
%left DIV;
%left MOD;

%type <big_type> Functions Function Function_Name 
%type <big_type> Extra_Declarations Extra_Declarations2 Declaration
%type <big_type> Statement_Semicolons Statement
%type <big_type> Comma_Var Bool_Expr Relation_And_Expr Relation_Expr Comp Expression
%type <big_type> Optional_Array Multiplicative_Expr Comma_Expression 
%type <big_type> Var Term Term_Arg Number Ident

%%


program:	Functions	 {}
		;

Functions:	/*Empty*/	{}
		|Function Functions	{$$.idCode = $1.idCode + $2.idCode;}

Function_Name:	FUNCTION Ident	{$$.identifier = $2;
				funTable.push_back($2);
				}
				;

Function:	Function_Name SEMICOLON BEGIN_PARAMS Extra_Declarations END_PARAMS BEGIN_LOCALS Extra_Declarations2 END_LOCALS BEGIN_BODY Statement_Semicolons END_BODY 
		{
			$$.idCode = "func " + $1.identifier + "\n" + $4.idCode + $7.idCode + get_tmps() + $10.idCode + "endfunc\n";
			tmpTable.clear();
			varTable.clear();
			tmpCnt = 0;
			paramCnt = 0;
		}
		;

Extra_Declarations:	/* empty */{}
			|Declaration SEMICOLON Extra_Declarations
			{
				$$.idCode = $1.idCode + "=" + $1.identifier + "," + "$" + std::to_string($1.number) + "\n" + $3.idCode;
			}	
			;

Extra_Declarations2:	/*empty*/{}
			|Declaration SEMICOLON Extra_Declarations2
			{
				$$idCode = $1.idCode + $3.idCode;
			}
			;

Declaration:	Ident COLON Optional_Array INTEGER
		{
			map<string,int>::iterator it = vtable.find($1.identifier);
			it->second = 1;
			$$.idCode = ".[] " + $1.identifier + ", " + $3.num
		}
		;

Optional_Array:		/*empty*/{}
			|ARRAY L_SQUARE_BRACKET Number R_SQUARE_BRACKET OF
			{
				$$.number = $3;
			}
			;


Statement_Semicolons:	/*empty*/ {}
			|Statement SEMICOLON Statement_Semicolons
			{
				$$.idCode = $1.idCode + $3.idCode;
				if($1.contFlag)
					$$.contFlag = $1.contFlag;
				else if($3.contFlag)
					$$.contFlag = $3.contFlag;
			}
			;

Statement:	Var ASSIGN  Expression 
		{
			if($3.isArray){
				$$.idCode = $$.idCode + $3.idCode + "=[] " + $1.varName + ", " + $3.arrayName + ", " + $3.arrayIndex + "\n";
			}
			else if($1.left_array){
				$$.idCode += $3.idCode + "= " + $1.varName + ", " + $3.result + "\n";
			}
		}
		| IF Bool_Expr THEN Statement_Semicolons ENDIF
		{	
			std::string l1,l2;
			l1 = make_lable();
			l2 = make_lable();
			$$.idCode = $2.idCode + "?:= " + l1 + ", " + $2.result + "\n" + ":=" + l2 + "\n" + ": " + l1 + "\n" + $4.idCode + ": " + l2 + "\n";
		}
		| IF Bool_Expr THEN Statement_Semicolons ELSE Statement_Semicolons ENDIF
		{
			std::string l1,l2, l3;
			l1 = make_lable();
			l2 = make_lable();
			l3 = make_lable();
			$$.idCode = $2.idCode + "?:= " + l1 + ", " + $2.result + "\n" + ":=" + l2 + "\n" + ": " + l1 + "\n" + $4.idCode + ":= " + l3 + "\n" + ": " + l2 + "\n" + $6.idCode + ": " + l3 + "\n";
		}
		| WHILE Bool_Expr BEGIN_LOOP Statement_Semicolons END_LOOP
		{
			std::string l1, l2, l3;
			l1 = make_lable();
			l2 = make_lable();
			l3 = make_lable();

			$$.idCode = ": " + l1 + "\n" + $2.idCode + "?:= " + l2 + ", " + $2.result + "\n" + ":= " + l3 + "\n" + ": " + l2 + "\n" + $4.idCode + ":= " + l1 + "\n "+ ": "+ l3 + "\n";
			loopLable = make_lable();
			if($4.contFlag)
				$4.contFlag = false;
			$$.contFlag = $4.contFlag;
		}
		| DO BEGIN_LOOP Statement_Semicolons END_LOOP WHILE Bool_Expr
		{
			std::string l1, l2;
			l1 = make_lable();;
			l2 = loopLable;
			
			$$.idCode = ": " + l1 + "\n" + $3.idCode + ": " + l2 + "\n " + $6.idCode +"?:= " + l1 + ", " + $6.result + "\n";
			
		}
		| READ Comma_Var
		{
			if($2.multipleVars)
				$$.idCode = $2.rvars;
			else if($2.isArray)
				$$.idCode = ".[]< " + $2.arrayName + ", " + $2.arrayIndex + "\n";
			else
				$$.idCode = ".<" + $2.varName + "\n";
		}
		| WRITE Comma_Var	
		{
			if($2.multipleVars)
				$$.idCode = $2.wvars;
			else if($2.isArray)
				$$.idCode = ".[]> " + $2.arrayName + ", " + $2.arrayIndex + "\n";
			else
				$$.idCode = ".> " + $2.varName + "\n";
		}
		| CONTINUE
		{
			$$.idCode = ":= " + loopLable + "\n";
			$$.contFlag = true;
		}
		| RETURN Expression 
		{
			$$.idCode = $2.idCode + "ret " + $2.result + "\n"
		}
		;

	
Comma_Var:	/*empty*/ {}
		|Var	
		{
			$$.isArray = $1.isArray;
			$$.arrayName = $1.arrayName;
			if($1.isArray)
			{
				$$.wvars = ".[]> " + $1.arrayName + ", " + $1.arrayIndex + "\n";
				$$.rvars = ".[]< " + $1.arrayName + ", " + $1.arrayIndex + "\n";
			}
			else
			{
				$$.rvars = ".< " + $1.varName + "\n ";
				$$.wvars = ".> " + $1.varName + "\n";
			}
		}
		|Var COMMA Comma_Var
		{
			$3.multipleVars = true;
			$$.multipleVars = true;
			if($1.isArray)
			{
				$$.wvars = ".[]>" + $1.arrayName + ", " + $1.arrayIndex + "\n" + $3.wvars;
				$$.rvars = ".[]< " + $1.arrayName + ", " + $1.arrayIndex + "\n" + $3.rvars;
			}
			 else
                        {
                                $$.rvars = ".< " + $1.varName + "\n " + $3.rvars;
                                $$.wvars = ".> " + $1.varName + "\n" + $3.wvars;
                        }

		}
		;

Bool_Expr:	Relation_And_Expr 
		{
			$$.idCode = $1.idCode;
			$$.result = $1.result;
		}
		| Bool_Expr OR Relation_And_Expr
		{
			string tmp = make_tmp_name();
			$$.result = tmp;
			$$.idcode = $1.idCode + $3.idCode + "|| " + tmp + ", " + $1.result + ", " + $3.result + "\n";
		}
		;

Relation_And_Expr:	Relation_Expr 
			{
				$$.idCode = $1.idCode;
				$$.result = $1.result;				
			}
			| Relation_And_Expr AND Relation_Expr
			{
				string tmp = make_tmp_name();
				$$.result = tmp;
				$$.idCode = $1.idCode + $3.idCode + "&& " + tmp + ", " + $1.result + ", " + $3.result + "\n";
			}
			;

Relation_Expr:	NOT Relation_Expression
		{
			string tmp = make_tmp_name();
			$$.result = tmp;
			$$.idCode = $2.idCode + "! " + tmp + ", " + $2.result + "\n";
		}	
		|Expression Comp Expression
		{
			string tmp = make_tmp_name();
			$$.result = tmp;
			$$.idCode += $1.idCode + $3.idCode + $2.compare_op + " " + tmp + ", " + $1.result + ", " + $3.result + "\n";
		}
		| TRUE
		{
			string tmp = make_tmp_name();
			$$.idCode = "= " + tmp + ", " + "1\n";
			$$.result = tmp;
		}
		| FALSE
		{
			string tmp = make_tmp_name();
			$$.idCode = "= " + tmp + ", " + "0\n";
			$$.result = tmp;
		}
		| L_PAREN Bool_Expr R_PAREN
		{
			$$.idCode += $2.idCode;
			$$.result = $2.result;
		}
			;

Comp:		 EQ	{$$.compare_op = $1;}
		|NEQ	{$$.compare_op = $1;}
		|LT	{$$.compare_op = $1;}
		|GT	{$$.compare_op = $1;}
		|LTE	{$$.compare_op = $1;}
		|GTE	{$$.compare_op = $1;}
		;

Expression:	Multiplicative_Expr 
		{
			$$.result = $1.result;
			$$.idCode += $1.idCode;
			$$.isArray = $1.isArray;
			$$.arrayIndex = $1.arrayIndex;
			$$.arrayName = $1.arrayName;
		}
		|Expression ADD Multiplicative_Expr
		{
			string tmp = make_tmp_name();
			$$.result = tmp;
			$$.idCode = $1.idCode + $3.idCode + "+ " + tmp + ", " + $1.result + ", " + $3.result + "\n";
		}
		| Expression SUB Multiplicative_Expr
		{
			string tmp = make_tmp_name();
			$$.result = tmp;
			$$.idCode = $1.idCode + $3.idCode + "- " + tmp + ", " + $1.result + ", " + $3.result + "\n";				
		}
		;

Multiplicative_Expr:	Multiplicative_Expr MULT Term
			{
				string tmp = make_tmp_name();
				$$.idCode = $1.idCode + $3.idCode + "* " + tmp + ", " + $1.result + ", " + $3.result + " \n";
				
			}
  			|Multiplicative_Expr MOD Term
                        {
                                string tmp = make_tmp_name();
                                $$.idCode = $1.idCode + $3.idCode + "% " + tmp + ", " + $1
.result + ", " + $3.result + " \n";

                        }
  			|Multiplicative_Expr DIV Term
                        {
                                string tmp = make_tmp_name();
                                $$.idCode = $1.idCode + $3.idCode + "/ " + tmp + ", " + $1
.result + ", " + $3.result + " \n";

                        }
			|Term
			{
				$$.idCode = $1.idCode;
				$$.result = $1.result;
				$$.isArray = $1.isArray;
				$$.arrayIndex = $1.arrayIndex;
				$$.arrayName = $1.arrayName;
			}
			;

Term:		SUB Term_Arg
		{
			string tmp = make_tmp_name();
			$$..iCode = "- " + tmp + ", " + "0" + ", " + $2.result + "\n";
			$$.result = tmp;
		}
		| Term_Arg	
		{
		$$.idCode = $1.idCode;
		$$.result = $1.result;
		}
		| Ident L_PAREN Expression Comma_Expression  R_PAREN 
		{
			string tmp = make_tmp_name();
			$$.idCode = $3.idCode + "call " + $1  + ", " + tmp + "\n";
		};
		;

Comma_Expression:	/*empty*/ {}
		|COMMA Expression Comma_Expression
		{
			string tmp = make_tmp_name();
			$$.idCode = $2.idCode + "param " + $2.result + "\n" + $3.idCode;	
		}
		;

Term_Arg:	Var
		{
			$$.idCode = $1.idCode;
			$$.isArray = $1.isArray;
			$$.arrayName = $1.arrayName;
			$$.arrayIndex = $1.arrayIndex;
			$$.result = $1.result;
		}
		| Number
		{
			$$.result = $1;
		}
		| L_PAREN Expression Comma_Expression R_PAREN
		{
			$$.idCode = $2.idCode + $3.idCode;
			$$.result = $2.result;
			
		}
		;

Var:		Ident
		{
			$$.isArray = false;
			$$.varName = $1;
			$$.result = $1;			
		}
		|Ident L_SQUARE_BRACKET Expression R_SQUARE_BRACKET
		{
			$$.isArray = true;
			$$.arrayIndex = $3.result;
			$$.arrayName = $1;
			$$.idCode += $3.idCode;
			$$.leftArray = true;
	
		}
		;

Ident:		IDENT
		{
			vtable.insert(pair<string,int>($1,0); //0 = variable, not array
			$$.idCode = ". " + $1 + "\n";
			$$.identifier = $1;
		}
		IDENT COMMA Ident
		{
			vtable.insert(pair<string, int>($1,0));
			$$.idCode = ". " + $1 + "\n" + $3.idCode;
			$$.identifier = $1;
		}
		;

Number:		NUMBER	
		{
			$$.result = $1;
		}
		;
%%

int main(int argc, char **argv) {
   if (argc > 1) {
      yyin = fopen(argv[1], "r");
      if (yyin == NULL){
         printf("syntax: %s filename\n", argv[0]);
      }//end if
   }//end if
   yyparse(); // Calls yylex() for tokens.
   return 0;
}
void yyerror(const char *msg) {
   printf("** Line %d, position %d: %s\n", line, col, msg);
}

 	

