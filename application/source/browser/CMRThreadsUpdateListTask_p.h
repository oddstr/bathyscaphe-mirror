//:CMRThreadsUpdateListTask_p.h
#import "CMRThreadsUpdateListTask.h"

#import "CMRThreadAttributes.h"
#import "CMRThreadsList.h"
#import "CMRThreadLayout.h"



@interface CMRThreadsUpdateListTask(Private)
/**
  * CMRThreadsList.plist��ǂݍ���mutable�Ȕz��̒��g��
  * �s�����Ă���p�����[�^������΁AthreadsInfo�܂���
  * fromPath�����̃��O�t�@�C������ǉ�����B
  * ����ƂƂ��ɁAthreadsInfo��V�������ɍX�V�B
  * ���X�g�̍X�V���ɂ�isUpdatedList��YES�ɐݒ肷��B
  * 
  * [�p�r]
  * �@���X�g�̏���ǂݍ��ݎ��ɂ�threadsInfo�ɋ�̎�����n�����ƂŁA
  * �X�V���ɔ�����threadsInfo���X�V�B�܂��A�O�o�[�W�����Ƃ̌݊��̂��߁A
  * path�ɂ͌f���̃p�X��n���B
  * 
  * �@���񂩂�̍X�V���ɂ̓_�E�����[�h����subject.txt�̒��g�i�ϔz��j
  * �Ƌ��ɑO���threadsInfo��n���A�X���b�h���X�g���X�V����B
  *
  * @param    loadedList     CMRThreadsList.plist��ǂݍ��񂾉ϔz��
  * @param    threadsInfo    �O��擾�������̃X���b�h���(key:���O�t�@�C���̕ۑ��ꏊ)
  * @param    isUpdatedList  ���X�g�̍X�V���ɂ�YES
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



