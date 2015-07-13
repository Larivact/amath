%include{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <assert.h>
#include "strip.h"
#include "symtypes.h"
}

%token_type {const struct sym*}
%extra_argument {char **f}

%syntax_error
{
	printf("Problem");
	exit(0);
}

start ::= e(B) .
{
	*f = strdup(B->str);
}

v(A) ::= IDENTIFIER(B) .
{
	struct sym *new = malloc(sizeof(struct sym));
	char *str;
	asprintf(&str, "<mi>%s</mi>", B->str);
	new->str = str;
	A = new;
}
v(A) ::= NUMBER(B) .
{
	struct sym *new = malloc(sizeof(struct sym));
	char *str;
	asprintf(&str, "<mn>%s</mn>", B->str);
	new->str = str; new->pos = B->pos;
	A = new;
}
v(A) ::= OPERATOR(B) .
{
	struct sym *new = malloc(sizeof(struct sym));
	char *str;
	asprintf(&str, "<mo>%s</mo>", B->str);
	new->str = str; new->pos = B->pos;
	A = new;
}
v(A) ::= TEXT(B) .
{
	struct sym *new = malloc(sizeof(struct sym));
	char *str;
	asprintf(&str, "<mtext>%s</mtext>", strip_quotes(B->str));
	new->str = str; new->pos = B->pos;
	A = new;
}

s(A) ::= v(B). { A = B; }
s(A) ::= LEFT(B) e(C) RIGHT(D) .
{
	struct sym *new = malloc(sizeof(struct sym));
	char *str;
	asprintf(&str, "<mrow>%s%s%s</mrow>", B->str, C->str, D->str);
	new->str = str;
	A = new;
}

s(A) ::= ACCENT(B) s(C) .
{
	struct sym *new = malloc(sizeof(struct sym));
	char *str;

	if (B->pos == 2)
		asprintf(&str, "<mover>%s<mo>%s</mo></mover>", C->str, B->str);
	else
		asprintf(&str, "<munder>%s<mo>%s</mo></munder>", C->str, B->str);

	new->str = str;
	A = new;
}

s(A) ::= UNARY(B) s(C) .
{
	struct sym *new = malloc(sizeof(struct sym));
	char *str;
	asprintf(&str, "<m%s>%s</m%s>", B->str, strip_brackets(C->str), B->str);
	new->str = str;
	A = new;
}

s(A) ::= BINARY(B) s(C) s(D) .
{
	struct sym *new = malloc(sizeof(struct sym));
	char *str;
	/* TODO: maybe use B == syms[SYM_sqrt], check header deps */
	if(strcmp("sqrt", B->str) == 0){
		asprintf(&str, "<m%s>%s%s</m%s>", B->str, strip_brackets(C->str), strip_brackets(D->str), B->str);
	}
	else{
		asprintf(&str, "<m%s>%s%s</m%s>", B->str, strip_brackets(D->str), strip_brackets(C->str), B->str);
	}
	new->str = str;
	A = new;
}

i(A) ::= s(B). { A = B; }
i(A) ::= s(B) DIV s(C) .
{
	struct sym *new = malloc(sizeof(struct sym));
	char *str;
	asprintf(&str, "<mfrac>%s%s</mfrac>", strip_brackets(B->str), strip_brackets(C->str));
	new->str = str;
	A = new;
}
i(A) ::= s(B) SUB s(C) .
{
	struct sym *new = malloc(sizeof(struct sym));
	char *str;
	asprintf(&str, "<msub>%s%s</msub>", B->str, strip_brackets(C->str));
	new->str = str;
	A = new;
}
i(A) ::= s(B) SUP s(C) .
{
	struct sym *new = malloc(sizeof(struct sym));
	char *str;
	asprintf(&str, "<msup>%s%s</msup>", B->str, strip_brackets(C->str));
	new->str = str;
	A = new;
}
i(A) ::= s(B) SUB s(C) SUP s(D) .
{
	struct sym *new = malloc(sizeof(struct sym));
	char *str;
	if (B->pos == TOK_underover)
		asprintf(&str, "<munderover>%s%s%s</munderover>", B->str, strip_brackets(C->str), strip_brackets(D->str));
	else
		asprintf(&str, "<msubsup>%s%s%s</msubsup>", B->str, strip_brackets(C->str), strip_brackets(D->str));
	new->str = str;
	A = new;
}
i(A) ::= matrixList(B). { A = B; }

matrixList(A) ::= LEFT(B) commaList(C) COMMA matrixListLoop(D) RIGHT(E).
{
	struct sym *new = malloc(sizeof(struct sym));
	char *str;
	asprintf(&str, "<mrow><mo>%s</mo><mtable>%s%s</mtable><mo>%s</mo></mrow>", B->str, C->str, D->str, E->str);
	new->str = str;
	A = new;

}

matrixListLoop(A) ::= commaList(B). { A = B; }
matrixListLoop(A) ::= commaList(B) COMMA matrixListLoop(C).
{
	struct sym *new = malloc(sizeof(struct sym));
	char *str;
	asprintf(&str, "%s%s", B->str, C->str);
	new->str = str;
	A = new;
}

commaList(A) ::= LEFT i(B) COMMA commaListLoop(C) RIGHT.
{
	struct sym *new = malloc(sizeof(struct sym));
	char *str;
	asprintf(&str, "<mtr><mtd>%s</mtd>%s</mtr>", B->str, C->str);
	new->str = str;
	A = new;

}

commaListLoop(A) ::= i(B).
{
	struct sym *new = malloc(sizeof(struct sym));
	char *str;
	asprintf(&str, "<mtd>%s</mtd>", B->str);
	new->str = str;
	A = new;
}

commaListLoop(A) ::= i(B) COMMA commaListLoop(C).
{
	struct sym *new = malloc(sizeof(struct sym));
	char *str;
	asprintf(&str, "<mtd>%s</mtd>%s", B->str, C->str);
	new->str = str;
	A = new;
}

e(A) ::= i(B). { A = B; }
e(A) ::= i(B) e(C) .
{
	struct sym *new = malloc(sizeof(struct sym));
	char *str;
	asprintf(&str, "%s%s", B->str, C->str);
	new->str = str;
	A = new;
}
