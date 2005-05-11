//: NSURL-SGExtensions_p.h
/**
  * $Id: NSURL-SGExtensions_p.h,v 1.1 2005/05/11 17:51:45 tsawada2 Exp $
  * 
  * Copyright (c) 2001-2003, Takanori Ishikawa.
  * See the file LICENSE for copying permission.
  */

#import "NSURL-SGExtensions.h"
#import <SGFoundation/PrivateDefines.h>
#import <SGFoundation/NSString-SGExtensions.h>

#import <sys/syslimits.h>

@interface NSURL(SGExtensionsPrivate)
- (BOOL) getFileSystemReference : (FSRef      *) fileSystemRef
				 UTF8PathString : (const char *) pathString;

- (BOOL) getDividedPathWithUTF8PathString : (const char *) pathString
							 stringLength : (ByteCount   ) byteLength
								   prefix : (NSString  **) prefixPtr
			                       suffix : (NSString  **) suffixPtr;
- (BOOL) getFileSystemReference : (FSRef      *) fileSystemRef
					 prefixPath : (NSString *) prefix
					 suffixPath : (NSString *) suffix;
@end

