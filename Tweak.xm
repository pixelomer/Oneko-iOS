#import "resources.h"
#import "Oneko.h"

@interface UIScreen(Private)
- (CGRect)_referenceBounds;
@end

@interface UIWindow(Private)
- (UIInterfaceOrientation)interfaceOrientation;
- (void)_rotateWindowToOrientation:(UIInterfaceOrientation)orientation
    updateStatusBar:(BOOL)updateStatusBar duration:(CGFloat)duration
    skipCallbacks:(BOOL)skipCallbacks;
@end

@interface SpringBoard : UIApplication
- (BOOL)isLocked;
- (NSSet<UIWindowScene *> *)connectedScenes;
@end

@interface OnekoWindow : UIWindow
@end

@implementation OnekoWindow
- (BOOL)autorotates {
    return NO;
}
- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    return NO;
}
@end

@interface OnekoViewController : UIViewController
@end

@implementation OnekoViewController
- (BOOL)shouldAutorotate {
    return NO;
}
@end

//FIXME: There has to be a better way to do this
static CGPoint TranslatePoint(CGPoint point, CGSize bounds,
    UIInterfaceOrientation from, UIInterfaceOrientation to)
{
    CGPoint ret = point;
    const CGFloat origX = point.x;
    const CGFloat origY = point.y;
    const CGFloat mirroredX = bounds.width - origX;
    const CGFloat mirroredY = bounds.height - origY;
    
    switch (from) {
        case UIInterfaceOrientationPortraitUpsideDown: switch (to) {
            case UIInterfaceOrientationPortraitUpsideDown:
                // no change
                break;
            case UIInterfaceOrientationLandscapeRight:
                ret = CGPointMake(mirroredY, origX);
                break;
            case UIInterfaceOrientationLandscapeLeft:
                ret = CGPointMake(origY, mirroredX);
                break;
            case UIInterfaceOrientationPortrait:
                ret = CGPointMake(mirroredX, mirroredY);
            default:
                break;
        }
        break;
        case UIInterfaceOrientationLandscapeRight: switch (to) {
            case UIInterfaceOrientationPortraitUpsideDown:
                ret = CGPointMake(origY, mirroredX);
                break;
            case UIInterfaceOrientationLandscapeRight:
                // no change
                break;
            case UIInterfaceOrientationLandscapeLeft:
                ret = CGPointMake(mirroredX, mirroredY);
                break;
            case UIInterfaceOrientationPortrait:
                ret = CGPointMake(mirroredY, origX);
            default:
                break;
        }
        break;
        case UIInterfaceOrientationLandscapeLeft: switch (to) {
            case UIInterfaceOrientationPortraitUpsideDown:
                ret = CGPointMake(mirroredY, origX);
                break;
            case UIInterfaceOrientationLandscapeRight:
                ret = CGPointMake(mirroredX, mirroredY);
                break;
            case UIInterfaceOrientationLandscapeLeft:
                // no change
                break;
            case UIInterfaceOrientationPortrait:
                ret = CGPointMake(origY, mirroredX);
            default:
                break;
        }
        break;
        case UIInterfaceOrientationPortrait:
        default: switch (to) {
            case UIInterfaceOrientationPortraitUpsideDown:
                ret = CGPointMake(mirroredX, mirroredY);
                break;
            case UIInterfaceOrientationLandscapeRight:
                ret = CGPointMake(origY, mirroredX);
                break;
            case UIInterfaceOrientationLandscapeLeft:
                ret = CGPointMake(mirroredY, origX);
                break;
            case UIInterfaceOrientationPortrait:
                // no change
                break;
            default:
                break;
        }
        break;
    }
    return ret;
}

static OnekoViewController *viewController;
static Oneko *neko;
static OnekoWindow *window;
static NSTimer *timer;

%hook UITouchesEvent

-(void)_setHIDEvent:(id)event {
    %orig;
    NSSet<UITouch *> *touches;
    if (@available(iOS 11.0, *)) {
        touches = [MSHookIvar<NSMutableSet *>(self, "_allTouchesMutable") copy];
    } else {
        touches = MSHookIvar<NSSet *>(self, "_touches");
    }
    if (touches.count == 0) {
        return;
    }
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:nil];
    if ([[touch window] interfaceOrientation] == UIInterfaceOrientationPortrait) {
        CGSize referenceBounds = [[UIScreen mainScreen] _referenceBounds].size;
        CGPoint mouseLocation = TranslatePoint(point, referenceBounds,
            UIInterfaceOrientationPortrait, [window interfaceOrientation]);
        neko.mouseLocation = mouseLocation;
    }
}

%end

static void onekoTimerTick() {
    SpringBoard *springboard = (SpringBoard *)[UIApplication sharedApplication];
    if ([springboard isLocked]) {
        neko.hidden = YES;
        return;
    }
    neko.hidden = NO;
    UIInterfaceOrientation orientation = [springboard statusBarOrientation];
    if ([window interfaceOrientation] != orientation) {
        CGSize vcSize = [viewController.view bounds].size;
        UIInterfaceOrientation from = [window interfaceOrientation];
        UIInterfaceOrientation to = orientation;
        CGRect frame = neko.frame;
        frame.origin.x += frame.size.width / 2;
        frame.origin.y += frame.size.height / 2;
        frame.origin = TranslatePoint(frame.origin, vcSize, from, to);
        frame.origin.y -= frame.size.height / 2;
        neko.mouseLocation = frame.origin;
        frame.origin.x -= frame.size.width / 2;
        neko.frame = frame;
        [window _rotateWindowToOrientation:orientation updateStatusBar:NO
            duration:0 skipCallbacks:NO];
    }
    [neko handleTimer:timer];
}

%hook SpringBoard

- (void)applicationDidFinishLaunching:(id)application {
    %orig;

    window = [[OnekoWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];
    if (@available(iOS 13.0, *)) {
        window.windowScene = (id)[self connectedScenes].allObjects[0];
    }
    else {
        window.screen = [UIScreen mainScreen];
    }

    viewController = [OnekoViewController new];

    neko = [Oneko new];
    neko.userInteractionEnabled = NO;
    [viewController.view addSubview:neko];
    
    window.rootViewController = viewController;
    window.userInteractionEnabled = YES;
    window.opaque = NO;
    window.hidden = NO;
    window.backgroundColor = [UIColor clearColor];
    window.windowLevel = CGFLOAT_MAX / 2.0;
    [window makeKeyAndVisible];

    timer = [NSTimer
        timerWithTimeInterval:0.125f
        repeats:YES
        block:^(NSTimer *timer) {
            onekoTimerTick();
        }
    ];
    [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
}

%end