import Foundation
import UIKit

//Classes and methods must be marked with @objc. You cannot hook a method in a class *and* its superclass.
@objc class HookUIViewController : UIViewController{
    //Hook existing instance / class method. To call original implementation, define objc orig_ methods in your bridging header
    @objc func hook_viewDidLoad(){
        self.orig_viewDidLoad()
        self.view.tag = 69
    }
    //Add new instance method
    @objc func hook() -> String{
        return "Hook"
    }
    //Add new class method.
    @objc func class_classHook() -> String{
        return "Class Hook"
    }
}

//Hook unmangled Swift class, "_" is replaced with "." later.
@objc class HookSwiftMusicApplication_NowPlayingViewController : UIViewController{
    //Rehooking viewDidLoad after already hooking earlier, don't do this. ^
    /*@objc func hook_viewDidLoad(){
        self.orig_viewDidLoad()
    }*/
    @objc func swiftHook() -> String{
        return "Swift Hook"
    }
    @objc func class_swiftClassHook() -> String{
        return "Swift Class Hook"
    }
}
