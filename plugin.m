//
//  plugin.m
//  ddb_menubar_playpause
//
//  Created by Alexey Yakovenko on 8/22/20.
//

#import <AppKit/AppKit.h>
#include <deadbeef/deadbeef.h>

static DB_functions_t *deadbeef;

@interface MenubarPlayPause : NSObject

@property (readwrite, strong) NSStatusItem *statusItem;

@end

@implementation MenubarPlayPause

- (instancetype)init
{
    self = [super init];
    if (!self) {
        return nil;
    }

    self.statusItem = [NSStatusBar.systemStatusBar statusItemWithLength:NSVariableStatusItemLength];
    self.statusItem.highlightMode = YES;
    self.statusItem.enabled = YES;
    self.statusItem.toolTip = @"Play/pause DeaDBeeF";
    self.statusItem.title = @"⏯";
    self.statusItem.button.target = self;
    self.statusItem.button.action = @selector(onStatusItemClicked:);


    return self;
}

- (void)onStatusItemClicked:(id)sender {
    deadbeef->sendmessage(DB_EV_TOGGLE_PAUSE, 0, 0, 0);
    // show window
    [NSApp activateIgnoringOtherApps:YES];

    // restore window if minimized
    for(NSWindow* win in [NSApp windows])
    {
        if([win isMiniaturized])
        {
            [win deminiaturize:self];
        }
    }
}

@end

#pragma mark - Plugin def

static MenubarPlayPause *playPause;

static int
plugin_start (void) {
    dispatch_async (dispatch_get_main_queue(), ^{
        playPause = [MenubarPlayPause new];
    });
    return 0;
}

static int
plugin_stop (void) {
    playPause = nil;
    return 0;
}

// define plugin interface
static DB_misc_t plugin = {
    DDB_PLUGIN_SET_API_VERSION
    .plugin.version_major = 1,
    .plugin.version_minor = 0,
    .plugin.type = DB_PLUGIN_MISC,
    .plugin.id = "menubar_playpause",
    .plugin.name = "Play/Pause menubar icon",
    .plugin.descr = "Play/Pause menubar icon",
    .plugin.copyright =
    "Play/Pause menubar icon\n"
    "Based on pull request: https://github.com/DeaDBeeF-Player/deadbeef/pull/2431"
    "Public domain\n"
    ,
    .plugin.website = "http://deadbeef.sf.net",
    .plugin.start = plugin_start,
    .plugin.stop = plugin_stop,
};

DB_plugin_t *
ddb_menubar_playpause_load (DB_functions_t *api) {
    deadbeef = api;
    return DB_PLUGIN (&plugin);
}

