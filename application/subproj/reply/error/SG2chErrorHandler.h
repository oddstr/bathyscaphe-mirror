/**
  * $Id: SG2chErrorHandler.h,v 1.1.1.1 2005/05/11 17:51:12 tsawada2 Exp $
  * 
  * SG2chErrorHandler.h
  *
  * Copyright (c) 2003, Takanori Ishikawa.
  * See the file LICENSE for copying permission.
  */
#import <SGFoundation/SGFoundation.h>
#import "w2chConnect.h"



@interface SG2chErrorHandler : NSObject<w2chErrorHandling>
{
	NSURL				*m_requestURL;
	w2chConnectMode		m_requestMode;
	SG2chServerError	m_recentError;
	NSString			*m_recentErrorTitle;
	NSString			*m_recentErrorMessage;
}
//////////////////////////////////////////////////////////////////////
/////////////////////// [ �������E��n�� ] ///////////////////////////
//////////////////////////////////////////////////////////////////////
/**
  * �ꎞ�I�u�W�F�N�g�̐����B
  * �擾���URL���w�肵�ď������B
  * 
  * @param    anURL       �擾���URL
  * @return               �ꎞ�I�u�W�F�N�g
  */
+ (id) handlerWithURL : (NSURL *) anURL;

/**
  * �擾���URL���w�肵�ď������B
  * 
  * @param    anURL       �擾���URL
  * @return               �������ς݂̃C���X�^���X
  */
- (id) initWithURL : (NSURL         *) anURL;


//////////////////////////////////////////////////////////////////////
/////////////////////// [ �N���X���\�b�h ] ///////////////////////////
//////////////////////////////////////////////////////////////////////
/**
  * �w�肳�ꂽURL����f�[�^���擾�ł���ꍇ��YES
  * 
  * @param    anURL  URL
  * @return          URL����f�[�^���擾�ł���ꍇ��YES
  */
+ (BOOL) canInitWithURL : (NSURL *) anURL;

//////////////////////////////////////////////////////////////////////
////////////////////// [ �A�N�Z�T���\�b�h ] //////////////////////////
//////////////////////////////////////////////////////////////////////
/* Accessor for m_requestURL */
- (void) setRequestURL : (NSURL *) aRequestURL;
/* Accessor for m_recentError */
- (void) setRecentError : (SG2chServerError) aRecentError;
/* Accessor for m_recentErrorTitle */
- (void) setRecentErrorTitle : (NSString *) aRecentErrorTitle;
/* Accessor for m_recentErrorMessage */
- (void) setRecentErrorMessage : (NSString *) aRecentErrorMessage;
@end

extern SG2chServerError SGMake2chServerError(int type, 
			     						     w2chConnectMode mode, 
										     int error);

