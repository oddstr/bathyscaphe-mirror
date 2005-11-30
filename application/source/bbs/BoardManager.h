/**
 * $Id: BoardManager.h,v 1.6 2005/11/30 23:22:51 tsawada2 Exp $
 * 
 * BoardManager.h
 *
 * Copyright (c) 2004 Takanori Ishikawa, All rights reserved.
 * See the file LICENSE for copying permission.
 */

#import <SGFoundation/SGFoundation.h>

@class BoardList;
/*!
    @class		BoardManager
    @abstract   �f�����X�g�� dataSource �񋟂ƁA�e�f���̑����ւ̃A�N�Z�X���ꊇ���Ď�舵���}�l�[�W��
    @discussion BoardManager �́A�f�����X�g�� dataSource ��񋟂��܂��B�܂��A�e�f���Ɋւ���
				��X�̑����̓ǂݏ������T�|�[�g���܂��B�f���͂��̖��O�ň�ӂɎ��ʂ���邱�Ƃɒ��ӂ��Ă��������B
				BoardManager �Ōf���̑�����ǂݏ�������ہA�قƂ�ǂ̃��\�b�h�Ōf���́u���O�v���L�[��
				����K�v������܂��B�������A���O���킩��Ȃ����AURL ���킩���Ă���ꍇ�́AboardNameForURL:
				���\�b�h�Ŗ��O�𓾂邱�Ƃ��ł��܂��B
				BoardManager ���i���݂̂Ƃ���j��舵���f���̑����F
				�EURL�i���̋t�����AURL �ړ]�̃T�|�[�g���܂ށj
				�E�f�t�H���g������
				�E�f�t�H���g�R�e�n��
				�E�f�t�H���g���[����
				�E��� Be ���O�C�����ď������ނ��ǂ����H
				�E�X���b�h�ꗗ�ł̃\�[�g��J�����ƁA�����^�~��
*/


typedef enum _BSBeLoginPolicyType {
	BSBeLoginTriviallyNeeded	= 0, // Be ���O�C���K�{
	BSBeLoginTriviallyOFF		= 1, // Be ���O�C���͖��Ӗ��i2ch�ł͂Ȃ��f���Ȃǁj
	BSBeLoginDecidedByUser		= 2	 // Be ���O�C�����邩�ǂ����̓��[�U�̐ݒ���Q�Ƃ���
} BSBeLoginPolicyType;

@interface BoardManager : NSObject
{
    @private
	BoardList			*_defaultList;
	BoardList			*_userList;
	NSDictionary		*_noNameDict;	// NoNameManager �𓝍�
}
+ (id) defaultManager;

- (BoardList *) defaultList;
- (BoardList *) userList;

- (NSString *) defaultBoardListPath;
- (NSString *) userBoardListPath;
+ (NSString *) NNDFilepath;

- (NSURL *) URLForBoardName : (NSString *) boardName;
- (NSString *) boardNameForURL : (NSURL *) anURL;

- (void) updateURL : (NSURL    *) anURL
      forBoardName : (NSString *) aName;

/*!
 * @method        tryToDetectMovedBoard
 * @abstract      Detect moved BBS as possible.
 * @discussion    Detect moved BBS from HTML contents server has
 *                returned. It may be unexpected contents (expected
 *                index.html), but it can contain information about 
 *                new location of BBS.
 *
 * @param boardName BBS Name
 * @result          return YES, if BoardManager change old location.
 */
- (BOOL) tryToDetectMovedBoard : (NSString *) boardName;

/*!
 * @method        detectMovedBoardWithResponseHTML:
 * @abstract      Detect moved BBS as possible.
 * @discussion    Detect moved BBS from HTML contents server has
 *                returned. It may be unexpected contents (expected
 *                index.html), but it can contain information about 
 *                new location of BBS.
 *
 * @param aHTML     HTML contents, NSString
 * @param boardName BBS Name
 * @result          return YES, if BoardManager change old location.
 */
- (BOOL) detectMovedBoardWithResponseHTML : (NSString *) htmlContents
                                boardName : (NSString *) boardName;
@end

@interface BoardManager(BSAddition)
// CMRNoNameManager �𓝍�
// NoNameManager �͂��ׂ� CMRBBSSignature �������ɂƂ��Ă������ABoardManager �ւ�
// �����ɔ����A���ׂ� NSString �ɕύX�����̂Œ��ӁB

- (NSDictionary *) noNameDict;

/* ����������̖��O */
- (NSString *) defaultNoNameForBoard : (NSString *) boardName;
- (void) setDefaultNoName : (NSString *) aName
			 	 forBoard : (NSString *) boardName;
/* �\�[�g��J���� */
- (NSString *) sortColumnForBoard : (NSString *) boardName;
- (void) setSortColumn : (NSString *) anIdentifier
			  forBoard : (NSString *) boardName;
- (BOOL) sortColumnIsAscendingAtBoard : (NSString *) boardName;
- (void) setSortColumnIsAscending : (BOOL	   ) isAscending
						  atBoard : (NSString *) boardName;

// SledgeHammer Addition
- (BOOL) alwaysBeLoginAtBoard : (NSString *) boardName;
- (void) setAlwaysBeLogin : (BOOL	   ) alwaysLogin
				  atBoard : (NSString *) boardName;
- (NSString *) defaultKotehanForBoard : (NSString *) boardName;
- (void) setDefaultKotehan : (NSString *) aName
				  forBoard : (NSString *) boardName;
- (NSString *) defaultMailForBoard : (NSString *) boardName;
- (void) setDefaultMail : (NSString *) aString
			   forBoard : (NSString *) boardName;

// LittleWish Addition
/* ���ӁF���݂͂܂��C���^�t�F�[�X�̂� */
- (BOOL) allThreadsShouldAAThreadAtBoard : (NSString *) boardName;
- (void) setAllThreadsShouldAAThread : (BOOL      ) shouldAAThread
							 atBoard : (NSString *) boardName;

// LittleWish Addtion : Read-only Properties
- (NSImage *) iconForBoard : (NSString *) boardName;
- (BSBeLoginPolicyType) typeOfBeLoginPolicyForBoard : (NSString *) boardName;

/*
	���[�U����̓��͂��󂯂���B
	
	@param aBoard �f����
	@param presetValue:aValue �e�L�X�g�t�B�[���h�̃f�t�H���g�l
	@result �L�����Z�����ɂ� nil
*/
- (NSString *) askUserAboutDefaultNoNameForBoard : (NSString *) boardName
									 presetValue : (NSString *) aValue;
@end

///////////////////////////////////////////////////////////////
///////////////// [ N o t i f i c a t i o n ] /////////////////
///////////////////////////////////////////////////////////////

extern NSString *const CMRBBSManagerUserListDidChangeNotification;
extern NSString *const CMRBBSManagerDefaultListDidChangeNotification;
