//
//  Use this file to import your target's public headers that you would like to expose to Swift.
//
#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import <UIKit/UIKit.h>

//Defining original method implementations
@interface UIViewController (AutoHook)
-(void)orig_viewDidLoad;
@end
