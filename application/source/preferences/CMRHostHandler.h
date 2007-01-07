//: CMRHostHandler.h
/**
  * $Id: CMRHostHandler.h,v 1.5 2007/01/07 17:04:23 masakih Exp $
  * 
  * Copyright (c) 2001-2003, Takanori Ishikawa.
  * See the file LICENSE for copying permission.
  */

#import <Foundation/Foundation.h>


@interface CMRHostHandler : NSObject
{

}
+ (id) hostHandlerForURL : (NSURL *) anURL;

// Managing subclasses
+ (BOOL) canHandleURL : (NSURL *) anURL;
+ (void) registerHostHandlerClass : (Class) aHostHandlerClass;

- (NSDictionary *) properties;
- (NSString *) name;
- (NSString *) identifier;

- (BOOL) canReadDATFile;

/*
----------------------------------------
CES (Code Encoding Scheme)
----------------------------------------
Shift JIS については対応する符号化文字集合として三つの
候補が考えられる。

  - JIS 規格に忠実な JIS X 0208:1997
  - MicroSoft 社の仕様
  - Apple 社の仕様

これらは以下の CFStringEncodings に対応する（括弧内は
CFStringConvertEncodingToIANACharSetName() の返す名前）

  - kCFStringEncodingShiftJIS (SHIFT_JIS)
  - kCFStringEncodingDOSJapanese (CP932)
  - kCFStringEncodingMacJapanese (X-MAC-JAPANESE)

CocoMonar の場合、たとえば新・mac 板では Mac Japanese の
コードが使われるケースもあるため、Shift JIS に関しては
これらすべてに対応するのが現実的だと思われる。

そのため、以下のメソッドでこれらの CFStringEncoding を
返した場合は
(1) まず、そのエンコーディングを試し
(2) それで変換できなければ残りのエンコーディングを次の順番で試す。
(3) 結果的に変換できなければエラー

  - kCFStringEncodingDOSJapanese
  - kCFStringEncodingMacJapanese
  - kCFStringEncodingShiftJIS

NOTE:
実際の変換ルーチンは CMXTextParser.h にある。
----------------------------------------
*/
- (CFStringEncoding) subjectEncoding;
- (CFStringEncoding) threadEncoding;

/* 
	anURL = 掲示板URLを含むURL
	bbs = 掲示板ディレクトリ名 
*/
- (NSURL *) boardURLWithURL : (NSURL    *) anURL
						bbs : (NSString *) bbs;
- (NSURL *) datURLWithBoard : (NSURL    *) boardURL
                    datName : (NSString *) datName;

- (NSDictionary *) readCGIProperties;
- (NSURL *) readURLWithBoard : (NSURL    *) boardURL;
- (NSURL *) readURLWithBoard : (NSURL    *) boardURL
                     datName : (NSString *) datName;
- (NSURL *) readURLWithBoard : (NSURL    *) boardURL
                     datName : (NSString *) datName
				 latestCount : (int) count;
- (NSURL *) readURLWithBoard : (NSURL    *) boardURL
                     datName : (NSString *) datName
				   headCount : (int) count;

- (NSURL *) readURLWithBoard : (NSURL    *) boardURL
                     datName : (NSString *) datName
					   start : (unsigned  ) startIndex
					     end : (unsigned  ) endIndex
					 nofirst : (BOOL      ) nofirst;

- (BOOL) parseParametersWithReadURL : (NSURL        *) link
                                bbs : (NSString    **) bbs
                                key : (NSString    **) key
                              start : (unsigned int *) startIndex
                                 to : (unsigned int *) endIndex
                          showFirst : (BOOL         *) showFirst;

- (NSURL *) rawmodeURLWithBoard: (NSURL    *) boardURL
						datName: (NSString *) datName
						  start: (unsigned  ) startIndex
							end: (unsigned  ) endIndex
						nofirst: (BOOL      ) nofirst;

// parse HTML
- (id) parseHTML : (NSString *) inputSource
			with : (id        ) thread
		   count : (unsigned  ) loadedCount;
@end



@interface CMRHostHandler(WriteCGI)
/* write.cgi parameter names */
#define CMRHostFormSubmitKey	@"submit"
#define CMRHostFormNameKey		@"name"
#define CMRHostFormMailKey		@"mail"
#define CMRHostFormMessageKey	@"message"
#define CMRHostFormBBSKey		@"bbs"
#define CMRHostFormIDKey		@"key"
#define CMRHostFormDirectoryKey	@"directory"
#define CMRHostFormTimeKey		@"time"
- (NSDictionary *) formKeyDictionary;

- (NSURL *) writeURLWithBoard : (NSURL *) boardURL;
- (NSString *) submitValue;
@end
