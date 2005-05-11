//:CMRThreadsList-Search.m
/**
  *
  * �X���b�h�̌������T�|�[�g
  *
  * @version 1.0.0d2 (01/12/23  11:32:58 AM)
  *
  */

#import "CMRThreadsList_p.h"
/*
typedef enum _ThreadsListSearchMask{
	ThreadsListTitleSeach = 1,			//�^�C�g���Ō���
	ThreadsListPathSearch = 1 << 1,		//�p�X������Ō����@
} ThreadsListSearchMask;
*/
/**
  * [�֐�]_seachByLogFilePath
  * 
  * �X���b�h�T���Ńp�X�����S�Ɉ�v����ꍇ��YES��Ԃ��B
  * context�ɂ̓p�X�������n�����ƁB
  * 
  * @param    thread    �������e�X�g����X���b�h�B
  * @param    context   �p�X������
  */
static BOOL _seachByLogFilePath(NSDictionary *thread, void *context)
{
	NSString *path_;		//�����ƂȂ�p�X������
	NSString *target_;		//�e�X�g����p�X������
	
	path_ = (NSString *)context;
	NSCAssert(
		(path_ == nil || [path_ respondsToSelector : @selector(isSameAsString:)]),
		@"_seachByLogFilePath  context must be NSString!");
	
	target_ = [CMRThreadAttributes pathFromDictionary : thread];
	UTILCAssertNotNil(target_);
	
	if(target_ == nil && path_ == nil) return YES;
	if(target_ == nil || path_ == nil) return NO;
	
	return [path_ isSameAsString : target_];
}

/**
  * [�֐� : _func4type]
  * ThreadsListSearchType�ɑΉ����錟���p�֐���Ԃ��B
  */
static TLSearchFunction _func4type(ThreadsListSearchType type){
	switch(type){
	case ThreadsListTitleSeach:
		return _seachByLogFilePath;
		break;
	case ThreadsListPathSearch:
		return _seachByLogFilePath;
		break;
	default:
		return _seachByLogFilePath;
		break;
	}
	return _seachByLogFilePath;
}


@implementation CMRThreadsList(SearchThreads)
/**
  * ���O�t�@�C���̕ۑ��ꏊ���w�肳�ꂽ�p�X��
  * �X���b�h�ւ̎Q�Ƃ�Ԃ��B
  * ������Ȃ���΁Anil��Ԃ��B
  * 
  * @param    filepath  ���O�t�@�C���̕ۑ��ꏊ
  * @return             �X���b�h
  */
- (NSMutableDictionary *) seachThreadByPath : (NSString *) filepath
{
	id thread_;					//�X���b�h��������
	
	// ���Ƀ��O���擾���Ă���΁A�����Ɋi�[���Ă���B
	// ���O�����݂��Ȃ��ꍇ��NSNull���i�[���Ă���B
	thread_ = [[self threadsInfo] objectForKey : filepath];
	if(thread_ != nil && (NO == [thread_ isEqual : [NSNull null]]))
		return thread_;
	
	// ���O���Ȃ���΁A�ꗗ���猟���B
	thread_ = [self seachThreadByPath : filepath inArray : [self threads]];
	
	return thread_;
}

/**
  * ���O�t�@�C���̕ۑ��ꏊ���w�肳�ꂽ�p�X��
  * �X���b�h�ւ̎Q�Ƃ�Ԃ��B
  * ������Ȃ���΁Anil��Ԃ��B
  * 
  * @param    filepath  ���O�t�@�C���̕ۑ��ꏊ
  * @return             �X���b�h
  */
- (NSMutableDictionary *) seachThreadByPath : (NSString *) filepath
									inArray : (NSArray  *) array
{
	NSArray *matched_;		//���������X���b�h
	
	matched_ = [self _seachThreads : ThreadsListPathSearch
						   inArray : array
						   context : filepath];
	//������Ȃ���΁Anil��Ԃ��B
	if([matched_ count] == 0) return nil;
	
	//�p�X������̈�v����X���b�h�͂ЂƂ����Ȃ��B
	NSAssert(
		([matched_ count] == 1),
		@"duplicated threadsList.");
	
	return [matched_ objectAtIndex : 0];
}

/**
  * �ێ����Ă���X���b�h�ꗗ��T�����A�����Ƀ}�b�`�����X���b�h��
  * �i�[����ꎞ�I�Ȕz��I�u�W�F�N�g��V���ɍ���ĕԂ��B
  * �����̃e�X�g�ɂ́Achecker�Ŏw�肳�ꂽ�֐����g���B���̊֐���
  * �������Q�Ƃ�A���ʂƂ���BOOL�l��Ԃ��֐��łȂ��Ă͂Ȃ�Ȃ��B
  * ��1�����ɃX���b�h�̎������n����A��2�����ɂ�context���n�����B
  * 
  * �i�֐���jBOOL mtCheck(NSDictionary *thread, void *context);
  * 
  * �܂��A�����Ƀ}�b�`����X���b�h���ЂƂ��Ȃ��ꍇ�͋�̔z���Ԃ��B
  * 
  * @param    checker  �������e�X�g����֐�
  * @param    context  �֐��ɓn�����
  * @return            �����Ƀ}�b�`�����X���b�h
  */
- (NSArray *) seachThreadsUsingFunction : (TLSearchFunction)checker 
                                context : (void  *) context
{
	//�ێ����Ă���X���b�h�ꗗ����T������B
	
	return [self _seachThreadsUsingFunction : checker
							        inArray : [self threads]
							        context : context];
}

//-------------------------------------------------------------------
//-------------------------------------------------------------------
//-------------------------------------------------------------------
/**
  * �w�肵���X���b�h�ꗗ����T���B
  * 
  * @see seachThreadsUsingFunction:context:
  *
  * @param    type     ���������̎��
  * @param    array    �T���ΏۂƂȂ�z��I�u�W�F�N�g
  * @param    context  �֐��ɓn�����
  * @return            �����Ƀ}�b�`�����X���b�h
  */

- (NSArray *) _seachThreads : (ThreadsListSearchType) type
			        inArray : (NSArray *) array
			        context : (void    *) context
{
	return [self _seachThreadsUsingFunction : _func4type(type)
							        inArray : array
							        context : context];
}

/**
  * �w�肵���X���b�h�ꗗ����T���B
  * 
  * @see seachThreadsUsingFunction:context:
  *
  * @param    checker  �������e�X�g����֐�
  * @param    array    �T���ΏۂƂȂ�z��I�u�W�F�N�g
  * @param    context  �֐��ɓn�����
  * @return            �����Ƀ}�b�`�����X���b�h
  */

- (NSArray *) _seachThreadsUsingFunction : (TLSearchFunction)checker 
							     inArray : (NSArray *) array
							     context : (void *) context
{
	NSMutableArray *result_;		//�����Ƀ}�b�`�����X���b�h
	NSEnumerator   *iter_;			//�X���b�h�������T��
	NSDictionary   *thread_;		//�e�X�g���̃X���b�h
	
	result_ = [NSMutableArray array];
	if(nil == array || NULL == checker) return result_;

	iter_ = [array objectEnumerator];
	
	// �e�X���b�h�������T�����Achecker�֐���YES��Ԃ���
	// �X���b�h�ɂ��Ă͉ϔz��ɒǉ����Ă����B
	while(thread_ = [iter_ nextObject]){
		if(checker(thread_, context)){
			[result_ addObject : thread_];
		}
	}
	
	return result_;
}
@end
