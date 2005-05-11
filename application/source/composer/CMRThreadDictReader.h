/**
  * $Id: CMRThreadDictReader.h,v 1.1.1.1 2005/05/11 17:51:04 tsawada2 Exp $
  * 
  * CMRThreadDictReader.h
  *
  * Copyright (c) 2003, Takanori Ishikawa.
  * See the file LICENSE for copying permission.
  */
#import <Foundation/Foundation.h>
#import "CMRThreadContentsReader.h"


@class CMRThreadVisibleRange;

@interface CMRThreadDictReader : CMRThreadContentsReader
{
	@private
	id		_attributes;	/* threadAttributes cache */
}
@end
