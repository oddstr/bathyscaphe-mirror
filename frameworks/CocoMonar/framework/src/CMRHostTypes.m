/**
  * $Id: CMRHostTypes.m,v 1.1.1.1.4.1 2005/12/14 16:05:06 masakih Exp $
  * 
  * CMRHostTypes.m
  *
  * Copyright (c) 2003, Takanori Ishikawa.
  * See the file LICENSE for copying permission.
  */

#import "CMRHostTypes.h"
#import <SGFoundation/SGFoundation.h>
#import "UTILKit.h"



const char *CMRGetHostCStringFromBoardURL(NSURL *anURL, const char **pbbs)
{
	NSMutableData *buffer  = nil;
	
	const char	*path_;
	const char	*host_;
	size_t		bufSize;
	size_t		pathsize;
	char		*p;
	size_t		n;
	
	if(pbbs != NULL) *pbbs = NULL;
	if(NULL == anURL || NULL == (path_ = [[anURL absoluteString] UTF8String]))
		return NULL;
	
	
	pathsize = strlen(path_) * sizeof(char) + 1;
	
	buffer = SGTemporaryData();
	bufSize = [buffer length];
	if(bufSize < pathsize)
		[buffer setLength : pathsize];
	
	bufSize = [buffer length];
	p = (char*)[buffer mutableBytes];
	
	memset(p, bufSize, '\0');
	memmove(p, path_, pathsize);
	
	p = (char*)[[anURL scheme] UTF8String];
	if(NULL == p) return NULL;
	n = strlen(p);
	
	// http://pc.2ch.net/mac
	host_ = [buffer mutableBytes];
	// ://pc.2ch.net/mac
	host_ += n;
	
	// //pc.2ch.net/mac
	if(*host_ != ':') return NULL;
	host_++;
	
	// pc.2ch.net/mac
	while('/' == *host_)
		host_++;
	
	while(1){
		p = strrchr(host_, '/');
		if(NULL == p)
			return host_;
		
		*p = '\0';
		if(*(p +1) != '\0')
			break;
	}
	
	if(pbbs != NULL) *pbbs = ++p;
	
	return host_;
}

NSString *CMRGetHostStringFromBoardURL(NSURL *anURL, NSString **pbbs)
{
	const char	*host_;
	const char	*bbs_ = NULL;
	
	host_ = CMRGetHostCStringFromBoardURL(anURL, (pbbs ? &bbs_ : NULL));
	
	if(pbbs != NULL)
		*pbbs = bbs_ ? [NSString stringWithUTF8String : bbs_] : nil;
	
	return [NSString stringWithUTF8String : host_];
}
NSString *CMRGetHostStringFromBoardURLNoCopy(NSURL *anURL, NSString **pbbs)
{
	const char	*host_;
	const char	*bbs_ = NULL;
	
	host_ = CMRGetHostCStringFromBoardURL(anURL, (pbbs ? &bbs_ : NULL));
	if(pbbs != NULL)
		*pbbs =  bbs_ ? [NSString stringWithCStringNoCopy:bbs_] : nil;
	
	return [NSString stringWithCStringNoCopy:host_];
}

/*
 * read.cgiがパス仕様に対応していると期待できるか
 * 過去ログ倉庫、offlaw、板トップURLの判定などでも流用
 */
bool can_readcgi(const char *host)
{
	const char	*p;
	char		*ep;
	long		l;
	
	if(NULL == host) return false;
	
	if (strstr(host, ".2ch.net"))
		return !strstr(host, "tako") && !strstr(host, "piza.");
	if (strstr(host, ".bbspink.com"))
		return !strstr(host, "www.");
	/* 64.71.128.0/18 216.218.128.0/17 のテスト */
	p = strstr(host, "64.71.");
	if (p) {
		l = strtol(p + 6, &ep, 10);
		if (*ep == '.' && (l & 0xc0) == 128)
			return true;
	}
	p = strstr(host, "216.218.");
	if (p) {
		l = strtol(p + 8, &ep, 10);
		if (*ep == '.' && (l & 0x80) == 128)
			return true;
	}
	return strstr(host, ".he.net") != NULL;
}
bool is_2channel(const char *host)
{
	return can_readcgi(host);
}
//
bool is_be2ch(const char *host)
{
	return host ? strstr(host, "be.2ch.net") != NULL && can_readcgi(host) : true;
}

bool is_2ch_belogin_needed(const char *host)
{
	if (host != NULL) {
		return strstr(host, "be.2ch.net") != NULL ||
			   strstr(host, "qa.2ch.net") != NULL;
	}
	return false;
}

bool is_jbbs_shita(const char *host)
{
	if (host != NULL) {
		return strstr(host, "jbbs.shitaraba.com") != NULL ||
			   strstr(host, "jbbs.livedoor.jp") != NULL ||
			   strstr(host, "jbbs.livedoor.com") != NULL;
	}
	return false;
}

bool is_machi(const char *host)
{
	return host ? strstr(host, ".machi.to") || strstr(host, ".machibbs.com") : false;
}

bool is_jbbs(const char *host)
{
	return host ? strstr(host, ".jbbs.net") || is_jbbs_shita(host) : false;
}

bool is_shitaraba(const char *host)
{
	return host ? strstr(host, ".shitaraba.com") != NULL && !is_jbbs_shita(host) : false;
}

bool is_tanteifile(const char *host)
{
	return host ? strstr(host, "tanteifile2.gasuki.com") : false;
}


/*
 * offlaw.cgiが使えるかどうか
 */
bool can_offlaw(const char *host)
{
	return false;
//	return can_readcgi(host) && strstr(host, "choco.");
}


/*
 * 過去ログ倉庫が新形式かどうか
 */
bool kako_salad(const char *host, const char *bbs)
{
	static char *oldkako_servers[] = {
		"piza.",
		"www.bbspink",
		NULL,
	};
	int i;

	if (!can_readcgi(host))
		return false;

	for (i = 0; oldkako_servers[i]; i++) {
		if (strstr(host, oldkako_servers[i]))
			return false;
	}

	if (strstr(host, "mentai.2ch.net")) {
//debugout && fprintf(debugout, "kako_salad: bbs=%s\n", bbs);
		if(strstr(bbs, "mukashi/"))
			return false;
	}

	if (strstr(host, "www.2ch.net")) {
//debugout && fprintf(debugout, "kako_salad: bbs=%s\n", bbs);
		if(strstr(bbs, "tako/") || strstr(bbs, "kitanet/"))
			return false;
	}

	return true;
}

/*
 * bbs.cgiが新タイプかどうか
 */
bool bbs_qb(const char *host)
{
#if 0
	static char *newbbs_servers[] = {
//		"qb.",
		"ex.",
		"choco.",
		"comic.",
		"music.",
		"teri.",
//		"cocoa.",
		"game.",
		"oyster.",
		NULL,
	};
	int i;

	if (!can_readcgi(host))
		return false;

	for (i = 0; newbbs_servers[i]; i++) {
		if (strstr(host, newbbs_servers[i]))
			return true;
	}

#endif
	return false;
}
