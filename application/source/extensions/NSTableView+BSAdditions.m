//
//  NSTableView+BSAdditions.m
//  BathyScaphe
//
//  Created by Tsutomu Sawada on 05/06/20.
//  Copyright 2005 tsawada2. All rights reserved.
//

#import "NSTableView+BSAdditions.h"


@implementation NSTableView(BathyScapheAdditions)
// NSDraggingSource の各メソッドを 自身のデータソース・クラスに丸投げする
// BoardList-OVDataSource.m, CMRThreadsList-DataSource.m を参照。

// 本当は、これは NSTableView のサブクラスを作ってそこに書くべきなのだろうが、
// サブクラスを作るのが何となく面倒なのでカテゴリでごまかし。

- (unsigned int) draggingSourceOperationMaskForLocal : (BOOL) localFlag
{
	id				source_;
	source_ = [self dataSource];

	if(source_ != nil && [source_ respondsToSelector : _cmd]) {
		return [source_ draggingSourceOperationMaskForLocal : localFlag];
	} else {
		return NSDragOperationGeneric;
	}
}

- (void) draggedImage : (NSImage	   *) anImage
			  endedAt : (NSPoint		) aPoint
			operation : (NSDragOperation) operation
{
	id		source_;
	
	source_ = [self dataSource];
	if([source_ respondsToSelector : _cmd])
		[source_ draggedImage:anImage endedAt:aPoint operation:operation];
}
@end
