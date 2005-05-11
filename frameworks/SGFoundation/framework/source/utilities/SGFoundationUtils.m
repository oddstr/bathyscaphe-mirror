/**
  * $Id: SGFoundationUtils.m,v 1.1 2005/05/11 17:51:45 tsawada2 Exp $
  * 
  * SGFoundationUtils.m
  *
  * Copyright (c) 2004 Takanori Ishikawa, All rights reserved.
  * See the file LICENSE for copying permission.
  */

#import <Foundation/Foundation.h>
#import "SGNSR.h"
#import "UTILKit.h"
#import <ctype.h>
#import <zlib.h>



// for debugging only
#define UTIL_DEBUGGING		0
#import "UTILDebugging.h"



void *nsr_strncasestr(const char *str, const char *find, size_t length)
{
	char		c;
	size_t		n;
	char		*p = (char*)str;
	
	if (NULL == str || NULL == find)
		return NULL;
	if ( 0 == (n = strlen(find)) )
		return p;
	
	c = tolower(*find);
	for (; length >= n; p++, length--) {
		if (tolower(*p) == c && 0 == nsr_strncasecmp(p, find, n))
			return p;
	}
	
	return NULL;
}
void *nsr_strnstr(const char *str, const char *find, size_t length)
{
	char		c;
	size_t		n;
	char		*p = (char*)str;
	
	if (NULL == str || NULL == find)
		return NULL;
	if ( 0 == (n = strlen(find)) )
		return p;
	
	c = *find;
	for (; length >= n; p++, length--) {
		if (*p == c && 0 == strncmp(p, find, n))
			return p;
	}
	
	return NULL;
}



/*
 **********************************************************
 ************************** ZLIB **************************
 **********************************************************
 */
#define ZLIB_BYTE	Bytef
#define ZLIB_UINT	uInt
#define ZLIB_ULONG	uLongf

#define ZLIB_INFLATEEND(zstrm)			inflateEnd(zstrm)
#define ZLIB_INFLATEINIT2(zstrm, bits)	inflateInit2(zstrm, bits)

/* gzip flag byte */
#define ASCII_FLAG   0x01 /* bit 0 set: file probably ascii text */
#define HEAD_CRC     0x02 /* bit 1 set: header CRC present */
#define EXTRA_FIELD  0x04 /* bit 2 set: extra field present */
#define ORIG_NAME    0x08 /* bit 3 set: original file name present */
#define COMMENT      0x10 /* bit 4 set: file comment present */
#define RESERVED     0xE0 /* bits 5..7: reserved */


/* gzip magic header */
static const ZLIB_BYTE kGZIPMagicHeaderBytes[2] = {0x1f, 0x8b};
#define OUT_BUFSIZE   1024



static BOOL skipGZIPHeader_(z_stream *zStrm)
{
	int			i;
	ZLIB_BYTE	c;
	
	// GZIP Header
	ZLIB_BYTE	method;		// method byte
	ZLIB_BYTE	flags;		// flags byte
	
	UTIL_DEBUG_FUNCTION;
	UTIL_DEBUG_WRITE1(@"  zStrm->avail_in=%u.", zStrm->avail_in);
	// 
	// GZIP圧縮されていることを表す
	// 2バイトの先頭ヘッダを読む
	//
	UTIL_DEBUG_WRITE(@" zip magic numbers:");
	UTILDebugRequire((zStrm->avail_in >= 2), ErrSkipHeader,
		@"Require 2 bytes for zip magic numbers.");
	for (i = 0; i < 2; i++) {
		c = *zStrm->next_in++;
		zStrm->avail_in--;
		
		UTILRequireCondition(kGZIPMagicHeaderBytes[i] == c, ErrSkipHeader);
	}
	UTIL_DEBUG_WRITE1(@"  zStrm->avail_in=%u.", zStrm->avail_in);
	
	
	// compression method, and flags
	UTIL_DEBUG_WRITE(@" compression method, and flags:");
	UTILDebugRequire((zStrm->avail_in >= 2), ErrSkipHeader,
		@"Require 2 bytes for compression method, and flags.");
	method = *zStrm->next_in++; zStrm->avail_in--;
	flags = *zStrm->next_in++; zStrm->avail_in--;
	UTILDebugRequire(Z_DEFLATED == method && 0 == (flags & RESERVED),
		ErrSkipHeader,
		@"data has not Z_DEFLATED method header, or use RESERVED flags.");
	UTIL_DEBUG_WRITE1(@"  zStrm->avail_in=%u.", zStrm->avail_in);
	
	
    /* Discard time, xflags and OS code: */
	UTIL_DEBUG_WRITE(@" Discard time, xflags and OS code:");
	UTILDebugRequire((zStrm->avail_in >= 6), ErrSkipHeader,
		@"Require 6 bytes for Discard time, xflags and OS code.");
	
	zStrm->next_in += 6; zStrm->avail_in -= 6;
	UTIL_DEBUG_WRITE1(@"  zStrm->avail_in=%u.", zStrm->avail_in);
	
	
	UTIL_DEBUG_WRITE(@" EXTRA_FIELD:");
	if ((flags & EXTRA_FIELD) != 0) { /* skip the extra field */
		ZLIB_UINT	efLen = 0;
		
		
		UTILDebugRequire((zStrm->avail_in >= 6), ErrSkipHeader,
			@"Require 6 bytes for the extra field length.");
		efLen += (ZLIB_UINT)(*zStrm->next_in++);
		efLen += (ZLIB_UINT)(*zStrm->next_in++) << 8;
		
		UTIL_DEBUG_WRITE1(@" EXTRA_FIELD: length=%u.", efLen);
		UTILDebugRequire1((zStrm->avail_in >= efLen), ErrSkipHeader,
			@"Require %u bytes for the extra field.", efLen);
		/* i is garbage if EOF but the loop below will quit anyway */
		while (efLen-- != 0 && zStrm->avail_in > 0) {
			zStrm->next_in++; zStrm->avail_in--;
		}
	}
	UTIL_DEBUG_WRITE1(@"  zStrm->avail_in=%u.", zStrm->avail_in);
	
	
	UTIL_DEBUG_WRITE(@" ORIG_NAME:");
	if ((flags & ORIG_NAME) != 0) { /* skip the original file name */
		UTIL_DEBUG_WRITE1(@"  Original Name: %s", zStrm->next_in);
		while ((c = *zStrm->next_in++) != 0 && zStrm->avail_in > 0) 
			zStrm->avail_in--;
	}
	UTIL_DEBUG_WRITE1(@"  zStrm->avail_in=%u.", zStrm->avail_in);
	
	UTIL_DEBUG_WRITE(@" COMMENT:");
	if ((flags & COMMENT) != 0) {   /* skip the .gz file comment */
		UTIL_DEBUG_WRITE1(@"  Comment: %s", zStrm->next_in);
		while ((c = *zStrm->next_in++) != 0 && zStrm->avail_in > 0) 
			zStrm->avail_in--;
	}
	UTIL_DEBUG_WRITE1(@"  zStrm->avail_in=%u.", zStrm->avail_in);
	
	
	UTIL_DEBUG_WRITE(@" HEAD_CRC:");
	if ((flags & HEAD_CRC) != 0) {  /* skip the header crc */
		UTILDebugRequire((zStrm->avail_in >= 2), ErrSkipHeader,
			@"Require 2 bytes for header crc.");
		zStrm->next_in += 2; zStrm->avail_in -= 2;
	}
	UTIL_DEBUG_WRITE1(@"  zStrm->avail_in=%u.", zStrm->avail_in);
	
	return YES;

ErrSkipHeader:
	return NO;
}

#define ZIP_HEADER_MIN_LENGTH	10
#define DECOMPRESED_MULT		3
id SGUtilUngzip(NSData *aData)
{
	z_stream	zStream;			// zlib
	int			status = Z_OK;		// 展開の状況
	int			cnt;
	size_t		bufCapacity = 0;
	/* 出力バッファ */
	ZLIB_BYTE outbuf[OUT_BUFSIZE];	
	NSMutableData	*outData = nil;
	
	UTIL_DEBUG_FUNCTION;
	bufCapacity = [aData length];
	if (nil == aData || bufCapacity < ZIP_HEADER_MIN_LENGTH)
		return nil;
	
	UTIL_DEBUG_WRITE1(@"SourceLength = %u.", [aData length]);
	bufCapacity -= ZIP_HEADER_MIN_LENGTH;
	bufCapacity = bufCapacity * DECOMPRESED_MULT;
	UTIL_DEBUG_WRITE1(@"bufCapacity = %u.", bufCapacity);
	
	/* 初期化 */
	zStream.zalloc = Z_NULL; /* used to allocate the internal state */
	zStream.zfree  = Z_NULL; /* used to free the internal state */
	zStream.opaque = Z_NULL; /* private data object passed to zalloc and zfree */
	
	zStream.next_in = (ZLIB_BYTE*)[aData bytes];
	zStream.avail_in = (ZLIB_UINT)[aData length];
	zStream.next_out  = outbuf;
	zStream.avail_out = OUT_BUFSIZE;
	
	/*
	inflateInit2(z_stream *strm, int  windowBits)
	
	windowBits: 
	(8 .. 15)
	the base two logarithm of the maximum window
	size (the size of the history buffer) 
	(-8 .. -15)
	In this case, -windowBits determines the window size.
	inflate() will then process raw deflate data, not looking for
	a zlib or gzip header,
	*/
	UTILDebugRequire(
		Z_OK == ZLIB_INFLATEINIT2(&zStream, -MAX_WBITS),
		ZlibInflateEnd,
		@"ZLIB_INFLATEINIT2");
	
	// ヘッダを解析
	UTILDebugRequire(
		skipGZIPHeader_(&zStream),
		ZlibInflateEnd,
		@"skipGZIPHeader_");
	
	// 展開処理
	if (bufCapacity > 1024)
		outData = [NSMutableData dataWithCapacity : bufCapacity];
	else
		outData = [NSMutableData data];
	
	while (status != Z_STREAM_END) {
		if (0 == zStream.avail_in) 
			break;
		
		// 展開
		status = inflate(&zStream, Z_NO_FLUSH);
		
		// ステータスをチェックし、展開を続けるかを判断
		if (Z_STREAM_END == status) break;
		if (status != Z_OK) {
			outData = nil;
			goto ZlibInflateEnd;
		}
		
		// 出力バッファが一杯になった。別のバッファに追加していく
		if (0 == zStream.avail_out) {
			UTIL_DEBUG_WRITE1(@"  buffer appendBytes:%u", OUT_BUFSIZE);
			[outData appendBytes:outbuf length:OUT_BUFSIZE];
			zStream.next_out  = outbuf;			/* 出力ポインタを元に戻す */
			zStream.avail_out = OUT_BUFSIZE;	/* 出力バッファ残量を元に戻す */
		}
	}
	/* 残りを吐き出す */
	if ((cnt = OUT_BUFSIZE - zStream.avail_out) != 0) {
		UTIL_DEBUG_WRITE1(@"  buffer appendBytes:%u", cnt);
		[outData appendBytes:outbuf length:cnt];
	}
	

ZlibInflateEnd:
	if (ZLIB_INFLATEEND(&zStream) != Z_OK)
		return nil;
	
	UTIL_DEBUG_WRITE1(@"  buffer size:%u", [outData length]);
	return outData;
}


id SGUtilUngzipIfNeeded(NSData *aData)
{
	id		ret;
	
	return nil == (ret = SGUtilUngzip(aData)) ? aData : ret;
}
