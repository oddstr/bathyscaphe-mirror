//:ThreadTextDownloader_p.h
#import "ThreadTextDownloader.h"
#import "CMRDownloader_p.h"

#import "CocoMonar_Prefix.h"

#import "AppDefaults.h"
#import "CMRDocumentFileManager.h"

#import "CMRThreadPlistComposer.h"
#import "CMR2chDATReader.h"
#import "CMRThreadSignature.h"
//#import "CMRBBSSignature.h"
#import "CMRHostHandler.h"

#import "BoardManager.h"




@interface ThreadTextDownloader(ThreadDataArchiver)
- (BOOL) synchronizeLocalDataWithContents : (NSString   *) datContents
							   dataLength : (unsigned int) dataLength;
- (NSDictionary *) dictionaryByAppendingContents : (NSString   *) datContents
									  dataLength : (unsigned int) dataLength;
@end


