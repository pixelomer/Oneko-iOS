#import <UIKit/UIKit.h>

@interface Oneko : UIView
@property (nonatomic, assign) CGPoint mouseLocation;
- (void)handleTimer:(NSTimer*)timer;
@end