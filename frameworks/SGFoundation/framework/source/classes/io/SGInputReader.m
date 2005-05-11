/**
  * $Id: SGInputReader.m,v 1.1.1.1 2005/05/11 17:51:44 tsawada2 Exp $
  * 
  * SGInputReader.m
  *
  * Copyright (c) 2004, Takanori Ishikawa.
  * See the file LICENSE for copying permission.
  */
#import "SGInputReader.h"
#import "UTILKit.h"



@implementation SGInputReader
- (int) read
{
	int     ret;
	unichar c;
	
	ret = [self read:&c 
				length:1 
				autualLength:NULL];
	return (EOF == ret) ? EOF : c;
}
- (int) read : (unichar  *) aBuffer
      length : (unsigned  ) aLength
autualLength : (unsigned *) autualLength
{ UTILAbstractMethodInvoked; return EOF; }
@end
