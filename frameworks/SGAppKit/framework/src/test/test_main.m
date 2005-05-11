//: test_main.m
/**
  * $Id: test_main.m,v 1.1.1.1 2005/05/11 17:51:27 tsawada2 Exp $
  * 
  * Copyright (c) 2001-2003, Takanori Ishikawa.  All rights reserved.
  * See the file LICENSE for copying permission.
  */

#import <ObjcUnit/ObjcUnit.h>
#import "AllTest.h"

int main(int argv, char *argc[])
{
	TestRunnerMain([AllTests class]);
	
	return 0;
}