//: SGTextAccessoryFieldController.h
/**
  * $Id: SGTextAccessoryFieldController.h,v 1.1 2005/05/11 17:51:26 tsawada2 Exp $
  * 
  * Copyright (c) 2001-2003, Takanori Ishikawa.
  * See the file LICENSE for copying permission.
  */

/*!
 * @header     SGTextAccessoryFieldController
 * @discussion SGTextAccessoryFieldController�N���X
 */

#import <Cocoa/Cocoa.h>

@class SGBackgroundSurfaceView;
@class NSView, NSTextField, NSButton;

/*!
 * @class      SGTextAccessoryFieldController
 * @abstract   �O�ς�ύX�ł���e�L�X�g�t�B�[���h
 *
 * @discussion �w�i�摜�����ւ��邱�ƂŁA�O�ς��J�X�^�}�C�Y�\��
 *             �e�L�X�g�t�B�[���h�����b�v�����R���g���[���N���X�ł��B
 *             �܂��AMail.app�̌����t�B�[���h�̂悤�Ɂu�폜�v
 *             �{�^�����������Ă��܂��B
 *             �P����NSTextField���T�u�N���X�����������ł�
 *             ���ߍ��݃{�^���������ł��Ȃ��������߁A�����I�u�W�F�N�g
 *             �̃R���g���[���ɂȂ��Ă��܂��B
 */

@interface SGTextAccessoryFieldController : NSObject
{
	IBOutlet NSView						*m_componentView;
	IBOutlet SGBackgroundSurfaceView	*m_backgroundView;
	
	IBOutlet NSTextField		*m_textField;
	IBOutlet NSButton			*m_clearButton;
	
	NSView						*m_accessoryView;
	BOOL						_sendsActionOnTextDidChange;
}
+ (float) preferedHeight;
- (id) initWithViewFrame : (NSRect) aFrame;

- (void) setStringValue : (NSString *) aString;
- (void) selectAll : (id) sender;
- (void) sendTextFieldAction;

- (IBAction) clearText : (id) sender;
- (BOOL) sendsActionOnTextDidChange;
- (void) setSendsActionOnTextDidChange : (BOOL) flag;
@end



@interface SGTextAccessoryFieldController(Accessor)
- (NSView *) accessoryView;
- (void) setAccessoryView : (NSView *) anAccessoryView;

- (BOOL) isEmpty;
- (BOOL) clearButtonVisible;
- (void) setVisibleClearButton : (BOOL) flag;
@end



@interface SGTextAccessoryFieldController(ViewAccessor)
- (NSView *) componentView;
- (SGBackgroundSurfaceView *) backgroundView;
- (NSTextField *) textField;
- (NSButton *) clearButton;
@end
