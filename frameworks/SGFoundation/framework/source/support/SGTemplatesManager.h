/**
  * $Id: SGTemplatesManager.h,v 1.1.1.1 2005/05/11 17:51:45 tsawada2 Exp $
  * 
  * SGTemplatesManager.h
  *
  * Copyright (c) 2003, Takanori Ishikawa.
  * See the file LICENSE for copying permission.
  */

#ifndef SGTEMPLATE_MGR_INCLUDED
#define SGTEMPLATE_MGR_INCLUDED

#import <Cocoa/Cocoa.h>
#import <SGFoundation/SGBase.h>

SG_DECL_BEGIN



/*!
 * @define      kSGAttributesTemplateFile
 * @discussion  �����t��������̃e���v���[�g�t�@�C��
 */
#define kSGAttributesTemplateFile		@"StyleTemplates"
/*!
 * @define      kSGPropertyListTemplateFile
 * @discussion  Property List�`���̃e���v���[�g�t�@�C��
 */
#define kSGPropertyListTemplateFile		@"KeyValueTemplates"



@interface NSMutableAttributedString(SGTemplateResourcesManagerPrivate)
- (id) setStringAndReturnSelf : (NSString *) aString;
@end



/*

[Attributed String Template]
RTF, RTFD�t�@�C���ɋL�q�������ʎq�����o���A
NSMutableAttributedString�̃C���X�^���X�Ƃ��ĊǗ��ł��܂��B

���Ƃ��΁A%%%ExampleIdentifier%%%�ƋL�q����RTF�t�@�C����
�p�ӂ��Ă������荞�ނƁA�A�v���P�[�V���������
- resourceForKey:��@"ExampleIdentifier"��
NSMutableAttributedString�C���X�^���X�𓾂邱�Ƃ��ł��܂��B

*/

@interface SGTemplatesManager : NSObject
{
	@private
	NSMutableDictionary		*_resources;
}
/*!
 * @method      sharedInstance
 * @abstract    ���L�C���X�^���X
 * @discussion  
 * 
 * �A�v���P�[�V������Applecation Support�f�B���N�g����
 * + [NSBundle mainBundle]���烊�\�[�X��T������C���X�^���X
 * 
 * @result      ���L�C���X�^���X
 */
+ (SGTemplatesManager *) sharedInstance;

- (id) resourceForKey : (id) aKey;
- (void) addResourcesFromContentsOfFile : (NSString *) filepath;

- (void) resetAllResources;
@end


#define SGTemplateResource(aKey)	[[SGTemplatesManager sharedInstance] resourceForKey : (aKey)]

// Property List
#define SGTemplateSize(aKey)	NSSizeFromString(SGTemplateResource(aKey))
#define SGTemplatePoint(aKey)	NSPointFromString(SGTemplateResource(aKey))
#define SGTemplateRect(aKey)	NSRectFromString(SGTemplateResource(aKey))

#define SGTemplateSelector(aKey)	NSSelectorFromString(SGTemplateResource(aKey))
#define SGTemplateClass(aKey)	NSClassFromString(SGTemplateResource(aKey))


// �v���~�e�B�u
#define SGTemplateBool(aKey)	[SGTemplateResource(aKey) boolValue]


// �����t��������
#define SGTemplateAttrString(aKey, aString)	[SGTemplateResource(aKey) setStringAndReturnSelf : (aString)]

#define SGTemplateAttribute(aKey, aName)	[SGTemplateResource(aKey) attribute:(aName) atIndex:0 effectiveRange:NULL]

// NSDictionary
#define SGTemplateAttributes(aKey)	[SGTemplateResource(aKey) attributesAtIndex:0 effectiveRange:NULL]

#define SGTemplateColor(aKey)	SGTemplateAttribute(aKey, NSForegroundColorAttributeName)

#define SGTemplateFont(aKey)	SGTemplateAttribute(aKey, NSFontAttributeName)



SG_DECL_END


#endif /* SGTEMPLATE_MGR_INCLUDED*/
