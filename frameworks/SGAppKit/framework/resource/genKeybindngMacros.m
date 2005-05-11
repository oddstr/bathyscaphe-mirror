//:test.m.m
/**
  *
  * 
  *
  * @author Takanori Ishikawa
  * @author http://www15.big.or.jp/~takanori/
  * @version 1.0.0d1 (02/10/03  7:34:41 PM)
  *
  */
#import <Cocoa/Cocoa.h>



static unichar keys[] = {
NSUpArrowFunctionKey,
NSDownArrowFunctionKey,
NSLeftArrowFunctionKey,
NSRightArrowFunctionKey,
NSF1FunctionKey,
NSF2FunctionKey,
NSF3FunctionKey,
NSF4FunctionKey,
NSF5FunctionKey,
NSF6FunctionKey,
NSF7FunctionKey,
NSF8FunctionKey,
NSF9FunctionKey,
NSF10FunctionKey,
NSF11FunctionKey,
NSF12FunctionKey,
NSF13FunctionKey,
NSF14FunctionKey,
NSF15FunctionKey,
NSF16FunctionKey,
NSF17FunctionKey,
NSF18FunctionKey,
NSF19FunctionKey,
NSF20FunctionKey,
NSF21FunctionKey,
NSF22FunctionKey,
NSF23FunctionKey,
NSF24FunctionKey,
NSF25FunctionKey,
NSF26FunctionKey,
NSF27FunctionKey,
NSF28FunctionKey,
NSF29FunctionKey,
NSF30FunctionKey,
NSF31FunctionKey,
NSF32FunctionKey,
NSF33FunctionKey,
NSF34FunctionKey,
NSF35FunctionKey,
NSInsertFunctionKey,
NSDeleteFunctionKey,
NSHomeFunctionKey,
NSBeginFunctionKey,
NSEndFunctionKey,
NSPageUpFunctionKey,
NSPageDownFunctionKey,
NSPrintScreenFunctionKey,
NSScrollLockFunctionKey,
NSPauseFunctionKey,
NSSysReqFunctionKey,
NSBreakFunctionKey,
NSResetFunctionKey,
NSStopFunctionKey,
NSMenuFunctionKey,
NSUserFunctionKey,
NSSystemFunctionKey,
NSPrintFunctionKey,
NSClearLineFunctionKey,
NSClearDisplayFunctionKey,
NSInsertLineFunctionKey,
NSDeleteLineFunctionKey,
NSInsertCharFunctionKey,
NSDeleteCharFunctionKey,
NSPrevFunctionKey,
NSNextFunctionKey,
NSSelectFunctionKey,
NSExecuteFunctionKey,
NSUndoFunctionKey,
NSRedoFunctionKey,
NSFindFunctionKey,
NSHelpFunctionKey,
NSModeSwitchFunctionKey,
NSLineSeparatorCharacter,
NSTabCharacter,
NSFormFeedCharacter,
NSNewlineCharacter,
NSCarriageReturnCharacter,
NSEnterCharacter,
NSBackspaceCharacter,
NSBackTabCharacter,
NSDeleteCharacter,
0
};

static NSString *names[] = {
@"UpArrow",
@"DownArrow",
@"LeftArrow",
@"RightArrow",
@"F1",
@"F2",
@"F3",
@"F4",
@"F5",
@"F6",
@"F7",
@"F8",
@"F9",
@"F10",
@"F11",
@"F12",
@"F13",
@"F14",
@"F15",
@"F16",
@"F17",
@"F18",
@"F19",
@"F20",
@"F21",
@"F22",
@"F23",
@"F24",
@"F25",
@"F26",
@"F27",
@"F28",
@"F29",
@"F30",
@"F31",
@"F32",
@"F33",
@"F34",
@"F35",
@"Insert",
@"Delete",
@"Home",
@"Begin",
@"End",
@"PageUp",
@"PageDown",
@"PrintScreen",
@"ScrollLock",
@"Pause",
@"SysReq",
@"Break",
@"Reset",
@"Stop",
@"Menu",
@"User",
@"System",
@"Print",
@"ClearLine",
@"ClearDisplay",
@"InsertLine",
@"DeleteLine",
@"InsertChar",
@"DeleteChar",
@"Prev",
@"Next",
@"Select",
@"Execute",
@"Undo",
@"Redo",
@"Find",
@"Help",
@"ModeSwitch",
@"LineSeparator",
@"Tab",
@"FormFeed",
@"Newline",
@"CarriageReturn",
@"Enter",
@"Backspace",
@"BackTab",
@"Delete",
nil
};



int main(int argc, char *argv[])
{
	NSAutoreleasePool	*pool_ = [[NSAutoreleasePool alloc] init];
	
	unichar		*keys_ = keys;
	NSString	**names_ = names;
	NSMutableDictionary		*dict;
	
	dict = [[NSMutableDictionary alloc] init];
	for(; *keys_ != 0; keys_++){
		
		[dict setObject:[NSNumber numberWithUnsignedInt:*keys_]
				forKey : *names_];
		
		names_++;
	}
	
	[dict writeToFile:@"Keybinding.plist" atomically:YES];
	[pool_ release];
	return 0;
}