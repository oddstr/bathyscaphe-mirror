//: SGXMLEntityReference.h
/**
  * $Id: SGXMLEntityReference.h,v 1.1 2005/05/11 17:51:44 tsawada2 Exp $
  * 
  * Copyright (c) 2001-2003, Takanori Ishikawa.
  * See the file LICENSE for copying permission.
  */

#ifndef SGXMLENTITYREFERENCE_INCLUDED
#define SGXMLENTITYREFERENCE_INCLUDED

#include <CoreFoundation/CoreFoundation.h>
#include <SGFoundation/SGBase.h>

SG_DECL_BEGIN



/*!
 * @function      SGXMLCharacterForEntityReference
 * @abstract      XML���̎Q�Ƃ̉���
 * @discussion    

���̎Q�Ƃ̖��O�A�܂��͕����Q�ƂɑΉ�����Unicode������Ԃ��B
�C�ӂ�Unicode�����B�������C�T���Q�[�g�u���b�N�CFFFE�y��FFFF�͏����B
�T�|�[�g���Ă���̂̓X�^���_�[�h�ALatin1�ASpecial�ASymbol�ł���B

 * @param  theEntity  ���O or �����Q�� ("#123" "#xAA")
 * @param  theUniChar �Ή�����Unicode����
 * @result            ��������true
 */

SG_EXPORT
Boolean SGXMLCharacterForEntityReference(
				CFStringRef			theEntityReference,
				UniChar				*theUniChar);

SG_EXPORT
CFStringRef SGXMLStringForEntityReference(
				CFStringRef			theEntityReference);



SG_DECL_END

#endif /* SGXMLENTITYREFERENCE_INCLUDED */
