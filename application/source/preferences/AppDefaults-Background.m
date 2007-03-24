//:AppDefaults-Background.m
#import "AppDefaults_p.h"


//////////////////////////////////////////////////////////////////////
////////////////////// [ �萔��}�N���u�� ] //////////////////////////
//////////////////////////////////////////////////////////////////////
// �w�i�F�Ȃǂ̐ݒ�̎������i�[����L�[
static NSString *const AppDefaultsBackgroundsKey = @"Preferences - BackgroundColors";

//�X���b�h�ꗗ�̃e�[�u���̔w�i�F
static NSString *const AppDefaultsSTableBackgroundColorKey = @"ThreadsList BackgroundColor";
//�X���b�h�ꗗ�̃e�[�u���̎Ȗ͗l��`�悷�邩
static NSString *const AppDefaultsSTableDrawsStripedKey = @"ThreadsList Draws Striped";
//�X���b�h�ꗗ�̃e�[�u���̔w�i��`�悷�邩
static NSString *const AppDefaultsSTableDrawsBackgroundKey = @"ThreadsList Draws BackgroundColor";

//�X���b�h�\���̔w�i�F
static NSString *const AppDefaultsTVBackgroundColorKey = @"Thread Viewer BackgroundColor";
//�X���b�h�\���̔w�i�F
static NSString *const AppDefaultsTVDrawsBackgroundKey = @"Thread Viewer Draws Background";
//�|�b�v�A�b�v�\���̔w�i�F
static NSString *const AppDefaultsResPopUpBackgroundColorKey = @"Res PopUp Background";
//�|�b�v�A�b�v�𔼓����ɂ��邩
static NSString *const AppDefaultsResPopUpIsSeeThroughKey = @"Res PopUp See Through";
//�������݃E�C���h�E�̔w�i�F
static NSString *const kPrefReplyBackgroundColorKey	= @"Reply Window BackgroundColor";
static NSString *const kPrefBoardListBackgroundColorKey	= @"BoardList BackgroundColor";

//SledgeHammer Additions
static NSString *const kPrefResPopUpBgAlphaKey = @"Res PopUp Bg Alpha Value";
static NSString *const kPrefReplyWindowBgAlphaKey = @"Reply Window Bg Alpha Value";


@implementation AppDefaults(BackgroundColorsSupport)
- (NSMutableDictionary *) backgroundColorDictionary
{
	if(nil == m_backgroundColorDictionary){
		NSDictionary	*dict_;
		
		dict_ = [[self defaults] dictionaryForKey : AppDefaultsBackgroundsKey];
		m_backgroundColorDictionary = [dict_ mutableCopy];
	}
	
	if(nil == m_backgroundColorDictionary)
		m_backgroundColorDictionary = [[NSMutableDictionary alloc] init];
	
	return m_backgroundColorDictionary;
}
- (NSColor *) defaultsColorForKey : (NSString *) key
{
	NSColor		*color_;
	
	color_ = [[self backgroundColorDictionary]
					colorForKey : key];
	if(nil == color_) return [NSColor whiteColor];
	
	return color_;
}
- (void) setBGDefaultsColor : (NSColor  *) color
					 forKey : (NSString *) key
{
	if(nil == key) return;
	
	if(nil == color || [[NSColor whiteColor] isEqual : color]){
		[[self backgroundColorDictionary]
				removeObjectForKey : key];
		return;
	}
	[[self backgroundColorDictionary]
			setColor : color
			  forKey : key];
}
@end

#pragma mark -

@implementation AppDefaults(BackgroundColors)
#pragma mark Browser

- (NSColor *) browserSTableBackgroundColor
{
	return [self defaultsColorForKey:AppDefaultsSTableBackgroundColorKey];
}

- (void) setBrowserSTableBackgroundColor : (NSColor *) color
{
	[self setBGDefaultsColor : color
					  forKey : AppDefaultsSTableBackgroundColorKey];
	[self setBrowserSTableDrawsStriped : NO]; //�ǂ����Ă��J�X�^���J���[�œh��Ƃ����Ȃ�A�h�蕪���͎����I�ɖ���������
}

- (BOOL) browserSTableDrawsStriped
{
	return [[self backgroundColorDictionary]
					 boolForKey : AppDefaultsSTableDrawsStripedKey
				   defaultValue : DEFAULT_STABLE_DRAWS_STRIPED];
}

- (void) setBrowserSTableDrawsStriped : (BOOL) flag
{
	[[self backgroundColorDictionary]
			 setBool : flag
			  forKey : AppDefaultsSTableDrawsStripedKey];
	[self postLayoutSettingsUpdateNotification];
}

- (NSColor *) boardListBackgroundColor
{
	NSColor		*color_;
	
	color_ = [[self backgroundColorDictionary]
					colorForKey : kPrefBoardListBackgroundColorKey];
	
	if (color_ == nil)
		return DEFAULT_BOARD_LIST_BG_COLOR; // �f�t�H���g�̐F
	
	return color_;
}

- (void) setBoardListBackgroundColor : (NSColor *) color
{
	[self setBGDefaultsColor : color
					  forKey : kPrefBoardListBackgroundColorKey];
	[self postLayoutSettingsUpdateNotification];
}

#pragma mark Thread Viewer
- (NSColor *) threadViewerBackgroundColor
{
	return [[self threadViewTheme] backgroundColor];
}

#pragma mark Popup and Reply Window
- (NSColor *) resPopUpBackgroundColor
{
	NSColor		*color_;
	
	color_ = [[self backgroundColorDictionary]
					colorForKey : AppDefaultsResPopUpBackgroundColorKey];
	if(nil == color_){
		return DEFAULT_POPUP_BG_COLOR;
	}
	
	return color_;
}

- (void) setResPopUpBackgroundColor : (NSColor *) color
{
	[self setBGDefaultsColor : color
					  forKey : AppDefaultsResPopUpBackgroundColorKey];
	[self postLayoutSettingsUpdateNotification];
}

- (NSColor *) replyBackgroundColor
{
	NSColor *color_;
	color_ = [[self backgroundColorDictionary]
					colorForKey : kPrefReplyBackgroundColorKey];
	return (nil == color_) ? [NSColor whiteColor] : color_;
}

- (void) setReplyBackgroundColor : (NSColor *) aColor
{
	[self setBGDefaultsColor : aColor
					  forKey : kPrefReplyBackgroundColorKey];
	[self postLayoutSettingsUpdateNotification];
}

// SledgeHammer Additions
- (float) resPopUpBgAlphaValue
{
	return [[self backgroundColorDictionary]
					floatForKey : kPrefResPopUpBgAlphaKey
				   defaultValue : DEFAULT_POPUP_BG_ALPHA];
}
- (void) setResPopUpBgAlphaValue : (float) rate
{
	[[self backgroundColorDictionary]
			setFloat : rate
			  forKey : kPrefResPopUpBgAlphaKey];
	[self postLayoutSettingsUpdateNotification];
}
- (float) replyBgAlphaValue
{
	return [[self backgroundColorDictionary]
					floatForKey : kPrefReplyWindowBgAlphaKey
				   defaultValue : DEFAULT_REPLY_BG_ALPHA];
}
- (void) setReplyBgAlphaValue : (float) rate
{
	[[self backgroundColorDictionary]
			setFloat : rate
			  forKey : kPrefReplyWindowBgAlphaKey];
	[self postLayoutSettingsUpdateNotification];
}


#pragma mark -
- (void) _loadBackgroundColors
{
}

- (BOOL) _saveBackgroundColors
{
	NSDictionary			*dict_;
	
	dict_ = [self backgroundColorDictionary];
	
	UTILAssertNotNil(dict_);
	[[self defaults] setObject : dict_
						forKey : AppDefaultsBackgroundsKey];
	return YES;
}
@end
