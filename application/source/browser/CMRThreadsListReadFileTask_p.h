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
  * CMRThreadsList.plistを読み込んだNSArrayの中身を
  * mutableなオブジェクトに変換。
  * 
  * @param    loadedList  CMRThreadsList.plistを読み込んだNSArray
  * @return               mutableなスレッド一覧
  */
- (NSMutableArray *) convertThreadsList : (NSArray  *) loadedList;
- (NSMutableDictionary *) mutableDictionaryConvertFrom : (NSDictionary *) dict
										  subjectIndex : (unsigned int  ) index;
@end
