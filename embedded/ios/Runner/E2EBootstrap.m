// E2EBootstrap.m
//
// Sets the `frontegg-testing` environment variable BEFORE main() runs, via
// Objective-C +load.  This is required because FronteggSwift's
// FronteggRuntime.isTesting reads ProcessInfo.processInfo.environment, which
// captures the environment when the process starts; setenv() called from
// AppDelegate's didFinishLaunchingWithOptions runs too late and is not visible
// to ProcessInfo on iOS.
//
// +load is called by the Objective-C runtime when the class is loaded into
// memory, before any Swift code (including @main AppDelegate) runs.
//
// Only active in DEBUG builds — production app must never advertise itself
// as a test build.

#import <Foundation/Foundation.h>
#import <stdlib.h>

@interface FronteggE2EBootstrap : NSObject
@end

@implementation FronteggE2EBootstrap

+ (void)load {
#if DEBUG
    setenv("frontegg-testing", "true", 1);
    NSLog(@"[E2E] +load: frontegg-testing env set");
#endif
}

@end
