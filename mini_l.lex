%{
#include "y.tab.h"
#include <string.h>
%}
digit [0-9]
id [a-zA-Z]([a-zA-Z0-9_]*[a-zA-Z0-9])*
	int line = 1,  col = 1;
%%

function	{return(FUNCTION);col+= yyleng;}
beginparams	{col+= yyleng;
		return(BEGIN_PARAMS);	}
endparams	{col+= yyleng;
		 return(END_PARAMS);	}
beginlocals	{col+= yyleng; 
		return(BEGIN_LOCALS);	}
endlocals	{col+= yyleng;
		 return(END_LOCALS);	}
beginbody	{col+= yyleng;
		 return(BEGIN_BODY);	}
endbody		{col+= yyleng;
		 return(END_BODY);	}

integer		{col+= yyleng;
		 return(INTEGER);	}
array		{col+= yyleng;	
		 return(ARRAY);		}
of		{col+= yyleng;
		 return(OF);		}

if		{col+= yyleng;
		 return(IF);	}
then		{col+= yyleng;
		 return(THEN);	}
endif		{col+= yyleng;
		 return(ENDIF);	}
else		{ col+= yyleng;
		 return(ELSE);	}
while		{col+= yyleng;
		 return(WHILE);	}
do		{ col+= yyleng;
		 return(DO);	}
beginloop	{ col+= yyleng;
		 return (BEGIN_LOOP);	}
endloop		{ col+= yyleng;
		 return(END_LOOP);	}
continue	{ col+= yyleng;
		 return(CONTINUE);	}

read		{ col+= yyleng;
		 return(READ);	}
write		{ col+= yyleng;
		 return(WRITE);	}

and		{ col+= yyleng;
		 return(AND);	}
or		{ col+= yyleng;
		 return(OR);	}
not		{ col+= yyleng;
		 return(NOT);	}
true		{ col+= yyleng;
		 return(TRUE);	}
false		{ col+= yyleng;
		 return(FALSE);	}
return		{ col+= yyleng;
		 return(RETURN);	}

"-"		{ col+= yyleng;
		 return(SUB);	}
"+"		{ col+= yyleng;
		 return(ADD);	}
"*"		{ col+= yyleng;
		 return(MULT);	}
"/"		{ col+= yyleng;
		 return(DIV);	}
"%"		{ col+= yyleng;
		 return(MOD);	}
"=="		{ col+= yyleng;
		 return(EQ);	}
"<>"		{ col+= yyleng;
		 return(NEQ);	}
"<"		{ col+= yyleng;
		 return(LT);	}
">"		{ col+= yyleng;
		 return(GT);	}
"<="		{ col+= yyleng;
		 return(LTE);	}
">="		{ col+= yyleng;
		 return(GTE);	}

{digit}+	{ col+= yyleng;
		 yylval.int_val = atoi(yytext);
		return(NUMBER);	}
{id}		{ col+= yyleng;
		 strcpy(yylval.string_val, yytext);
		return(IDENT);	}

";"		{ col+= yyleng;
		 return(SEMICOLON);	}
":"		{ col+= yyleng;
		 return(COLON);		}
","		{ col+= yyleng;
		 return(COMMA);		}
"("		{ col+= yyleng;
		 return(L_PAREN);	}
")"		{ col+= yyleng;
		 return(R_PAREN);	}
"["		{ col+= yyleng;
		 return(L_SQUARE_BRACKET);}
"]"		{ col+= yyleng;
		 return(R_SQUARE_BRACKET); }
":="		{ col+= yyleng;
		 return(ASSIGN);		}

[ \t]+		{ col+= yyleng;} /* eat whitespace */
"\n"		{ line++; col = 1;		}
"##".*"\n"	{ line++; col = 1; 		}	/* eat line comments */

{digit}*{id}*|"_"*{id}*{digit}*     	{ printf ("Error: line %d, column %d, ID \" %s \" must start with a character\n", line, col, yytext);
					col+= yyleng;}

{id}"_"*|{digit}+{id}"_"+		{ printf("Error: Line %d, Column %d, ID \"%s\"  can't end with an underscore\n", line, col, yytext);
					col+= yyleng;}

.					{ printf("Error: Unrecognized character \" %s \" on line %d column %d. \n", yytext, line, col);
					col+= yyleng;}
