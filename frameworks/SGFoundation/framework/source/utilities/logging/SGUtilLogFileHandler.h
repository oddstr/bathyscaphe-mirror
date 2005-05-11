//: SGUtilLogFileHandler.h
/**
  * $Id: SGUtilLogFileHandler.h,v 1.1 2005/05/11 17:51:45 tsawada2 Exp $
  * 
  * Copyright (c) 2001-2003, Takanori Ishikawa.  All rights reserved.
  * See the file LICENSE for copying permission.
  */

/*!
 * @header     SGFoundation Logging API -- SGUtilLogHandler class
 * @discussion SGUtilLogFileHandler
 */


#import <Foundation/Foundation.h>
#import <SGFoundation/SGUtilLogHandler.h>


@interface SGUtilLogFileHandler : SGUtilLogHandler
{
	NSFileHandle		*_fileHandle;
}
+ (id) logHandlerWithFileHandle : (NSFileHandle *) fhandle;
- (id) initWithFileHandle : (NSFileHandle *) fhandle;

- (NSFileHandle *) fileHandle;
- (void) setFileHandle : (NSFileHandle *) aFileHandle;
@end



@interface SGUtilLogConsoleHandler : SGUtilLogFileHandler
@end
