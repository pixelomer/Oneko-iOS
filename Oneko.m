#import "Oneko.h"
#import "resources.h"

@interface UIView(Private)
- (UIViewController *)_viewControllerForAncestor;
@end

@implementation Oneko {
    NSArray *stop, *jare, *kaki, *akubi, *sleep, *awake, *u_move, *d_move,
            *l_move, *r_move, *ul_move, *ur_move, *dl_move, *dr_move, *u_togi,
            *d_togi, *l_togi, *r_togi;
    
    id nekoState;
    unsigned char tickCount, stateCount;
    float moveDx, moveDy;
    id myTimer;
    UIImageView *view;
}

- (CGRect)cocoaFrame {
    CGRect frame = self.frame;
    frame.origin.y = [[UIScreen mainScreen] bounds].size.height - frame.origin.y;
    return frame;
}

- (CGPoint)cocoaMouseLocation {
    UIView *parent = [[self _viewControllerForAncestor] view];
    CGPoint point = _mouseLocation;
    point.y = parent.bounds.size.height - point.y;
    return point;
}

- (void)setCocoaFrame:(CGRect)frame {
    frame.origin.y = [[UIScreen mainScreen] bounds].size.height - frame.origin.y;
    self.frame = frame;
}

- (void)setStateTo:(id)theState
{
    if(nekoState == theState)
        return;
    //printf("state %d\n", theState);
    tickCount = 0;
    stateCount = 0;
    nekoState = theState;
    [self setNeedsDisplay];
}

+ (UIImage *)resourceNamed:(NSString *)name {
    static NSMutableDictionary<NSString *, UIImage *> *images;
    static NSDictionary<NSString *, NSData *> *bytes;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        images = [[NSMutableDictionary new] retain];
        bytes = [oneko_getResources() retain];
    });
    @synchronized ([Oneko class]) {
        if (images[name] != nil) {
            return images[name];
        }
        images[name] = [[[UIImage alloc] initWithData:bytes[name]] retain];
        return images[name];
    }
}

- (instancetype)init {
    self = [super initWithFrame:CGRectMake(100, 100, 32, 32)];
    self.mouseLocation = CGPointMake(116, 100);
    view = [[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 32, 32)] retain];
    view.contentMode = UIViewContentModeScaleAspectFit;
    [self addSubview:view];

    stop = [NSArray arrayWithObjects:
        [Oneko resourceNamed:@"mati2.gif"], nil];
    [stop retain];
    jare = [NSArray arrayWithObjects:
        [Oneko resourceNamed:@"jare2.gif"],
        [Oneko resourceNamed:@"mati2.gif"], nil];
    [jare retain];
    kaki = [NSArray arrayWithObjects:
        [Oneko resourceNamed:@"kaki1.gif"],
        [Oneko resourceNamed:@"kaki2.gif"], nil];
    [kaki retain];
    akubi = [NSArray arrayWithObjects:
        [Oneko resourceNamed:@"mati3.gif"], nil];
    [akubi retain];
    sleep = [NSArray arrayWithObjects:
        [Oneko resourceNamed:@"sleep1.gif"],
        [Oneko resourceNamed:@"sleep2.gif"], nil];
    [sleep retain];
    awake = [NSArray arrayWithObjects:
        [Oneko resourceNamed:@"awake.gif"], nil];
    [awake retain];
    u_move = [NSArray arrayWithObjects:
        [Oneko resourceNamed:@"up1.gif"],
        [Oneko resourceNamed:@"up2.gif"], nil];
    [u_move retain];
    d_move = [NSArray arrayWithObjects:
        [Oneko resourceNamed:@"down1.gif"],
        [Oneko resourceNamed:@"down2.gif"], nil];
    [d_move retain];
    l_move = [NSArray arrayWithObjects:
        [Oneko resourceNamed:@"left1.gif"],
        [Oneko resourceNamed:@"left2.gif"], nil];
    [l_move retain];
    r_move = [NSArray arrayWithObjects:
        [Oneko resourceNamed:@"right1.gif"],
        [Oneko resourceNamed:@"right2.gif"], nil];
    [r_move retain];
    ul_move = [NSArray arrayWithObjects:
        [Oneko resourceNamed:@"upleft1.gif"],
        [Oneko resourceNamed:@"upleft2.gif"], nil];
    [ul_move retain];
    ur_move = [NSArray arrayWithObjects:
        [Oneko resourceNamed:@"upright1.gif"],
        [Oneko resourceNamed:@"upright2.gif"], nil];
    [ur_move retain];
    dl_move = [NSArray arrayWithObjects:
        [Oneko resourceNamed:@"dwleft1.gif"],
        [Oneko resourceNamed:@"dwleft2.gif"], nil];
    [dl_move retain];
    dr_move = [NSArray arrayWithObjects:
        [Oneko resourceNamed:@"dwright1.gif"],
        [Oneko resourceNamed:@"dwright2.gif"], nil];
    [dr_move retain];
    u_togi = [NSArray arrayWithObjects:
        [Oneko resourceNamed:@"utogi1.gif"],
        [Oneko resourceNamed:@"utogi2.gif"], nil];
    [u_togi retain];
    d_togi = [NSArray arrayWithObjects:
        [Oneko resourceNamed:@"dtogi1.gif"],
        [Oneko resourceNamed:@"dtogi2.gif"], nil];
    [d_togi retain];
    l_togi = [NSArray arrayWithObjects:
        [Oneko resourceNamed:@"ltogi1.gif"],
        [Oneko resourceNamed:@"ltogi2.gif"], nil];
    [l_togi retain];
    r_togi = [NSArray arrayWithObjects:
        [Oneko resourceNamed:@"rtogi1.gif"],
        [Oneko resourceNamed:@"rtogi2.gif"], nil];
    [r_togi retain];
    
    [self setStateTo:stop];
    return self;
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    return NO;
}

- (void)calcDxDyForX:(float)x Y:(float)y
{
    float		MouseX, MouseY;
    float		DeltaX, DeltaY;
    float		Length;
    
    CGPoint p = [self cocoaMouseLocation];
    MouseX = p.x;
    MouseY = p.y;
    
    DeltaX = floor(MouseX - x - 16.0f);
    DeltaY = floor(MouseY - y);
    
    Length = hypotf(DeltaX, DeltaY);
    
    if (Length != 0.0f) {
        if (Length <= 13.0f) {
            moveDx = DeltaX;
            moveDy = DeltaY;
        } else {
            moveDx = (13.0f * DeltaX) / Length;
            moveDy = (13.0f * DeltaY) / Length;
        }
    } else {
        moveDx = moveDy = 0.0f;
    }
}

- (BOOL)isNekoMoveStart
{
    return moveDx > 6 || moveDx < -6 || moveDy > 6 || moveDy < -6;
}

- (void)advanceClock
{
    if (++tickCount >= 255) {
        tickCount = 0;
    }
    
    if (tickCount % 2 == 0) {
        if (stateCount < 255) {
            stateCount++;
        }
    }
}

- (void)NekoDirection
{
    id			NewState;
    double		LargeX, LargeY;
    double		Length;
    double		SinTheta;
    
    if (moveDx == 0.0f && moveDy == 0.0f) {
        NewState = stop;
    } else {
        LargeX = (double)moveDx;
        LargeY = (double)moveDy;
        Length = sqrt(LargeX * LargeX + LargeY * LargeY);
        SinTheta = LargeY / Length;
        //printf("SinTheta = %f\n", SinTheta);
        
        if (moveDx > 0) {
            if (SinTheta > 0.9239) {
                NewState = u_move;
            } else if (SinTheta > 0.3827) {
                NewState = ur_move;
            } else if (SinTheta > -0.3827) {
                NewState = r_move;
            } else if (SinTheta > -0.9239) {
                NewState = dr_move;
            } else {
                NewState = d_move;
            }
        } else {
            if (SinTheta > 0.9239) {
                NewState = u_move;
            } else if (SinTheta > 0.3827) {
                NewState = ul_move;
            } else if (SinTheta > -0.3827) {
                NewState = l_move;
            } else if (SinTheta > -0.9239) {
                NewState = dl_move;
            } else {
                NewState = d_move;
            }
        }
    }
    
    [self setStateTo:NewState];
}

- (void)handleTimer:(NSTimer*)timer
{
    float x = [self cocoaFrame].origin.x;
    float y = [self cocoaFrame].origin.y;
    //printf("paint %d %d\n", time(NULL), tickCount % [nekoState count]);
    
    [self calcDxDyForX:x Y:y];
    BOOL isNekoMoveStart = [self isNekoMoveStart];
    
    if(nekoState != sleep) {
        [view setImage:(UIImage *)[nekoState objectAtIndex:tickCount % [nekoState count]]];
    } else {
        [view setImage:(UIImage *)[nekoState objectAtIndex:(tickCount>>2) % [nekoState count]]];
    }
    
    [self advanceClock];
    
    if(nekoState == stop) {
        if (isNekoMoveStart) {
            [self setStateTo:awake];
            goto breakout;
        }
        if (stateCount < 4) {
            goto breakout;
        }
        /*if (moveDx < 0 && x <= 0) {
        [self setStateTo:l_togi];
        } else if (moveDx > 0 && x >= WindowWidth - 32) {
            [self setStateTo:r_togi];
        } else if (moveDy < 0 && y <= 0) {
            [self setStateTo:u_togi];
        } else if (moveDy > 0 && y >= WindowHeight - 32) {
            [self setStateTo:d_togi];
        } else {*/
        [self setStateTo:jare];
        //}
    } else if(nekoState == jare) {
        if (isNekoMoveStart) {
            [self setStateTo:awake];
            goto breakout;
        }
        if (stateCount < 10) {
            goto breakout;
        }
        [self setStateTo:kaki];
    } else if(nekoState == kaki) {
        if (isNekoMoveStart) {
            [self setStateTo:awake];
            goto breakout;
        }
        if (stateCount < 4) {
            goto breakout;
        }
        [self setStateTo:akubi];
    } else if(nekoState == akubi) {
        if (isNekoMoveStart) {
            [self setStateTo:awake];
            goto breakout;
        }
        if (stateCount < 6) {
            goto breakout;
        }
        [self setStateTo:sleep];
    } else if(nekoState == sleep) {
        if (isNekoMoveStart) {
            [self setStateTo:awake];
            goto breakout;
        }
    } else if(nekoState == awake) {
        if (stateCount < 3) {
            goto breakout;
        }
        [self NekoDirection];	/* 猫が動く向きを求める */
    } else if(nekoState == u_move || nekoState == d_move || nekoState == l_move || nekoState == r_move || nekoState == ul_move || nekoState == ur_move || nekoState == dl_move || nekoState == dr_move) {
        x += moveDx;
        y += moveDy;
        [self NekoDirection];
    } else if(nekoState == u_togi || nekoState == d_togi || nekoState == l_togi || nekoState == r_togi) {
        if (isNekoMoveStart) {
            [self setStateTo:awake];
            goto breakout;
        }
        if (stateCount < 10) {
            goto breakout;
        }
        [self setStateTo:kaki];
    } else {
        /* Internal Error */
        [self setStateTo:stop];
    }

    breakout:
    [self setNeedsDisplay];
    CGRect frame = self.cocoaFrame;
    frame.origin = CGPointMake(x, y);
    self.cocoaFrame = frame;
}
@end
