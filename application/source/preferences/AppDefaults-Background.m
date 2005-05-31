//:AppDefaults-Background.m
#import "AppDefaults_p.h"


//////////////////////////////////////////////////////////////////////
////////////////////// [ �萔��}�N���u�� ] //////////////////////////
//////////////////////////////////////////////////////////////////////
// �w�i�F�Ȃǂ̐ݒ�̎������i�[����L�[
static NSString *const AppDefaultsBackgroundsKey = @"Preferences - BackgroundColors";

//�X���b�h�ꗗ�̔w�i�F�i�Ȗ͗l�j
static NSString *const AppDefaultsStripedTableColorKey = @"ThreadsList Striped Color";
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



@implementation AppDefaults(BackgroundColors)
- (NSColor *) browserStripedTableColor
{
	return [self defaultsColorForKey:AppDefaultsStripedTableColorKey];
}
- (void) setBrowserStripedTableColor : (NSColor *) color
{
	NSLog(@"Deprecated.");
	//[self setBGDefaultsColor : color
	//				  forKey : AppDefaultsStripedTableColorKey];
	//[self setBrowserSTableDrawsStriped : YES];
}

- (NSColor *) browserSTableBackgroundColor
{
	return [self defaultsColorForKey:AppDefaultsSTableBackgroundColorKey];
}
- (void) setBrowserSTableBackgroundColor : (NSColor *) color
{
	[self setBGDefaultsColor : color
					  forKey : AppDefaultsSTableBackgroundColorKey];
	[self setBrowserSTableDrawsStriped : NO]; //�ǂ����Ă��J�X�^���J���[�œh��Ƃ����Ȃ�A�h�蕪���͎����I�ɖ���������
	[self setBrowserSTableDrawsBackground : YES];
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
	[self setBrowserSTableDrawsBackground : NO];//(NO == flag)];
	[self postLayoutSettingsUpdateNotification];
}



- (BOOL) browserSTableDrawsBackground
{
	return [[self backgroundColorDictionary]
					 boolForKey : AppDefaultsSTableDrawsBackgroundKey
				   defaultValue : DEFAULT_STABLE_DRAWS_BGCOLOR];
}
- (void) setBrowserSTableDrawsBackground : (BOOL) flag
{
	[[self backgroundColorDictionary]
			 setBool : flag
			  forKey : AppDefaultsSTableDrawsBackgroundKey];
	[self postLayoutSettingsUpdateNotification];
}





- (NSColor *) threadViewerBackgroundColor
{
	return [self defaultsColorForKey:AppDefaultsTVBackgroundColorKey];
}
- (void) setThreadViewerBackgroundColor : (NSColor *) color
{
	[self setBGDefaultsColor : color
					  forKey : AppDefaultsTVBackgroundColorKey];
	[self setThreadViewerDrawsBackground : YES];
}



- (BOOL) threadViewerDrawsBackground
{
	return [[self backgroundColorDictionary]
					 boolForKey : AppDefaultsTVDrawsBackgroundKey
				   defaultValue : DEFAULT_TVIEW_DRAWS_BGCOLOR];
}
- (void) setThreadViewerDrawsBackground : (BOOL) flag
{
	[[self backgroundColorDictionary]
			 setBool : flag
			  forKey : AppDefaultsTVDrawsBackgroundKey];
	[self postLayoutSettingsUpdateNotification];
}



- (BOOL) isResPopUpSeeThrough
{
	return [[self backgroundColorDictionary]
					 boolForKey : AppDefaultsResPopUpIsSeeThroughKey
				   defaultValue : DEFAULT_RESPOPUP_IS_SEETHROUGH];
}

- (void) setIsResPopUpSeeThrough : (BOOL) anIsResPopUpSeeThrough
{
	[[self backgroundColorDictionary]
			 setBool : anIsResPopUpSeeThrough
			  forKey : AppDefaultsResPopUpIsSeeThroughKey];
	[self postLayoutSettingsUpdateNotification];
}



- (NSColor *) resPopUpBackgroundColor
{
	NSColor		*color_;
	
	color_ = [[self backgroundColorDictionary]
					colorForKey : AppDefaultsResPopUpBackgroundColorKey];
	if(nil == color_){
		return [NSColor colorWithCalibratedHue : 0.14f
									saturation : 0.2f
									brightness : 1.0f
										 alpha : 1.0f];
	}
	
	return color_;
}
- (void) setResPopUpBackgroundColor : (NSColor *) color
{
	[self setBGDefaultsColor : color
					  forKey : AppDefaultsResPopUpBackgroundColorKey];
	[self postLayoutSettingsUpdateNotification];
}


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

