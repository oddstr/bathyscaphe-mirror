//:w2chConnect.h
/**
  *
  * 2ch�ɐڑ��ł���N���X�̃v���g�R��
  *
  * @version 1.0.1 (02/02/04  5:44:38 PM)
  *
  */
#import <Foundation/Foundation.h>

@class SGHTTPConnector;

typedef enum {
	kw2chConnectGettingSubject_txtMode,		//subject.txt�̎擾
	kw2chConnectGettingDATMode,				//.dat�t�@�C���̎擾
	kw2chConnectPOSTMessageMode,			//"POST"���\�b�h�̎��s
	

} w2chConnectMode;

//Error Handling

// �Ή��\��ReplyErrorCode.plist���Q��
enum {
	k2chNoneErrorType 				= 0,		// ����
	k2chEmptyDataErrorType			= 1,		// �f�[�^�Ȃ�
	k2chAnyErrorType				= 2,		// �d�q�q�n�q�I
	k2chContributionCheckErrorType	= 3,		// ���e�m�F

	k2chRequireNameErrorType		= 4,		// ���O����Ă���
	k2chRequireContentsErrorType	= 5,		// �{��������܂���B
	k2chSPIDCookieErrorType			= 6,		// �N�b�L�[�m�F�I
	k2chDoubleWritingErrorType		= 7,		// ��d��������
	k2chWarningType					= 8,		// ���ӎ���
	
	
	k2chUnknownErrorType
};

typedef struct {
	int type;
	w2chConnectMode mode;
	int error;
} SG2chServerError;

@protocol w2chConnect<NSObject>
- (SGHTTPConnector*) HTTPConnector;
- (id) delegate;

- (void) setDelegate : (id) newDelegate;

/**
  * �e�R�l�N�^�̏����Ώۂ�\���萔��Ԃ��B
  * 
  * @return     SG2chConnectorMode
  */
- (w2chConnectMode) mode;

/**
  * ���̎��_�Ŏ�M���������f�[�^��Ԃ��B
  * ���k����Ă���ꍇ�͓W�J����B
  * 
  * @return     ��M���������f�[�^
  */
- (NSData *) availableResourceData;

/**
  * ���V�[�o�̕ێ�����f�[�^��Ԃ��B
  * �K�v�ȏꍇ�͐ڑ����A�f�[�^����M
  * 
  * @return     �ێ�����f�[�^
  */
- (NSData *) resourceData;

/**
  * ��M���J�n�B�I������܂Ńu���b�N����B
  * 
  * @return     ��M�����f�[�^
  */
- (NSData *) loadInForeground;

/**
  * �o�b�N�O���E���h�Ŏ�M���J�n����B
  */
- (void) loadInBackground;

/**
  * �o�b�N�O���E���h�ł̎�M�𒆎~����B
  */
- (void) cancelLoadInBackground;

/**
  * �T�[�o�ɑ��M����f�[�^��ݒ�B
  * ���̂Ƃ��A"Content-Length"�w�b�_��
  * �����I�ɐݒ肳���B
  * 
  * @param    data  ���M����f�[�^
  * @return         �������ɂ�YES
  */
- (BOOL) writeData : (NSData *) data;

/**
  * �T�[�o�ɑ��M����t�H�[���̃f�[�^��ݒ肷��B
  * ���̂Ƃ��A"Content-Length"�w�b�_�y�сA"Content-Type"
  * �w�b�_�͎����I�ɐݒ肳���B
  * 
  * @param    forms  �t�H�[���̕ϐ��ƒl��[�߂������I�u�W�F�N�g
  * @return          �������ɂ�YES
  */
- (BOOL) writeForm : (NSDictionary *) forms;


//response
/**
  * �T�[�o����̃��X�|���X��Ԃ��B
  * 
  * @return     �w�b�_
  */
- (NSDictionary *) responseHeaders;

/**
  * ���X�|���X�w�b�_���Q�ƁB
  * 
  * @param    field  �t�B�[���h��
  * @return          �l
  */
- (NSString *) headerFieldValueForKey : (NSString *) field;

/**
  * �T�[�o�̃��X�|���X�R�[�h��Ԃ��B
  * 
  * @return     ���X�|���X�R�[�h
  */
- (unsigned) statusCode;

/**
  * �X�e�[�^�X�s��Ԃ��B
  * 
  * @return     �X�e�[�^�X�s
  */
- (NSString *) statusLine;

- (NSURL *) requestURL;

- (NSString *) requestMethod;
@end

//Error Handling
@protocol w2chErrorHandling<NSObject>
//////////////////////////////////////////////////////////////////////
////////////////////// [ �A�N�Z�T���\�b�h ] //////////////////////////
//////////////////////////////////////////////////////////////////////
- (NSURL *) requestURL;
- (w2chConnectMode) requestMode;
- (SG2chServerError) recentError;
- (NSString *) recentErrorTitle;
- (NSString *) recentErrorMessage;
- (void) setRecentErrorCode : (int) code;
//////////////////////////////////////////////////////////////////////
//////////////////// [ �C���X�^���X���\�b�h ] ////////////////////////
//////////////////////////////////////////////////////////////////////
/**
  * �T�[�o�[����Ԃ��Ă����f�[�^���󂯂Ƃ�A�G���[���ǂ���
  * ���f�BSG2chServerError�\���̂�type��k2chNoneErrorType
  * �ȊO�̓G���[�B
  * 
  * @param    contents  �T�[�o�[����Ԃ��Ă����f�[�^
  * @param    title     �G���[�̓��e���Ȍ��ɕ\����������
  * @param    message   �G���[�̓��e
  * @return             SG2chServerError�\����
  */
- (SG2chServerError) handleErrorWithContents : (NSString  *) contents
                                       title : (NSString **) title
                                     message : (NSString **) message; 

@end


//Delegate
@interface NSObject(w2chConnectDelegate)
/////////////////////////////////////////////////////////////////////
////////////////// [ ��M�̊J�n�A�I���A�L�����Z���Ȃ� ] /////////////
/////////////////////////////////////////////////////////////////////

- (void) connectorResourceDidBeginLoading : (id<w2chConnect>) sender;

- (void) connectorResourceDidCancelLoading : (id<w2chConnect>) sender;

- (void) connectorResourceDidFinishLoading : (id<w2chConnect>) sender;
  
/////////////////////////////////////////////////////////////////////
///////////////////// [ �f�[�^�̎�M�֌W ] //////////////////////////
/////////////////////////////////////////////////////////////////////

- (void) connector               : (id<w2chConnect>) sender
  resourceDataDidBecomeAvailable : (NSData      *) newBytes;

- (void) connector                 : (id<w2chConnect>) sender
  resourceDidFailLoadingWithReason : (NSString    *) reason;

/**
  * ��M�E���M�͊����������A���炩�̗��R�Ŏ󂯓�����Ȃ������B
  * 
  * @param    sender   �R�l�N�^�[
  * @param    handler  �G���[�����I�u�W�F�N�g
  */
- (void) connector                 : (id<w2chConnect>) sender
   resourceDidFailLoadingWithError : (id<w2chErrorHandling>) handler;
@end


