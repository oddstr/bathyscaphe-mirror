//: SGBase64.c
/**
  * $Id: SGBase64.c,v 1.1.1.1 2005/05/11 17:51:44 tsawada2 Exp $
  * 
  * Copyright (c) 2001-2003, Takanori Ishikawa.
  * See the file LICENSE for copying permission.
  */

#include "SGBase64.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>



static void decodeQuantum(unsigned char *dest, const char *src)
{
  unsigned int x = 0;
  int i;
  for(i = 0; i < 4; i++) {
    if(src[i] >= 'A' && src[i] <= 'Z')
      x = (x << 6) + (unsigned int)(src[i] - 'A' + 0);
    else if(src[i] >= 'a' && src[i] <= 'z')
      x = (x << 6) + (unsigned int)(src[i] - 'a' + 26);
    else if(src[i] >= '0' && src[i] <= '9') 
      x = (x << 6) + (unsigned int)(src[i] - '0' + 52);
    else if(src[i] == '+')
      x = (x << 6) + 62;
    else if(src[i] == '/')
      x = (x << 6) + 63;
    else if(src[i] == '=')
      x = (x << 6);
  }

  dest[2] = (unsigned char)(x & 255); x >>= 8;
  dest[1] = (unsigned char)(x & 255); x >>= 8;
  dest[0] = (unsigned char)(x & 255); x >>= 8;
}


/* ---- Base64 Encoding --- */
static char table64[]=
  "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
  
int SGBase64Encode(const void *inp, size_t insize, char **outptr)
{
	unsigned char ibuf[3];
	unsigned char obuf[4];
	int i;
	int inputparts;
	char *output;
	char *base64data;
	
	char *indata = (char *)inp;
	
	if(0 == insize)
	insize = strlen(indata);
	
	base64data = output = (char*)malloc(insize*4/3+4);
	if(NULL == output)
	return -1;
	
	while(insize > 0) {
		for (i = inputparts = 0; i < 3; i++) { 
			if(insize > 0) {
				inputparts++;
				ibuf[i] = *indata;
				indata++;
				insize--;
			}else{
				ibuf[i] = 0;
			}
		}
		                   
		obuf [0] = (ibuf [0] & 0xFC) >> 2;
		obuf [1] = ((ibuf [0] & 0x03) << 4) | ((ibuf [1] & 0xF0) >> 4);
		obuf [2] = ((ibuf [1] & 0x0F) << 2) | ((ibuf [2] & 0xC0) >> 6);
		obuf [3] = ibuf [2] & 0x3F;
		
		switch(inputparts){
		case 1: /* only one byte read */
			sprintf(output, "%c%c==", 
				table64[obuf[0]],
				table64[obuf[1]]);
			break;
		case 2: /* two bytes read */
			sprintf(output, "%c%c%c=", 
				table64[obuf[0]],
				table64[obuf[1]],
				table64[obuf[2]]);
			break;
		default :
			sprintf(output, "%c%c%c%c", 
				table64[obuf[0]],
				table64[obuf[1]],
				table64[obuf[2]],
				table64[obuf[3]] );
			break;
		}
		output += 4;
	}
	*output=0;
	*outptr = base64data; /* make it return the actual data memory */
	
	return strlen(base64data); /* return the length of the new data */
}

int SGBase64Decode(const char *src, unsigned char *dest)
{
	int ret = 0;
	int length = 0;
	int equalsTerm = 0;
	int i;
	int numQuantums;
	unsigned char lastQuantum[3];
	
	while((src[length] != '=') && src[length])
		length++;
	while(src[length+equalsTerm] == '=')
		equalsTerm++;
	
	numQuantums = (length + equalsTerm) / 4;
	ret = (numQuantums * 3) - equalsTerm;
	
	for(i = 0; i < numQuantums - 1; i++) {
		decodeQuantum(dest, src);
		dest += 3; src += 4;
	}
	
	decodeQuantum(lastQuantum, src);
	for(i = 0; i < 3 - equalsTerm; i++)
	dest[i] = lastQuantum[i];
	
	return ret;
}
