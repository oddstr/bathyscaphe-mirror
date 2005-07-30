/**
 * $Id: AppDefaults-Bundle.m,v 1.4 2005/07/30 22:30:09 tsawada2 Exp $
 * 
 * AppDefaults-Bundle.m
 *
 * Copyright (c) 2004 Takanori Ishikawa, All rights reserved.
 * See the file LICENSE for copying permission.
 */

#import "AppDefaults_p.h"
#import "BoardManager.h"
#import "TextFinder.h"
#import "w2chConnect.h"
#import "UTILKit.h"
#import "CMRMainMenuManager.h"



// ----------------------------------------
// C O N S T A N T S
// ----------------------------------------
#define BoardListEditorPluginName  @"BoardListEditor"
#define BoardListEditorPluginType  @"plugin"
#define BoardListEditorClassName   @"BoardListEditor"

#define PreferencesPanePluginName  @"PreferencesPane"
#define PreferencesPanePluginType  @"plugin"
#define PreferencesPaneClassName   @"PreferencesPane"

#define w2chConnectorPluginName    @"2chConnector"
#define w2chConnectorPluginType    @"plugin"
#define w2chConnectorClassName     @"SG2chConnector"
#define w2chAuthenticaterClassName @"w2chAuthenticater"

static NSString *const AppDefaultsHelperAppNameKey = @"Helper Application Path";



@implementation AppDefaults(BundleSupport)
- (NSBundle *) moduleWithName : (NSString *) bundleName
                       ofType : (NSString *) type
                  inDirectory : (NSString *) bundlePath
{
    NSBundle *bundle_;
    NSString *path_;
    
    bundle_ = [NSBundle mainBundle];
    
    path_ = [bundle_ pathForResource : bundleName 
                              ofType : type
                         inDirectory : bundlePath];
    
    if (nil == path_) {
        NSString *plugInsPath_;
        NSString *plugin_;

        plugin_ = [bundleName stringByAppendingPathExtension : type];
        plugInsPath_ = [bundle_ builtInPlugInsPath];
        path_ = [plugInsPath_ stringByAppendingPathComponent : plugin_];
    }
    return [NSBundle bundleWithPath : path_];
}


/*
- (void) test 
{
    NSBundle *module;
    BOOL ret;
    
    UTILMethodLog;
    
    module = [NSBundle bundleWithIdentifier : @"com.apple.AppleScriptKit"];
    if (nil == module) {
        module = [NSBundle bundleWithPath : @"/System/Library/Frameworks/AppleScriptKit.framework"];
    }
    
    ret = [module load];
    NSLog(@"Loading new module... %@", UTILBOOLString(ret));
    NSLog(@"Done. module=%@", [module description]);
    
    module = [self moduleWithName : @"BoardWarrior"
                           ofType : @"app"
                      inDirectory : nil];
    
    ret = [module load];
    NSLog(@"Loading new module... %@", UTILBOOLString(ret));
    NSLog(@"Done. module=%@", [module description]);
    NSLog(@"- [module principalClass] = %@", NSStringFromClass([module principalClass]));
    NSLog(@"- [module infoDictionary] = %@", [[module infoDictionary] description]);
    
    ret = [module loadNibFile:@"MainWindow" 
    externalNameTable:
    [NSDictionary dictionaryWithObject:NSApp forKey:@"NSOwner"]
    withZone:[self zone]];
    NSLog(@"Load MainMenu.nib... (%@)", UTILBOOLString(ret));
    
    Class klass = [module classNamed : @"BWController"];

    NSLog(@"- [module classNamed:] = %@", NSStringFromClass(klass));
}
*/
- (id) _boardListEditor
{
    static Class kEditorInstance;
    
    if (Nil == kEditorInstance) {
        NSBundle *module;
        
        module = [self moduleWithName : BoardListEditorPluginName
                               ofType : BoardListEditorPluginType
                          inDirectory : nil];
        if (nil == module) {
            NSLog(@"Couldn't load plugin<%@.%@>", 
                    BoardListEditorPluginName,
                    BoardListEditorPluginType);
            return nil;
        }
        kEditorInstance = [module classNamed : BoardListEditorClassName];
    }
    if (Nil == kEditorInstance) {
        NSLog(@"Couldn't load Class<%@> in <%@.%@>", 
                BoardListEditorClassName,
                BoardListEditorPluginName,
                BoardListEditorPluginType);
        return nil;
    }
    
    return [[[kEditorInstance alloc]
       initWithDefaultList : [[BoardManager defaultManager] defaultList]
                  userList : [[BoardManager defaultManager] userList]]
            autorelease];
}

- (id) sharedBoardListEditor
{
    static id instance_;
    if (nil == instance_) {
        instance_ = [[self _boardListEditor] retain];
    }
    return instance_;
}

- (id) _preferencesPane
{
    static Class st_class_PrefsPane_;
    if (Nil == st_class_PrefsPane_) {
        NSBundle *module_;
        
        module_ = [self moduleWithName : PreferencesPanePluginName
                                ofType : PreferencesPanePluginType
                           inDirectory : nil];
        if (nil == module_) {
            NSLog(@"Couldn't load plugin<%@.%@>", 
                    PreferencesPanePluginName,
                    PreferencesPanePluginType);
            return nil;
        } else {
        st_class_PrefsPane_ = [module_ classNamed : PreferencesPaneClassName];
        }
    }
    if (Nil == st_class_PrefsPane_) {
        NSLog(@"Couldn't load Class<%@> in <%@.%@>", 
                PreferencesPaneClassName,
                PreferencesPanePluginName,
                PreferencesPanePluginType);
        return nil;
    }
    
    return [[[st_class_PrefsPane_ alloc]
       initWithPreferences : self] autorelease];
}

- (id<w2chConnect>) w2chConnectWithURL : (NSURL        *) anURL
                            properties : (NSDictionary *) properties
{
    static Class st_class_2chAuthenticater;
    static Class st_class_2chConnector;
    
    if (Nil == st_class_2chConnector) {
        NSBundle *module_;
        
        module_ = [self moduleWithName : w2chConnectorPluginName
                                ofType : w2chConnectorPluginType
                           inDirectory : nil];
        if (nil == module_) {
            NSLog(@"Couldn't load plugin<%@.%@>", 
                    w2chConnectorPluginName,
                    w2chConnectorPluginType);
            return nil;
        } else {
            if (Nil == st_class_2chAuthenticater) {
                st_class_2chAuthenticater = 
                  [module_ classNamed : w2chAuthenticaterClassName];
                NSAssert3(
                    (st_class_2chAuthenticater != Nil),
                    @"Couldn't load Class<%@> in <%@.%@>",
                    w2chAuthenticaterClassName,
                    w2chConnectorPluginName,
                    w2chConnectorPluginType);
                [st_class_2chAuthenticater setPreferencesObject : self];
            }
            st_class_2chConnector = [module_ classNamed : w2chConnectorClassName];
        }
    }
    if (Nil == st_class_2chConnector) {
        NSLog(@"Couldn't load Class<%@> in <%@.%@>", 
                w2chConnectorClassName,
                w2chConnectorPluginName,
                w2chConnectorPluginType);
        return nil;
    }
    
    return [st_class_2chConnector connectorWithURL : anURL
                              additionalProperties : properties];
}


- (id) sharedPreferencesPane
{
    static id instance_;
    if (nil == instance_) {
        instance_ = [[self _preferencesPane] retain];
    }
    return instance_;
}

- (NSString *) helperAppPath
{
	NSString *fullPath_;
	
	fullPath_ = [[self defaults] stringForKey : AppDefaultsHelperAppNameKey];
	return fullPath_ ? fullPath_ : [[NSWorkspace sharedWorkspace] fullPathForApplication : @"CMLogFinder.app"];
}
- (void) setHelperAppPath : (NSString *) fullPath_
{
	if (nil == fullPath_) {
		[[self defaults] removeObjectForKey : AppDefaultsHelperAppNameKey];
		return;
	}
	[[self defaults] setObject : fullPath_
						forKey : AppDefaultsHelperAppNameKey];
}

- (NSString *) helperAppDisplayName
{
	NSString *tmp_ = [self helperAppPath];
	
	if (tmp_) {
		NSString	*displayName_;
		displayName_ = [[NSFileManager defaultManager] displayNameAtPath: tmp_];
		return displayName_;
	}

	return nil;
}
@end
