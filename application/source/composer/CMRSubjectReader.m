/**
  * $Id: CMRSubjectReader.m,v 1.4 2006/02/24 15:13:21 tsawada2 Exp $
  * 
  * CMRSubjectReader.m
  *
  * Copyright (c) 2003, Takanori Ishikawa.
  * See the file LICENSE for copying permission.
  */
#import "CocoMonar_Prefix.h"
#import "CMRSubjectReader.h"

#import "CMXTextParser.h"
#import "CMRThreadSubjectComposer.h"



/*
2channel互換やまちBBSのsubject.txtは行の末尾に
括弧などで囲まれている。
その囲んでいる文字列のセット（開き括弧のみ）
*/
static NSCharacterSet *CMXSubjectCountBracketSet(void);
// subject.txtから取得したタイトルを適切な形に変換
static NSString *preprocessWithTitle(NSString *aTitle);



@implementation CMRSubjectReader
APP_SINGLETON_FACTORY_METHOD_IMPLEMENTATION(reader);


- (BOOL) composeLine : (NSString             *) aLine
          lineNumber : (unsigned int          ) aLineNum
        withComposer : (id<CMRSubjectComposer>) aComposer
{
	NSCharacterSet		*bracketCSet_ = CMXSubjectCountBracketSet();
	NSArray				*components_;
	
	NSString			*identifier_ = nil;
	id					title_       = nil;
	unsigned int		resCount_    = NSNotFound;
	
	NSRange				resRange_;
	
	UTILAssertNotNil(aComposer);
	UTILRequireCondition(aLine && NO == [aLine isEmpty], ErrCompose);
	
	// subject.txtはなんらかの事情で区切り文字が混在する事があるようなので、
	// 毎行調べる
	// 区切り文字が不明の場合は処理しない
	//
	//   0 : dat識別子 （必須）
	//   1 : タイトル　（必須）--> レス数が末尾にくっついているかも
	//   2 : レス数　　（あるかも）
	
	components_ = [CMXTextParser separatedLine : aLine];
	UTILRequireCondition(components_ && [components_ count] >= 2, ErrCompose);
	//NSLog(@"%@",[components_ description]);
	// 識別子
	identifier_ = [components_ objectAtIndex : 0];
	identifier_ = [identifier_ stringByDeletingPathExtension];
	
	// タイトル
	title_ = [components_ objectAtIndex : 1];
	
	// ３つ目のフィールドがあった
	if([components_ count] >= 3){
		const char		*s;
		
		if((s = [[components_ objectAtIndex : 2] UTF8String]) != NULL){
			char	*endp;
			
			resCount_ = strtoul(s, &endp, 10);
			if(endp == s) resCount_ = NSNotFound;
		}
	}
	
	// まだレス数が決定していないということは三番目のフィールドがなかった
	// タイトル欄の末尾を調べて、それでもなければエラー
	if(NSNotFound == resCount_){
		NSString			*field_;
		NSScanner			*scanner_;
		int				resCount2_;
		
		// タイトルとレス数を調べる
		// レス数を取得。
		// タイトル部分の末尾に'<res>','(res)','（res）'のいずれか
		// の形式で記述されているので、タイトルの末尾から"<(（"いずれかを
		// 検索し、NSScannerで整数を得る。
		field_ = title_;
		resRange_ = 
		  [field_ rangeOfCharacterFromSet : bracketCSet_
		  						options : NSBackwardsSearch];
		UTILRequireCondition(
			resRange_.location != NSNotFound && resRange_.length != 0,
			ErrCompose);
		scanner_ = [NSScanner scannerWithString : field_];
		//最初の開き括弧は飛ばす
		//resCount_ = 0;
		resCount2_ = 0;
		[scanner_ setScanLocation : NSMaxRange(resRange_)];
		//if(NO == [scanner_ scanInt : &resCount_]){
		if(NO == [scanner_ scanInt : &resCount2_]){
			resCount_ = NSNotFound;
		} else {
			resCount_ = (unsigned int)resCount2_;
		}
		title_ = [field_ substringToIndex : resRange_.location];
	}
	title_ = preprocessWithTitle(title_);
	
	
	[aComposer composeIndex : aLineNum];
	[aComposer composeIdentifier : identifier_];
	[aComposer composeTitle : title_];
	[aComposer composeCount : resCount_];
	
	
	return YES;
	
ErrCompose:
	return NO;
}
@end



static NSCharacterSet *CMXSubjectCountBracketSet(void)
{
	static NSCharacterSet	*kResCountBracketSet;
	
	if(nil == kResCountBracketSet){
		NSString		*separaters_;
		
		separaters_ = NSLocalizedString(@"ResCount Separater", nil);
		UTILCAssertNotNil(separaters_);
		kResCountBracketSet = 
			[[NSCharacterSet 
				characterSetWithCharactersInString : separaters_] copy];
	}
	return kResCountBracketSet;
}
static NSString *preprocessWithTitle(NSString *aTitle)
{
	NSMutableString		*tmp = SGTemporaryString();
	NSString			*title_ = aTitle;
	
	if(nil == title_) return title_;
	
	[tmp setString : title_];
	[tmp replaceEntityReference];
		
	if(NO == [tmp isSameAsString : title_])
		title_ = [[tmp copy] autorelease];
	
	[tmp setString : @""];
	return title_;
}
