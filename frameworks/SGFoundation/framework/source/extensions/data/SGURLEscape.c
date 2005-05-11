//: SGURLEscape.c
/**
  * $Id: SGURLEscape.c,v 1.1 2005/05/11 17:51:44 tsawada2 Exp $
  * 
  * Copyright (c) 2001-2003, Takanori Ishikawa.
  * See the file LICENSE for copying permission.
  */

#include "SGURLEscape.h"
#include <ctype.h>

#include <stdio.h>
#include <stdlib.h>
#include <string.h>


static int isSymbolToBeUnescaped(unsigned char c)
{
	static const char _unescapeString[] = "*-._";
	
	if (isalnum(c))
		return 1;
	
	return (strchr(_unescapeString, c) != NULL);
}

char *SGURLEscape(const char *string, size_t length)
{
	size_t	allocsize = (length?length:strlen(string))+1;  
	char	*ns = malloc(allocsize);
	char	*testing_ptr = NULL;
	
	const    char *p = string;
	unsigned char c;
	auto     int  newlen = allocsize;
	auto     int  index  = 0;
	
	length = allocsize-1;
	while (length--) {
		c = *p;
		if (isSymbolToBeUnescaped(c)) {
			/* just copy this */
			ns[index++]=c;
		}else {
			/* encode it */
			newlen += 2; /* the size grows with two, since this'll become a %XX */
			if (newlen > allocsize) {
				allocsize *= 2;
				testing_ptr = realloc(ns, allocsize);
				if (!testing_ptr) {
					free( ns );
					return NULL;
				} else {
		  			ns = testing_ptr;
				}
			}
			sprintf(ns+index, "%%%02X", c);
			index+=3;
		}
		p++;
	}
	ns[index] = '\0'; /* terminate it */
	return ns;
}

char *SGURLUnescape(const char *string, size_t length)
{
	size_t	allocsize = (length?length:strlen(string))+1;  
	char	*ns = malloc(allocsize);
	
	const    char *p = string;
	unsigned char c;
	auto     int  index  = 0;
	unsigned int  hex;
	
	if (NULL == ns) return NULL;
	
	while (--allocsize > 0) {
		c = *p;
		if ('%' == c) {
			/* encoded part */
			if (sscanf(p+1, "%02X", &hex)) {
				c = hex;
				p+=2;
				allocsize-=2;
			}
		}else if ('+' == c) {
			c = ' ';
		}
		
		ns[index++] = c;
		p++;
	}
	ns[index] = '\0'; /* terminate it */
	return ns;
}
