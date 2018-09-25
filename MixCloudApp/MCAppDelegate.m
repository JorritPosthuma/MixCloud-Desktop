#import "MCAppDelegate.h"

@interface MCAppDelegate ()
@end

@interface WebPreferences (WebPreferencesPrivate)
// Just the bits we need from the full private API
// via https://code.google.com/p/webkit-mirror/source/browse/Source/WebKit/mac/WebView/WebPreferencesPrivate.h?r=3290f05ba8bef86d538b4b8dd4c61d1c03361f13
// and http://stackoverflow.com/questions/10609644/localstorage-not-persisting-in-osx-app-xcode-4-3
- (void)_setLocalStorageDatabasePath:(NSString *)path;
- (void) setLocalStorageEnabled: (BOOL) localStorageEnabled;
@end


@implementation MCAppDelegate

- (NSString *)run: (NSString *)script {
    return [self.webView stringByEvaluatingJavaScriptFromString: script];
}

- (void)playPause {
    [self run: @"$('.player-control,.mz-player-control').click()"];
    [self updateNowPlaying];
}


static NSString *nowPlayingJavaScript = @""
"[].slice.call(document.querySelectorAll(\""
    "[ng-bind='player.nowPlaying.currentDisplayTrack.artist'],"
    "[ng-bind='player.nowPlaying.currentDisplayTrack.title']"
"\")).map(function(e){return e.innerText}).join(' - ')";

static NSString *castNameJavaScript = @""
"[].slice.call(document.querySelectorAll(\""
"[ng-bind='player.currentCloudcast.owner'],"
"[ng-bind='player.currentCloudcast.title']"
"\")).map(function(e){return e.innerText}).join(' - ')";

- (void) updateNowPlaying {
    NSString *nowPlaying = [self run: nowPlayingJavaScript];
    NSString *effectiveTitle = @"MixCloud Desktop";
    if(nowPlaying && [nowPlaying length] >= 5) {
        if(self.lastTitle == nil || ![nowPlaying isEqualToString: self.lastTitle]) {
            NSString *castName = [self run: castNameJavaScript];
            NSUserNotification *notification = [[NSUserNotification alloc] init];
            notification.title = @"MixCloud";
            notification.informativeText = [NSString stringWithFormat:@"%@\n%@", nowPlaying, castName];
            [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];
            self.lastTitle = nowPlaying;
        }
        effectiveTitle = nowPlaying;
    }
    [self.window setTitle: effectiveTitle];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    [self loadSettings];
    [self updateUIFromSettings];
    [self.window setDelegate:self];
    [[NSUserNotificationCenter defaultUserNotificationCenter] setDelegate:self];
    self.titleUpdateTimer = [NSTimer scheduledTimerWithTimeInterval:10
                                                             target:self
                                                           selector:@selector(updateNowPlaying)
                                                           userInfo:nil
                                                            repeats:YES];
    // initialise and save preferences
    // via http://www.lostdecadegames.com/completing-your-native-mac-osx-app-built-in-h/
    // and http://stackoverflow.com/questions/8198453/local-storage-in-webview-is-not-persistent/18153115#18153115
    WebPreferences *prefs = [self.webView preferences];
    [prefs setAutosaves:YES];
    [prefs _setLocalStorageDatabasePath:@"~/Library/Application Support/MixCloudApp/LocalStorage"];
    [prefs setLocalStorageEnabled:YES];
    [prefs setJavaScriptEnabled:YES];
    [prefs setJavaScriptCanOpenWindowsAutomatically:YES];
    [self.webView setUIDelegate:self];
    [self.webView setGroupName:@"MixCloudApp"];
    // navigate to mixcloud
    [self.webView.mainFrame loadRequest: [NSURLRequest requestWithURL: [NSURL URLWithString: @"https://mixcloud.com"]]];

}

- (BOOL)userNotificationCenter:(NSUserNotificationCenter *)center
     shouldPresentNotification:(NSUserNotification *)notification
{
    // Always present our title notification bubbles
    return YES;
}

- (void)windowWillClose:(NSNotification *)aNotification {
	[NSApp terminate:self];
}

- (WebView *)webView:(WebView *)sender createWebViewWithRequest:(NSURLRequest *)request {
    return [self openPopup: request];
}

- (WebView *) openPopup:(NSURLRequest *) request {
    if(self.popupWindow != NULL) {
        [self.popupWindow close];
        self.popupWindow = NULL;
    }
    NSRect frame = CGRectMake(0, 0, 800, 600);
    NSWindow *win = [[NSWindow alloc] initWithContentRect:frame styleMask:(NSTitledWindowMask | NSClosableWindowMask) backing:NSBackingStoreBuffered defer:NO];
    [win setAnimationBehavior: NSWindowAnimationBehaviorAlertPanel];
    [win center];
    [win makeKeyAndOrderFront: self];
    self.popupWindow = win;
    WebView *view = (WebView*)[[WebView alloc] initWithFrame:frame];
    [win setContentView: view];
    [[view mainFrame] loadRequest: request];
    return view;
}

-(void)updateUIFromSettings {
    [self.showNotificationsMenuItem setState:(self.showNotifications ? NSOnState : NSOffState)];
}

-(void)updateSettingsFromUI {
    self.showNotifications = ([self.showNotificationsMenuItem state] == NSOnState ? TRUE : FALSE);
    [self saveSettings];
}

-(void)loadSettings {
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    self.showNotifications = [defaults boolForKey:@"ShowNotifications"];
}

-(void)saveSettings {
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:self.showNotifications forKey:@"ShowNotifications"];
}


-(IBAction)toggleShowNotifications:(id)sender {
    self.showNotifications = !self.showNotifications;
    [self saveSettings];
    [self updateUIFromSettings];
}


@end
