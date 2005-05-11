/**
  * $Id: SGFileLocation.h,v 1.1.1.1 2005/05/11 17:51:44 tsawada2 Exp $
  * 
  * SGFileLocation.h
  *
  * Copyright (c) 2004, Takanori Ishikawa.
  * See the file LICENSE for copying permission.
  */

#import <Foundation/Foundation.h>
#import <SGFoundation/SGFoundationBase.h>

@class SGFileRef;

/*!
 * @class       SGFileLocation
 * @abstract    An Object represents file location.
 * @discussion
 *   An instance of SGFileLocation represents file location
 *   as file name (Unicode) and its parent directory reference.
 */
@interface SGFileLocation : SGBaseObject<NSCopying>
{
    @private
    SGFileRef  *m_directory;
    NSString   *m_name;
}
+ (id) fileLocationWithName : (NSString  *) aFileName
                  directory : (SGFileRef *) aDirectory;
- (id) initWithName : (NSString  *) aFileName
          directory : (SGFileRef *) aDirectory;

+ (id) fileLocationAtPath : (NSString  *) aFilePath;
- (id) initLocationAtPath : (NSString  *) aFilePath;

/* Resolve alias if needed. */
- (SGFileRef *) actualDirectory;
- (SGFileRef *) directory;
- (NSString *) name;

- (BOOL) exists;
- (SGFileRef *) fileRef;
- (NSString *) filepath;
@end
