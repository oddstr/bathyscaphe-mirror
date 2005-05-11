//:CMRThreadsUpdateListTask_p.h
#import "CMRThreadsUpdateListTask.h"

#import "CMRThreadAttributes.h"
#import "CMRThreadsList.h"
#import "CMRThreadLayout.h"



@interface CMRThreadsUpdateListTask(Private)
/**
  * CMRThreadsList.plistを読み込んだmutableな配列の中身を
  * 不足しているパラメータがあれば、threadsInfoまたは
  * fromPath直下のログファイルから追加する。
  * それとともに、threadsInfoを新しい情報に更新。
  * リストの更新時にはisUpdatedListをYESに設定する。
  * 
  * [用途]
  * 　リストの初回読み込み時にはthreadsInfoに空の辞書を渡すことで、
  * 更新時に備えてthreadsInfoを更新。また、前バージョンとの互換のため、
  * pathには掲示板のパスを渡す。
  * 
  * 　次回からの更新時にはダウンロードしたsubject.txtの中身（可変配列）
  * と共に前回のthreadsInfoを渡し、スレッドリストを更新する。
  *
  * @param    loadedList     CMRThreadsList.plistを読み込んだ可変配列
  * @param    threadsInfo    前回取得した分のスレッド情報(key:ログファイルの保存場所)
  * @param    isUpdatedList  リストの更新時にはYES
  */
- (void) addParameterForThreadsList : (NSArray             *) loadedList
                           fromInfo : (NSMutableDictionary *) threadsInfo
                             update : (BOOL                 ) isUpdatedList;


- (NSMutableArray *) threadsArray;
- (void) setThreadsArray : (NSMutableArray *) aThreadsArray;
- (NSMutableDictionary *) pathMappingTbl;
- (void) setPathMappingTbl : (NSMutableDictionary *) aPathMappingTbl;
- (BOOL) isUpdate;
- (void) setIsUpdate : (BOOL) anIsUpdate;

- (unsigned) progress;
- (void) setProgress : (unsigned) aProgress;
@end



