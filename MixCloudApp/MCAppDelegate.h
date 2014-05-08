#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>

#import "SPMediaKeyTap.h"

@interface MCAppDelegate : NSObject <NSApplicationDelegate>

@property (weak) IBOutlet WebView *webView;
@property (assign) IBOutlet NSWindow *window;

@end
