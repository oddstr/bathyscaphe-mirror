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
2channel�݊���܂�BBS��subject.txt�͍s�̖�����
���ʂȂǂň͂܂�Ă���B
���̈͂�ł��镶����̃Z�b�g�i�J�����ʂ̂݁j
*/
static NSCharacterSet *CMXSubjectCountBracketSet(void);
// subject.txt����擾�����^�C�g����K�؂Ȍ`�ɕϊ�
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
	
	// subject.txt�͂Ȃ�炩�̎���ŋ�؂蕶�������݂��鎖������悤�Ȃ̂ŁA
	// ���s���ׂ�
	// ��؂蕶�����s���̏ꍇ�͏������Ȃ�
	//
	//   0 : dat���ʎq �i�K�{�j
	//   1 : �^�C�g���@�i�K�{�j--> ���X���������ɂ������Ă��邩��
	//   2 : ���X���@�@�i���邩���j
	
	components_ = [CMXTextParser separatedLine : aLine];
	UTILRequireCondition(components_ && [components_ count] >= 2, ErrCompose);
	//NSLog(@"%@",[components_ description]);
	// ���ʎq
	identifier_ = [components_ objectAtIndex : 0];
	identifier_ = [identifier_ stringByDeletingPathExtension];
	
	// �^�C�g��
	title_ = [components_ objectAtIndex : 1];
	
	// �R�ڂ̃t�B�[���h��������
	if([components_ count] >= 3){
		const char		*s;
		
		if((s = [[components_ objectAtIndex : 2] UTF8String]) != NULL){
			char	*endp;
			
			resCount_ = strtoul(s, &endp, 10);
			if(endp == s) resCount_ = NSNotFound;
		}
	}
	
	// �܂����X�������肵�Ă��Ȃ��Ƃ������Ƃ͎O�Ԗڂ̃t�B�[���h���Ȃ�����
	// �^�C�g�����̖����𒲂ׂāA����ł��Ȃ���΃G���[
	if(NSNotFound == resCount_){
		NSString			*field_;
		NSScanner			*scanner_;
		int				resCount2_;
		
		// �^�C�g���ƃ��X���𒲂ׂ�
		// ���X�����擾�B
		// �^�C�g�������̖�����'<res>','(res)','�ires�j'�̂����ꂩ
		// �̌`���ŋL�q����Ă���̂ŁA�^�C�g���̖�������"<(�i"�����ꂩ��
		// �������ANSScanner�Ő����𓾂�B
		field_ = title_;
		resRange_ = 
		  [field_ rangeOfCharacterFromSet : bracketCSet_
		  						options : NSBackwardsSearch];
		UTILRequireCondition(
			resRange_.location != NSNotFound && resRange_.length != 0,
			ErrCompose);
		scanner_ = [NSScanner scannerWithString : field_];
		//�ŏ��̊J�����ʂ͔�΂�
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
