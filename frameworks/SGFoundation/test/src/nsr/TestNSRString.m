//: TestNSRString.m
/**
  * $Id: TestNSRString.m,v 1.1 2005/05/11 17:51:46 tsawada2 Exp $
  * 
  * Copyright (c) 2001-2003, Takanori Ishikawa.
  * See the file LICENSE for copying permission.
  */

#import "TestNSRString.h"


@implementation TestNSRString
- (void) setUp
{
}
- (void) tearDown
{
}

- (void) test_nsr_strdup : (const char *) src
{
	char		*p;
	
	p = nsr_strdup(src);
	
	[self assertTrue : (p != NULL)
			 message : @"NULL"];
	[self assertTrue : strlen(src) == strlen(p)
			 message : @"strlen"];
	[self assertTrue : !(strcmp(src, p))
			 message : @"strcmp"];
	
	free(p);
}

- (void) test_nsr_strdup
{
	[self test_nsr_strdup : "This is a Test"];
	[self test_nsr_strdup : ""];
	[self test_nsr_strdup : "AAAAAAAAAAAAAAAAAAAAAAAA"];
}


- (void) test_nsr_strcasecmp
{
	char		*s1, *s2;
	
	s1 = ""; s2 = "";
	[self assertTrue : !(nsr_strcasecmp(s1, s2))
			 message : @"Empty"];
	s1 = "AAAA"; s2 = "AAAA";
	[self assertTrue : !(nsr_strcasecmp(s1, s2))
			 message : @"AAAA"];
	s1 = "AAAA"; s2 = "aaaa";
	[self assertTrue : !(nsr_strcasecmp(s1, s2))
			 message : @"AAAA aaaa"];

	s1 = "AAAA"; s2 = "AAAB";
	[self assertTrue : (nsr_strcasecmp(s1, s2)) < 0
			 message : @"AAAA AAAB"];
}

- (void) test_nsr_memcasestr
{
	const char	*s;
	
	s = "Hello, world!";
	[self assertTrue : (nsr_memcasestr(s, "HELLO", strlen(s)) != NULL)
			 message : [NSString stringWithCString : s]];
			   
	s = "Hello";
	[self assertTrue : (nsr_memcasestr(s, "HELLO", strlen(s)) != NULL)
			 message : [NSString stringWithCString : s]];
			   
	s = "Hell";
	[self assertTrue : (NULL == nsr_memcasestr(s, "HELLO", strlen(s)))
			 message : [NSString stringWithCString : s]];
	[self assertTrue : (NULL == nsr_memcasestr(s, NULL, strlen(s)))
			 message : [NSString stringWithCString : s]];
	[self assertTrue : (NULL == nsr_memcasestr(NULL, NULL, strlen(s)))
			 message : @"(NULL)"];

	[self assertTrue : (nsr_memcasestr("", "", strlen(s)) != NULL)
			 message : @"(Empty)"];
}
@end
