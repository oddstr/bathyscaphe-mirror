/**
 * $Id: AppDefaults-Bundle.m,v 1.10.4.3 2006/09/18 11:26:21 tsawada2 Exp $
 * 
 * AppDefaults-Bundle.m
 *
 * Copyright (c) 2004 Takanori Ishikawa, All rights reserved.
 * See the file LICENSE for copying permission.
 */

#import "AppDefaults_p.h"
#import "w2chConnect.h"
#import "UTILKit.h"
#import "CMRMainMenuManager.h"
#import "BoardWarrior.h"

@protocol BSImagePreviewerProtocol;

// ----------------------------------------
// C O N S T A N T S
// ----------------------------------------

#define ImagePreviewerPluginName  @"ImagePreviewer"
#define ImagePreviewerPluginType  @"plugin"

#define PreferencesPanePluginName  @"PreferencesPane"
#define PreferencesPanePluginType  @"plugin"

#define w2chConnectorPluginName    @"2chConnector"
#define w2chConnectorPluginType    @"plugin"
#define w2chConnectorClassName     @"SG2chConnector"
#define w2chAuthenticaterClassName @"w2chAuthenticater"

static NSString *const AppDefaultsHelperAppNameKey = @"Helper Application Path";
static NSString *const AppDefaultsImagePreviewerSettingsKey = @"Preferences - ImagePreviewer Plugin";

static NSString *const AppDefaultsBWSettingsKey = @"Preferences - BoardWarrior";

static NSString *const kBWBBSMenuURLKey = @"BoardWarrior:bbsmenu URL";
static NSString *const kBWAutoSyncBoardListKey = @"BoardWarrior:Auto Sync";
static NSString *const kBWAutoSyncIntervalKey = @"BoardWarrior:Auto Sync Interval";
static NSString *const kBWLastSyncDateKey = @"BoardWarrior:Last Sync Date";

#pragma mark -

@implementation AppDefaults(BundleSupport)
- (NSMutableDictionary *) imagePreviewerPrefsDict
{
	if(nil == m_imagePreviewerDictionary){
		NSDictionary	*dict_;
		
		dict_ = [[self defaults] 
					dictionaryForKey : AppDefaultsImagePreviewerSettingsKey];
		m_imagePreviewerDictionary = [dict_ mutableCopy];
	}
	
	if(nil == m_imagePreviewerDictionary)
		m_imagePreviewerDictionary = [[NSMutableDictionary alloc] init];
	
	return m_imagePreviewerDictionary;
}

- (NSBundle *) moduleWithName : (NSString *) bundleName
                       ofType : (NSString *) type
                  inDirectory : (NSString *) bundlePath
{
    NSBundle    *bundles[] = {
                [NSBundle applicationSpecificBundle], 
                [NSBundle mainBundle],
                nil};
    NSBundle    **p = bundles;
    NSString    *path_ = nil;
    
    for (; *p != nil; p++)
        if (path_ = [*p pathForResource : bundleName
								 ofType : type
							inDirectory : bundlePath])
            break;
    /*NSBundle *bundle_;
    NSString *path_;
    
    bundle_ = [NSBundle mainBundle];
    
    path_ = [bundle_ pathForResource : bundleName 
                              ofType : type
                         inDirectory : bundlePath];*/
    
    if (nil == path_) {
        NSString *plugInsPath_;
        NSString *plugin_;

        plugin_ = [bundleName stringByAppendingPathExtension : type];
        //plugInsPath_ = [bundle_ builtInPlugInsPath];
		plugInsPath_ = [[NSBundle mainBundle] builtInPlugInsPath];
        path_ = [plugInsPath_ stringByAppendingPathComponent : plugin_];
    }
    return [NSBundle bundleWithPath : path_];
}

- (id) _imagePreviewer
{
    static Class kPreviewerInstance;
	NSString		*pClassName;

	pClassName = @"Unknown";
    
    if (Nil == kPreviewerInstance) {
        NSBundle		*module;
		NSDictionary	*infoPlist;
        
        module = [self moduleWithName : ImagePreviewerPluginName
                               ofType : ImagePreviewerPluginType
                          inDirectory : @"PlugIns"];

        if (nil == module) {
            NSLog(@"Couldn't load plugin<%@.%@>", ImagePreviewerPluginName, ImagePreviewerPluginType);
            return nil;
        }

		infoPlist = [module infoDictionary];
		pClassName = [infoPlist objectForKey : @"NSPrincipalClass"];

		if (pClassName) {
			Class pluginClass = NSClassFromString(pClassName);
			if (!pluginClass) {
				kPreviewerInstance = [module principalClass];
				//NSLog(@"We load plugin <%@.%@>, and load its principal class <%@>",
				//		ImagePreviewerPluginName, ImagePreviewerPluginType, pClassName);
			}
		}
    }
    if (Nil == kPreviewerInstance) {
        NSLog(@"Couldn't load principal class <%@> in <%@.%@>", 
                pClassName, ImagePreviewerPluginName, ImagePreviewerPluginType);
        return nil;
    }
	if ([kPreviewerInstance conformsToProtocol : @protocol(BSImagePreviewerProtocol)]) {
		return [[[kPreviewerInstance alloc] initWithPreferences : self] autorelease];
	} else {
        NSLog(@"Principal class <%@> doesn't conform to protocol BSImagePreviewerProtocol! So we cancel loading this plugin", 
                pClassName);
        return nil;
    }		
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
        st_class_PrefsPane_ = [module_ principalClass];
        }
    }
    if (Nil == st_class_PrefsPane_) {
        NSLog(@"Couldn't load principal class in <%@.%@>", 
                PreferencesPanePluginName,
                PreferencesPanePluginType);
        return nil;
    }
    
    return [[[st_class_PrefsPane_ alloc] initWithPreferences : self] autorelease];
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

- (id<BSImagePreviewerProtocol>) sharedImagePreviewer
{
    static id instance_;
    if (nil == instance_) {
        instance_ = [[self _imagePreviewer] retain];
    }
    return instance_;
}

#pragma mark -
- (NSString *) helperAppPath
{
	NSString *fullPath_;
	
	fullPath_ = [[self defaults] stringForKey : AppDefaultsHelperAppNameKey];
	return fullPath_ ? fullPath_ : [[NSWorkspace sharedWorkspace] fullPathForApplication : @"CMLogBuccaneer.app"];
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

#pragma mark -

- (void) _loadImagePreviewerSettings
{
}

- (BOOL) _saveImagePreviewerSettings
{
	NSDictionary			*dict_;
	
	dict_ = [self imagePreviewerPrefsDict];
	
	UTILAssertNotNil(dict_);
	[[self defaults] setObject : dict_
						forKey : AppDefaultsImagePreviewerSettingsKey];
	return YES;
}
@end


@implementation AppDefaults(BoardWarriorSupport)
- (NSMutableDictionary *) boardWarriorSettingsDictionary
{
	if(nil == m_boardWarriorDictionary){
		NSDictionary	*dict_;
		
		dict_ = [[self defaults] dictionaryForKey : AppDefaultsBWSettingsKey];
		m_boardWarriorDictionary = [dict_ mutableCopy];
	}
	
	if(nil == m_boardWarriorDictionary)
		m_boardWarriorDictionary = [[NSMutableDictionary alloc] init];
	
	return m_boardWarriorDictionary;
}

- (NSURL *) BBSMenuURL
{
	NSString *tmp_ = [[self boardWarriorSettingsDictionary] objectForKey: kBWBBSMenuURLKey
														   defaultObject: @"http://azlucky.s25.xrea.com/2chboard/bbsmenu2.html"];

	return [NSURL URLWithString: tmp_];
}
- (void) setBBSMenuURL : (NSURL *) anURL
{
	if (anURL == nil) return;
	NSString *tmp_ = [anURL absoluteString];
	[[self boardWarriorSettingsDictionary] setObject: tmp_ forKey : kBWBBSMenuURLKey];
}

- (BOOL) autoSyncBoardList
{
	return [[self boardWarriorSettingsDictionary] boolForKey: kBWAutoSyncBoardListKey defaultValue: NO];
}
- (void) setAutoSyncBoardList: (BOOL) autoSync
{
	[[self boardWarriorSettingsDictionary] setBool: autoSync forKey: kBWAutoSyncBoardListKey];
}

- (BSAutoSyncIntervalType) autoSyncIntervalTag
{
	return [[self boardWarriorSettingsDictionary] integerForKey: kBWAutoSyncIntervalKey defaultValue: BSAutoSyncByWeek];
}
- (void) setAutoSyncIntervalTag: (BSAutoSyncIntervalType) aType
{
	[[self boardWarriorSettingsDictionary] setInteger: aType forKey: kBWAutoSyncIntervalKey];
}

- (NSTimeInterval) timeIntervalForAutoSyncPrefs
{
	double interval_;

	switch ([self autoSyncIntervalTag]) {
	case BSAutoSyncByWeek:
		interval_ = 604800.0;
		break;
	case BSAutoSyncBy2weeks:
		interval_ = 1209600.0;
		break;
	case BSAutoSyncByMonth:
		interval_ = 2592000.0;
		break;
	default:
		interval_ = 0.0;
		break;
	}
	return interval_;
}

- (NSDate *) lastSyncDate
{
	return [[self boardWarriorSettingsDictionary] objectForKey: kBWLastSyncDateKey];
}
- (void) setLastSyncDate : (NSDate *) finishedDate
{
	[[self boardWarriorSettingsDictionary] setObject: finishedDate forKey: kBWLastSyncDateKey];
}

- (void) letBoardWarriorStartSyncing : (id) sender
{
	[[NSNotificationCenter defaultCenter]
	     addObserver : sender
	        selector : @selector(taskDidFail:)
	            name : BoardWarriorDidFailDownloadNotification
	          object : [BoardWarrior warrior]];
	[[NSNotificationCenter defaultCenter]
	     addObserver : sender
	        selector : @selector(taskDidFail:)
	            name : BoardWarriorDidFailCreateDefaultListTaskNotification
	          object : [BoardWarrior warrior]];
	[[NSNotificationCenter defaultCenter]
	     addObserver : sender
	        selector : @selector(taskDidFail:)
	            name : BoardWarriorDidFailSyncUserListTaskNotification
	          object : [BoardWarrior warrior]];

	[[NSNotificationCenter defaultCenter]
	     addObserver : sender
	        selector : @selector(downloadBBSMenuDidFinish:)
	            name : BoardWarriorDidFinishDownloadNotification
	          object : [BoardWarrior warrior]];
	[[NSNotificationCenter defaultCenter]
	     addObserver : sender
	        selector : @selector(createDefaultListWillStart:)
	            name : BoardWarriorWillStartCreateDefaultListTaskNotification
	          object : [BoardWarrior warrior]];
	[[NSNotificationCenter defaultCenter]
	     addObserver : sender
	        selector : @selector(syncUserListWillStart:)
	            name : BoardWarriorWillStartSyncUserListTaskNotification
	          object : [BoardWarrior warrior]];

	[[NSNotificationCenter defaultCenter]
	     addObserver : sender
	        selector : @selector(allSyncTaskDidFinish:)
	            name : BoardWarriorDidFinishAllTaskNotification
	          object : [BoardWarrior warrior]];

	[[BoardWarrior warrior] syncBoardLists];
}
/*
- (BOOL) canStartSyncTask
{
	return (NO == [[BoardWarrior warrior] isInProgress]);
}
*/
- (void) _loadBWSettings
{
}

- (BOOL) _saveBWSettings
{
	NSDictionary			*dict_;
	
	dict_ = [self boardWarriorSettingsDictionary];
	
	UTILAssertNotNil(dict_);
	[[self defaults] setObject : dict_
						forKey : AppDefaultsBWSettingsKey];
	return YES;
}
@end
