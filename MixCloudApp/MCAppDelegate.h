#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>

#import "SPMediaKeyTap.h"

@interface MCAppDelegate : NSObject <NSApplicationDelegate, NSWindowDelegate, WebUIDelegate>

@property (weak) IBOutlet WebView *webView;
@property (assign) IBOutlet NSWindow *window;

@property (retain) NSWindow *popupWindow;

@end
