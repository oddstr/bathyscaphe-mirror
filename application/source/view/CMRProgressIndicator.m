//: CMRProgressIndicator.m
/**
  * $Id: CMRProgressIndicator.m,v 1.3 2005/09/24 06:07:49 tsawada2 Exp $
  * 
  * Copyright (c) 2001-2003, Takanori Ishikawa.
  * See the file LICENSE for copying permission.
  */

#import "CMRProgressIndicator.h"
#import "CMRTask.h"
#import "CMRTaskManager.h"

@implementation CMRProgressIndicator
- (void) mouseUp : (NSEvent *) theEvent
{
	[super mouseUp : theEvent];
	/*
		2005-07-04 tsawada2 <ben-sawa@td5.so-net.ne.jp>
		isDisplayWhenStopped が YES の場合、プログレスインジケータが動いていない時は自動的に
		プログレスインジケータが非表示になる。しかし、このときでも、その位置をクリックすると
		クリックイベントに反応してしまう。
		
		NSProgressIndicator が現在隠れているか（＝動いていないか）を判断するメソッドが
		ないようなので、CMRTask が isInProgress かどうかでチェックすることにする。
	*/
	if ((![self isDisplayedWhenStopped]) && ([[CMRTaskManager defaultManager] isInProgress]))
		[[CMRTaskManager defaultManager] showWindow : nil];
}
@end
