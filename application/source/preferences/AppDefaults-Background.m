//:AppDefaults-Background.m
#import "AppDefaults_p.h"

static NSString *const AppDefaultsSTableBackgroundColorKey = @"ThreadsList BackgroundColor";
static NSString *const AppDefaultsSTableDrawsStripedKey = @"ThreadsList Draws Striped";
static NSString *const kPrefBoardListBackgroundColorKey	= @"BoardList BackgroundColor";

@implementation AppDefaults(BackgroundColors)
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
- (NSColor *) backgroundColorForKey: (NSString *) key defaultColor: (NSColor *) defaultColor
{
	NSColor		*color_;
	
	color_ = [[self backgroundColorDictionary] colorForKey : key];
	if (nil == color_) {
		return defaultColor ? defaultColor : [NSColor whiteColor];
	}
	return color_;
}
- (void) setBackgroundColor: (NSColor *) color forKey: (NSString *) key
{
	if(nil == key) return;
	
	if(nil == color){
		[[self backgroundColorDictionary] removeObjectForKey: key];
		return;
	}
	[[self backgroundColorDictionary] setColor: color forKey: key];
}

#pragma mark -
- (NSColor *) browserSTableBackgroundColor
{
	return [self backgroundColorForKey: AppDefaultsSTableBackgroundColorKey defaultColor: nil];
}

- (void) setBrowserSTableBackgroundColor : (NSColor *) color
{
	[self setBackgroundColor: color forKey: AppDefaultsSTableBackgroundColorKey];
	[self setBrowserSTableDrawsStriped: NO]; //どうしてもカスタムカラーで塗るというなら、塗り分けは自動的に無効化する
}

- (BOOL) browserSTableDrawsStriped
{
	return [[self backgroundColorDictionary] boolForKey: AppDefaultsSTableDrawsStripedKey defaultValue: DEFAULT_STABLE_DRAWS_STRIPED];
}

- (void) setBrowserSTableDrawsStriped : (BOOL) flag
{
	[[self backgroundColorDictionary] setBool: flag forKey: AppDefaultsSTableDrawsStripedKey];
	[self postLayoutSettingsUpdateNotification];
}

- (NSColor *) boardListBackgroundColor
{
	return [self backgroundColorForKey: kPrefBoardListBackgroundColorKey defaultColor: DEFAULT_BOARD_LIST_BG_COLOR];
}

- (void) setBoardListBackgroundColor : (NSColor *) color
{
	[self setBackgroundColor: color forKey: kPrefBoardListBackgroundColorKey];
	[self postLayoutSettingsUpdateNotification];
}

- (NSColor *) threadViewerBackgroundColor
{
	return [[self threadViewTheme] backgroundColor];
}
/*
- (NSColor *) resPopUpBackgroundColor
{
	return [[self threadViewTheme] popupBackgroundColorIgnoringAlpha];
}
*/
- (NSColor *) replyBackgroundColor
{
	return [[self threadViewTheme] replyBackgroundColor];
}
/*
- (float) resPopUpBgAlphaValue
{
	return [[self threadViewTheme] popupBackgroundAlphaValue];
}
*/
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
