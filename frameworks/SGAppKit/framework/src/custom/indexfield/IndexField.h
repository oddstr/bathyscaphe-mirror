
/**
  *
  * �C���f�b�N�X���w�肷��e�L�X�g�t�B�[���h
  *
  * @version 1.0.0d2 (01/12/20  2:07:49 AM)
  *
  */


#import <Foundation/Foundation.h>
#import <AppKit/NSTextField.h>

@interface IndexField : NSTextField
{
}
@end



@interface IndexField(DelegateExtension)
- (NSRange) selectRangeWithTextField : (NSTextField *) textField;
@end