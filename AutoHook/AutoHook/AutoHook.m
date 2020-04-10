#import <Foundation/Foundation.h>
#import "AutoHook-Swift.h"

//Initialize AutoHook
static void __attribute__ ((constructor)) ctor(){
    [AutoHookImplementor swiftInit];
}
