#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>

@interface MCAppDelegate : NSObject <NSApplicationDelegate, NSWindowDelegate, WebUIDelegate, NSUserNotificationCenterDelegate>

@property (weak) IBOutlet WebView *webView;
@property (assign) IBOutlet NSWindow *window;

@property (retain) NSWindow *popupWindow;

@property (retain) NSTimer *titleUpdateTimer;
@property (retain) NSString *lastTitle;

@property (assign) BOOL showNotifications;
@property (weak) IBOutlet NSMenuItem *showNotificationsMenuItem;


@end
