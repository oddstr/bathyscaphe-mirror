//:CMRThreadDownloadTask.m
#import "CMRThreadDownloadTask_p.h"



@implementation CMRThreadDownloadTask
- (id) initWithThreadViewer : (CMRThreadViewer *) tviewr
{
	if(self = [super init]){
		_threadViewer = [tviewr retain];
	}
	return self;
}
- (void) dealloc
{
	[_threadViewer release];
	[super dealloc];
}
- (void) doExecuteWithLayout : (CMRThreadLayout *) layout
{
	[CMRMainMessenger target : _threadViewer
			 performSelector : @selector(startDownload_veryPrivate)
				  withResult : YES];
}


// CMRTask
- (NSString *) identifier
{
	// 
	// �}�l�[�W���ɂ͓o�^���Ȃ�
	// 
	return nil;
}
@end
