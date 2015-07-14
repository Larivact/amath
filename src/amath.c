#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include "parser.h"
#include "scanner.h"
#include "symtypes.h"

void* ParseAlloc(void* (*allocProc)(size_t));
void Parse(void*, int, struct sym*, char**);
void ParseFree(void*, void(*freeProc)(void*));

char *amath_asciimath_to_mathml(char *text, size_t len)
{
	void *parser = ParseAlloc(malloc);
	char **cursor_ptr = &text;
	struct sym *cur_sym;
	char *f;

	do {
		cur_sym = scan(cursor_ptr, len);
		if(cur_sym->extra == TOK_ignore) continue;
		Parse(parser, cur_sym->type, cur_sym, &f);
	} while (cur_sym->type != 0);
	ParseFree(parser, free);

	return f;
}
