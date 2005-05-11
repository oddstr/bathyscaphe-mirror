//: NSURL-SGExtensions.h
/**
  * $Id: NSURL-SGExtensions.h,v 1.1 2005/05/11 17:51:45 tsawada2 Exp $
  * 
  * Copyright (c) 2001-2003, Takanori Ishikawa.
  * See the file LICENSE for copying permission.
  */

#import <Foundation/Foundation.h>
#import <CoreServices/CoreServices.h>


@interface NSURL(SGExtensions)
+ (id) URLWithLink : (id) aLink;
+ (id) URLWithLink : (id     ) anLink
	       baseURL : (NSURL *) baseURL;
+ (id) URLWithScheme : (NSString *) scheme
                host : (NSString *) host
                path : (NSString *) path;

- (NSString *) stringValue;
- (NSDictionary *) queryDictionary;

- (NSURL *) URLByAppendingPathComponent : (NSString *) pathComponent;
- (NSURL *) URLByDeletingLastPathComponent;


// Carbon FSRef/Alias
+ (id) fileURLWithFileSystemReference : (const FSRef *) fileSystemRef;
- (BOOL) getFileSystemReference : (FSRef *) fileSystemRef;
- (NSString *) fileSystemPathHFSStyle;
- (NSURL *) resolveAliasFile;
@end