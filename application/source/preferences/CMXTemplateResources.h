//: CMXTemplateResources.h
/**
  * $Id: CMXTemplateResources.h,v 1.1.1.1 2005/05/11 17:51:07 tsawada2 Exp $
  * 
  * Copyright (c) 2001-2003, Takanori Ishikawa.
  * See the file LICENSE for copying permission.
  */

#ifndef CMXTEMPLATERESOURCES_INCLUDED
#define CMXTEMPLATERESOURCES_INCLUDED

#import <Foundation/Foundation.h>


#define CMXTemplateResource(aKey, aComment)	SGTemplateResource(aKey)

// Property List
#define CMXTemplateSize(aKey, aComment)	SGTemplateSize(aKey)
#define CMXTemplatePoint(aKey, aComment)	SGTemplatePoint(aKey)
#define CMXTemplateRect(aKey, aComment)	SGTemplateRect(aKey)

#define CMXTemplateSelector(aKey, aComment)	SGTemplateSelector(aKey)
#define CMXTemplateClass(aKey, aComment)	SGTemplateClass(aKey)
// プリミティブ
#define CMXTemplateBool(aKey, aComment)					SGTemplateBool(aKey)
// 書式付き文字列
#define CMXTemplateAttrString(aKey, aString, aComment)	SGTemplateAttrString(aKey, aString)
#define CMXTemplateAttribute(aKey, aName, aComment)		SGTemplateAttribute(aKey, aName)
// NSDictionary
#define CMXTemplateAttributes(aKey, aComment)			SGTemplateAttributes(aKey)
#define CMXTemplateColor(aKey, aComment)				SGTemplateColor(aKey)
#define CMXTemplateFont(aKey, aComment)					SGTemplateFont(aKey)



#ifdef  __cplusplus
extern "C" {
#endif




#ifdef  __cplusplus
}
#endif
#endif /* CMXTEMPLATERESOURCES_INCLUDED*/
