/**
  * $Id: CMRThreadAttributes.h,v 1.7 2007/02/24 18:03:37 tsawada2 Exp $
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


@interface CMRThreadAttributes : NSObject
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
- (void) setAAThread : (BOOL) flag; // deprecated. Use -setIsAAThread: instead.
- (void) setIsAAThread: (BOOL) flag;
// available in BathyScaphe 1.2 and later.
- (BOOL) isDatOchiThread;
- (void) setDatOchiThread : (BOOL) flag; // Deprecated. Use -setIsDatOchiThread: instead.
- (void) setIsDatOchiThread: (BOOL) flag;
- (BOOL) isMarkedThread;
- (void) setMarkedThread : (BOOL) flag; // Deprecated. Use -setIsMarkedThread: instead.
- (void) setIsMarkedThread: (BOOL) flag;
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

// Available in ReinforceII and later.
+ (NSURL *) threadURLWithDefaultParameterFromDictionary: (NSDictionary *) dict;

+ (void) replaceKeywords: (NSMutableString *) theBuffer dictionary: (NSDictionary *) theThread;
+ (void) replaceKeywords: (NSMutableString *) theBuffer attributes: (CMRThreadAttributes *) theThread;
+ (void) fillBuffer: (NSMutableString *) theBuffer withThreadInfoForCopying: (NSArray *) threadAttrsAry;
@end



extern NSString *const CMRThreadAttributesDidChangeNotification;
