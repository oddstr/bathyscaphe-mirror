//:CMRBBSSignature.h
/**
  *
  * 掲示板オブジェクト
  *     (値オブジェクト・Property List)
  *
  * @author  Takanori Ishikawa
  * @author  http://www15.big.or.jp/~takanori/
  * @version Thu May 16 2002
  *
  */
#import <Foundation/Foundation.h>
#import <SGFoundation/SGFoundation.h>
#import <CocoMonar/CocoMonar.h>
#import "CMRHistoryObject.h"

@class SGFileRef;



@interface CMRBBSSignature : SGBaseObject<NSCopying, CMRHistoryObject, CMRPropertyListCoding>
{
	NSString		*_name;
}
+ (id) favoritesListSignature;
- (BOOL) isFavorites;

+ (id) BBSSignatureWithName : (NSString   *) bbsName;
- (id) initWithName : (NSString   *) bbsName;

- (NSString *) name;

//- (NSString *) dataRootDirectoryPath;	// Deprecated in PrincessBride and Later. Use CMRDocumentFileManager's
										// directoryWithBoardName: instead.
//- (NSString *) localSubjectTextPath;	// Deprecated in ShortCircuit and later.
//- (NSString *) threadsListPlistPath;	// Deprecated in PrincessBride and Later. Use CMRDocumentFileManager's
										// threadsListPathWithBoardName: instead.
//- (NSString *) threadsListPlistFileName;	// Deprecated in ShortCircuit and later.
@end
