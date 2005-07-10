//:AppDefaults-Background.m
#import "AppDefaults_p.h"


//////////////////////////////////////////////////////////////////////
////////////////////// [ 定数やマクロ置換 ] //////////////////////////
//////////////////////////////////////////////////////////////////////
// 背景色などの設定の辞書を格納するキー
static NSString *const AppDefaultsBackgroundsKey = @"Preferences - BackgroundColors";

//スレッド一覧のテーブルの背景色
static NSString *const AppDefaultsSTableBackgroundColorKey = @"ThreadsList BackgroundColor";
//スレッド一覧のテーブルの縞模様を描画するか
static NSString *const AppDefaultsSTableDrawsStripedKey = @"ThreadsList Draws Striped";
//スレッド一覧のテーブルの背景を描画するか
static NSString *const AppDefaultsSTableDrawsBackgroundKey = @"ThreadsList Draws BackgroundColor";

//スレッド表示の背景色
static NSString *const AppDefaultsTVBackgroundColorKey = @"Thread Viewer BackgroundColor";
//スレッド表示の背景色
static NSString *const AppDefaultsTVDrawsBackgroundKey = @"Thread Viewer Draws Background";
//ポップアップ表示の背景色
static NSString *const AppDefaultsResPopUpBackgroundColorKey = @"Res PopUp Background";
//ポップアップを半透明にするか
static NSString *const AppDefaultsResPopUpIsSeeThroughKey = @"Res PopUp See Through";
//書き込みウインドウの背景色
static NSString *const kPrefReplyBackgroundColorKey	= @"Reply Window BackgroundColor";
static NSString *const kPrefBoardListBackgroundColorKey	= @"BoardList BackgroundColor";


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
	[self setBrowserSTableDrawsStriped : NO]; //どうしてもカスタムカラーで塗るというなら、塗り分けは自動的に無効化する
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

- (NSColor *) boardListBackgroundColor
{
	NSColor		*color_;
	
	color_ = [[self backgroundColorDictionary]
					colorForKey : kPrefBoardListBackgroundColorKey];
	
	if (color_ == nil)
		return [NSColor colorWithCalibratedRed: 0.898 green: 0.9294 blue: 0.9686 alpha:1.0]; // デフォルトの色
	
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

#pragma mark Popup and Reply Window
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