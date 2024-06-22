#if DEBUG
#define NSLog(args...) NSLog(@"[Oneko] " args)
#else
#define NSLog(...)
#endif