/**
  * $Id: CMRNoNameManager.h,v 1.1.1.1 2005/05/11 17:51:05 tsawada2 Exp $
  * 
  * CMRNoNameManager.h
  *
  * Copyright (c) 2003, Takanori Ishikawa.
  * See the file LICENSE for copying permission.
  */

/*!
	@header CMRNoNameManager
	
	�̖���������̖��O���Ǘ�����}�l�[�W��
	SETTING.TXT �𗘗p���邱�Ƃ��ł��邪�A�K���������ׂĂ̔�
	�p�ӂ���Ă�킯�ł͂Ȃ��i�C������j�̂ŁA
	�E���[�U����
	�E�X������̎�������
	�ŕ₤
	
	1.0.9.7 �ȍ~�ł͂��L�͂ɁA���Ƃ̃v���p�e�B�̊Ǘ���S�킹��
	�E�u���E�U�̃\�[�g��J�����i�����A�~���܂ށj
	�E�K�v�Ȃ�g�����\�i���Ƃ̃R�e�n���L���A�X���ꗗ�̃t�B���^�ݒ�Ȃǂ��l������j
	
	���O�� NoNameManager/NoName.plist �̂܂܂Ȃ̂͒P�ɓ����̌݊����ێ��̂��߁B
*/

#import <Foundation/Foundation.h>

@class	CMRBBSSignature;



@interface CMRNoNameManager : NSObject
{
	@private
	NSDictionary	*_noNameDict;
}
+ (id) defaultManager;


/* ����������̖��O */
- (NSString *) defauoltNoNameForBoard : (CMRBBSSignature *) aBoard;
- (void) setDefaultNoName : (NSString        *) aName
			 	 forBoard : (CMRBBSSignature *) aBoard;
/* �\�[�g��J���� */
- (NSString *) sortColumnForBoard : (CMRBBSSignature *) aBoard;
- (void) setSortColumn : (NSString		  *) anIdentifier
			  forBoard : (CMRBBSSignature *) aBoard;
- (BOOL) sortColumnIsAscendingAtBoard : (CMRBBSSignature *) aBoard;
- (void) setSortColumnIsAscending : (BOOL			  ) TorF
						  atBoard : (CMRBBSSignature *) aBoard;

/*
	���[�U����̓��͂��󂯂���B
	
	@param aBoard �f����
	@param presetValue:aValue �e�L�X�g�t�B�[���h�̃f�t�H���g�l
	@result �L�����Z�����ɂ� nil
*/
- (NSString *) askUserAboutDefaultNoNameForBoard : (CMRBBSSignature *) aBoard
									 presetValue : (NSString        *) aValue;
@end
