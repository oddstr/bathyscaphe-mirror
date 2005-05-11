//:AppDefaults-Alert.m
/**
  *
  * 警告や報告などをパネル表示
  *
  * @version 1.0.0d2 (01/11/29  6:02:35 PM)
  *
  */
#import "AppDefaults_p.h"

//////////////////////////////////////////////////////////////////////
////////////////////// [ 定数やマクロ置換 ] //////////////////////////
//////////////////////////////////////////////////////////////////////
static NSString *const _appDefaultsAlertTableName = @"AlertPanel";


@implementation AppDefaults(AlertPanel)
/**
  * パネルで使用されるローカライズ文字列
  * を検索するファイル名
  * 
  * @return     ファイル名
  */
+ (NSString *) tableForPanels
{
	return _appDefaultsAlertTableName;
}

/**
  * 決定ボタンに表示する文字列
  * 
  * @return     表示する文字列
  */
+ (NSString *) labelForDefaultButton
{
	return NSLocalizedStringFromTable(
						@"OK",
						[[self class] tableForPanels],
						@"Lable for DefaultButton");
}

/**
  * キャンセルボタンに表示する文字列
  * 
  * @return     表示する文字列
  */
+ (NSString *) labelForAlternateButton
{
	return NSLocalizedStringFromTable(
						@"Cancel",
						[[self class] tableForPanels],
						@"Lable for DefaultButton");
}

/**
  * アラートパネルを表示。
  * 
  * @param    title  タイトル
  * @param    msg    内容
  * @return          結果
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
  * ディレクトリを見つけることができず、作成も不可能だったため、
  * 警告を表示して、アプリケーションを終了させる。
  * 
  * @param    msg  メッセージ
  * @return        結果
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
  * アラートパネルを表示。
  * 
  * @param    title  タイトル
  * @param    msg    内容
  * @return          結果
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