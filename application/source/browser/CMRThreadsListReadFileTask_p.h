//:CMRThreadsListReadFileTask_p.h
#import "CMRThreadsListReadFileTask.h"
#import "CMRThreadsUpdateListTask_p.h"

#import "CMRThreadLayout.h"



@interface CMRThreadsListReadFileTask(Private)
- (NSString *) threadsListPath;
- (void) setThreadsListPath : (NSString *) aThreadsListPath;
- (unsigned) readingProgress;
- (void) setReadingProgress : (unsigned) aReadingProgress;

/**
  * CMRThreadsList.plist��ǂݍ���NSArray�̒��g��
  * mutable�ȃI�u�W�F�N�g�ɕϊ��B
  * 
  * @param    loadedList  CMRThreadsList.plist��ǂݍ���NSArray
  * @return               mutable�ȃX���b�h�ꗗ
  */
- (NSMutableArray *) convertThreadsList : (NSArray  *) loadedList;
- (NSMutableDictionary *) mutableDictionaryConvertFrom : (NSDictionary *) dict
										  subjectIndex : (unsigned int  ) index;
@end
