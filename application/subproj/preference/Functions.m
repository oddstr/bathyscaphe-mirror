#import "Functions.h"



/**
  * [�֐�] iT_setToolbarItem
  * 
  * �ς̎�����ToolbarItem��ǉ����Ă����B
  */
void iT_setToolbarItem(
	NSString            *identifier,
	NSMutableDictionary *dictionary,
	NSString            *label,
	NSString            *paletteLabel,
	NSString            *toolTip,
	id                   target,
	SEL                  settingSelector,
	id                   itemContent,
	SEL                  action,
	NSMenu              *menu)
{
	NSToolbarItem *item_;
	item_ = [[NSToolbarItem alloc] initWithItemIdentifier : identifier];
	[item_ setLabel : label];
	[item_ setPaletteLabel : paletteLabel];
	[item_ setToolTip : toolTip];
	[item_ setTarget : target];
	[item_ performSelector : settingSelector withObject : itemContent];
	[item_ setAction : action];
	if (menu != nil) {
		NSMenuItem *mItem = [[NSMenuItem alloc] init];
		[mItem setSubmenu : menu];
		[mItem setTitle : [menu title]];
		[item_ setMenuFormRepresentation : mItem];
		[mItem release];
	}
	[dictionary setObject : item_ forKey : identifier];
	[item_ release];
}

/*NSRange rangeOfStringZenHanInsensitive(NSString *text,
									   NSString *find,
									   unsigned options,
									   NSRange  searchRange)
{
	static NSRange _notFound      = {NSNotFound, 0};
	static NSRange _firstCharRng   = {0, 1};		//�擪1����
	static NSRange _firstCharRng2  = {0, 2};		//�擪2����
	
	NSString *firstChar_;	//�擪����
	NSRange   han_Rng_;		//���p�ł̌����͈�
	NSRange   zen_Rng_;		//�S�p�ł̌����͈�
	NSRange   result_;		//��������
	
	unsigned int start_index_;	//���������ꕶ����
	unsigned int i, cnt;
	
	if(nil == text || nil == find || 0 == searchRange.length) return _notFound;
	if(0 == (cnt = [find length])) return _notFound;
	if(0 == [text length]) return _notFound;
	
	// �S�p�E���p������1�����ڂ������B
	// ���ꂪ������Ȃ���΁A�������Ŏ��s
	firstChar_ = [find substringWithRange : _firstCharRng2];
	firstChar_ = han2Zen(firstChar_);
	firstChar_ = [firstChar_ substringWithRange : _firstCharRng];
	zen_Rng_ = [text rangeOfString : firstChar_
						   options : options
						     range : searchRange];

	firstChar_ = zen2Han(firstChar_);
	han_Rng_ = [text rangeOfString : firstChar_
						   options : options
						     range : searchRange];
	if(NSNotFound == zen_Rng_.location && NSNotFound == han_Rng_.location)
		return _notFound;
	
	NSCAssert(
		(zen_Rng_.location != han_Rng_.location),
		@"Error : zen2Han() or han2Zen() implement");
	
	// ���������ꕶ���ڂ̃C���f�b�N�X��
	// �O���������ǂ����Ŕ���B
	if(zen_Rng_.length > 0 && han_Rng_.length > 0){
		if(options & NSBackwardsSearch){
			start_index_ = (han_Rng_.location < zen_Rng_.location)
							? han_Rng_.location
							: zen_Rng_.location;
		}else{
			start_index_ = (han_Rng_.location > zen_Rng_.location)
							? han_Rng_.location
							: zen_Rng_.location;
		}
	}else if(NSNotFound == zen_Rng_.location){
		start_index_ = han_Rng_.location;
	}else{
		start_index_ = zen_Rng_.location;
	}
	
	
	//�擪�������}�b�`�����̂ŁA�c��̕�����
	//�}�b�`���邩�ǂ����𒲂ׂ�
	
	//�͈͂𒴂��Ȃ���
	result_.location = start_index_;
	result_.length = cnt;
	if(NO == (NSMaxRange(result_) <= NSMaxRange(searchRange)))
		return _notFound;
	
	return result_;
}*/