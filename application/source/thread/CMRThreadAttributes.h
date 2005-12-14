/**
  * $Id: CMRThreadAttributes.h,v 1.1.1.1.4.1 2005/12/14 16:05:06 masakih Exp $
  * 
  * CMRThreadAttributes.h
  *
  * Copyright (c) 2003, Takanori Ishikawa.
  * See the file LICENSE for copying permission.
  */

#import <SGFoundation/SGFoundation.h>

//@class CMRBBSSignature;
@class CMRThreadSignature;
@class CMRThreadVisibleRange;


@interface CMRThreadAttributes : SGBaseObject
{
	@private
	BOOL					_changed;		/* needs to write file */
	NSMutableDictionary		*_attributes;	/* contains all properties */
}
- (id) initWithDictionary : (NSDictionary   *) info;
- (NSDictionary *) dictionaryRepresentation;
- (void) addEntriesFromDictionary : (NSDictionary *) newAttrs;
- (void) writeAttributes : (NSMutableDictionary *) aDictionary;



//- (CMRBBSSignature *) BBSSignature;// Deprecated in TestaRossa and later. use -(NSString *) boardName directly instead.
- (CMRThreadSignature *) threadSignature;
- (NSString *) bbsIdentifier;
- (NSString *) datIdentifier;

- (BOOL) needsToBeUpdatedFromLoadedContents;
- (BOOL) needsToUpdateLogFile;
- (void) setNeedsToUpdateLogFile : (BOOL) flag;

- (unsigned) numberOfLoadedMessages;
- (void) setNumberOfLoadedMessages : (unsigned) nLoaded;

- (unsigned) numberOfMessages;

- (NSString *) path;
- (NSString *) threadTitle;
- (NSString *) boardName;
- (NSURL *) boardURL;
- (NSURL *) threadURL;
- (NSRect) windowFrame;
- (void) setWindowFrame : (NSRect) newFrame;
- (unsigned) lastIndex;
- (void) setLastIndex : (unsigned) anIndex;


- (CMRThreadVisibleRange *) visibleRange;
- (void) setVisibleRange : (CMRThreadVisibleRange *) newRange;

@end



/* working with CMRThreadUserStatus */
@interface CMRThreadAttributes(UserStatus)
- (BOOL) isAAThread;
- (void) setAAThread : (BOOL) flag;
@end



@interface CMRThreadAttributes(Converter)
+ (BOOL) isNewThreadFromDictionary : (NSDictionary *) dict;
+ (int) numberOfUpdatedFromDictionary : (NSDictionary *) dict;
+ (NSString *) pathFromDictionary : (NSDictionary *) dict;
+ (NSString *) identifierFromDictionary : (NSDictionary *) dict;

+ (NSString *) boardNameFromDictionary : (NSDictionary *) dict;
+ (NSString *) threadTitleFromDictionary : (NSDictionary *) dict;
+ (NSDate *) createdDateFromDictionary : (NSDictionary *) dict;
+ (NSDate *) modifiedDateFromDictionary : (NSDictionary *) dict;

+ (NSURL *) boardURLFromDictionary : (NSDictionary *) dict;
+ (NSURL *) threadURLFromDictionary : (NSDictionary *) dict;
// Deprecated in LittleWish and later.
//+ (NSURL *) threadURLFromDictionary : (NSDictionary *) dict withParamStr : (NSString *) paramStr;

// Available in LittleWish and later.
+ (NSURL *) threadURLWithLatestParamFromDict : (NSDictionary *) dict resCount : (int) count;
+ (NSURL *) threadURLWithHeaderParamFromDict : (NSDictionary *) dict resCount : (int) count;
@end



extern NSString *const CMRThreadAttributesDidChangeNotification;
