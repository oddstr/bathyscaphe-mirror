//: CMRSubjectReader.h
/**
  * $Id: CMRSubjectReader.h,v 1.1 2005/05/11 17:51:04 tsawada2 Exp $
  * 
  * Copyright (c) 2001-2003, Takanori Ishikawa.
  * See the file LICENSE for copying permission.
  */

#import <Foundation/Foundation.h>
@protocol CMRSubjectComposer;


@interface CMRSubjectReader : NSObject
+ (id) reader;

- (BOOL) composeLine : (NSString             *) aLine
          lineNumber : (unsigned int          ) aLineNum
        withComposer : (id<CMRSubjectComposer>) composer;
@end
