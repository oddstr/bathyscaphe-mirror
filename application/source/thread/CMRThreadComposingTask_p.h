//:CMRThreadComposingTask_p.h
#import "CMRThreadComposingTask.h"

#import "CMRThreadLayout.h"
#import "CMRThreadLayout_p.h"
#import "CMRThreadContentsReader.h"

#import "CMRThreadVisibleRange.h"


/*!
 * @defined     NMESSAGES_PER_LAYOUT
 * @discussion  一度にレイアウトするレス数
 */
#define NMESSAGES_PER_LAYOUT		30

