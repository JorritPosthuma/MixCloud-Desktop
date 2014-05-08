#import "MCAppDelegate.h"

@interface MCAppDelegate ()
@property (nonatomic, strong) SPMediaKeyTap *keyTap;
@end

@implementation MCAppDelegate

- (NSString *)run: (NSString *)script {
    return [self.webView stringByEvaluatingJavaScriptFromString: script];
}

- (BOOL)isPaused {
    return [[self run: @"$('audio')[0].paused;"] isEqualToString: @"true"];
}

- (void)play {
    [self run: @"$('audio')[0].play();"];
}

- (void)pause {
    [self run: @"$('audio')[0].pause();"];
}

- (void)playPause {
    if ([self isPaused]) [self play];
    else [self pause];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    [self.webView.mainFrame loadRequest: [NSURLRequest requestWithURL: [NSURL URLWithString: @"http://mixcloud.com"]]];
	self.keyTap = [[SPMediaKeyTap alloc] initWithDelegate:self];
}

- (void)applicationDidBecomeActive:(NSNotification *)notification {
	if([SPMediaKeyTap usesGlobalMediaKeyTap]) {
		[self.keyTap startWatchingMediaKeys];
    }
}

-(void)mediaKeyTap:(SPMediaKeyTap*)keyTap receivedMediaKeyEvent:(NSEvent*)event; {
	int keyCode = (([event data1] & 0xFFFF0000) >> 16);
	int keyFlags = ([event data1] & 0x0000FFFF);
	BOOL keyIsPressed = (((keyFlags & 0xFF00) >> 8)) == 0xA;
	int keyRepeat = (keyFlags & 0x1);

	if (keyIsPressed) {
		NSString *debugString = [NSString stringWithFormat:@"%@", keyRepeat?@", repeated.":@"."];
		switch (keyCode) {
			case NX_KEYTYPE_PLAY:
				debugString = [@"Play/pause pressed" stringByAppendingString:debugString];
                [self playPause];
				break;
				
			case NX_KEYTYPE_FAST:
				debugString = [@"Ffwd pressed" stringByAppendingString:debugString];
				break;
				
			case NX_KEYTYPE_REWIND:
				debugString = [@"Rewind pressed" stringByAppendingString:debugString];
				break;

			default:
				debugString = [NSString stringWithFormat:@"Key %d pressed%@", keyCode, debugString];
				break;
		}
		NSLog(@"%@", debugString);
	}
}

@end