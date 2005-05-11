//:AppDefaults-Alert.m
/**
  *
  * �x����񍐂Ȃǂ��p�l���\��
  *
  * @version 1.0.0d2 (01/11/29  6:02:35 PM)
  *
  */
#import "AppDefaults_p.h"

//////////////////////////////////////////////////////////////////////
////////////////////// [ �萔��}�N���u�� ] //////////////////////////
//////////////////////////////////////////////////////////////////////
static NSString *const _appDefaultsAlertTableName = @"AlertPanel";


@implementation AppDefaults(AlertPanel)
/**
  * �p�l���Ŏg�p����郍�[�J���C�Y������
  * ����������t�@�C����
  * 
  * @return     �t�@�C����
  */
+ (NSString *) tableForPanels
{
	return _appDefaultsAlertTableName;
}

/**
  * ����{�^���ɕ\�����镶����
  * 
  * @return     �\�����镶����
  */
+ (NSString *) labelForDefaultButton
{
	return NSLocalizedStringFromTable(
						@"OK",
						[[self class] tableForPanels],
						@"Lable for DefaultButton");
}

/**
  * �L�����Z���{�^���ɕ\�����镶����
  * 
  * @return     �\�����镶����
  */
+ (NSString *) labelForAlternateButton
{
	return NSLocalizedStringFromTable(
						@"Cancel",
						[[self class] tableForPanels],
						@"Lable for DefaultButton");
}

/**
  * �A���[�g�p�l����\���B
  * 
  * @param    title  �^�C�g��
  * @param    msg    ���e
  * @return          ����
  */
- (int) runAlertPanelWithLocalizedString : (NSString *) title
								 message : (NSString *) msg
{
	return NSRunAlertPanel(
					title,
					msg,
					[[self class] labelForDefaultButton],
					[[self class] labelForAlternateButton],
					nil);
}

/**
  * �f�B���N�g���������邱�Ƃ��ł����A�쐬���s�\���������߁A
  * �x����\�����āA�A�v���P�[�V�������I��������B
  * 
  * @param    msg  ���b�Z�[�W
  * @return        ����
  */
- (int) runDirectoryNotFoundAlertAndTerminateWithMessage : (NSString *) msg
{
	NSString *title_;
	
	title_ = 
	  NSLocalizedStringFromTable(@"NotFound",
	  							 [[self class] tableForPanels],
								 nil);
	[self runCriticalAlertPanelWithLocalizedString : title_
						                   message : msg];
	[NSApp terminate : self];
	return 0;
}

/**
  * �A���[�g�p�l����\���B
  * 
  * @param    title  �^�C�g��
  * @param    msg    ���e
  * @return          ����
  */
- (int) runCriticalAlertPanelWithLocalizedString : (NSString *) title
                                          message : (NSString *) msg
{
	int error_;
	
	error_ = NSRunCriticalAlertPanel(title,
							msg,
							[[self class] labelForDefaultButton],
							[[self class] labelForAlternateButton],
							nil);
	return error_;
}
@end