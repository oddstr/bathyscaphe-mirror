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
Shift JIS �ɂ��Ă͑Ή����镄���������W���Ƃ��ĎO��
��₪�l������B

  - JIS �K�i�ɒ����� JIS X 0208:1997
  - MicroSoft �Ђ̎d�l
  - Apple �Ђ̎d�l

�����͈ȉ��� CFStringEncodings �ɑΉ�����i���ʓ���
CFStringConvertEncodingToIANACharSetName() �̕Ԃ����O�j

  - kCFStringEncodingShiftJIS (SHIFT_JIS)
  - kCFStringEncodingDOSJapanese (CP932)
  - kCFStringEncodingMacJapanese (X-MAC-JAPANESE)

CocoMonar �̏ꍇ�A���Ƃ��ΐV�Emac �ł� Mac Japanese ��
�R�[�h���g����P�[�X�����邽�߁AShift JIS �Ɋւ��Ă�
����炷�ׂĂɑΉ�����̂������I���Ǝv����B

���̂��߁A�ȉ��̃��\�b�h�ł����� CFStringEncoding ��
�Ԃ����ꍇ��
(1) �܂��A���̃G���R�[�f�B���O������
(2) ����ŕϊ��ł��Ȃ���Ύc��̃G���R�[�f�B���O�����̏��ԂŎ����B
(3) ���ʓI�ɕϊ��ł��Ȃ���΃G���[

  - kCFStringEncodingDOSJapanese
  - kCFStringEncodingMacJapanese
  - kCFStringEncodingShiftJIS

NOTE:
���ۂ̕ϊ����[�`���� CMXTextParser.h �ɂ���B
----------------------------------------
*/
- (CFStringEncoding) subjectEncoding;
- (CFStringEncoding) threadEncoding;

/* 
	anURL = �f����URL���܂�URL
	bbs = �f���f�B���N�g���� 
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
