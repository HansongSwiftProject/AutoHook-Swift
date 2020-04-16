import Foundation

public class AutoHookImplementor: NSObject{
    static func implementHooks(hookClass: AnyClass, targetClass: AnyClass){
        var methodCount: UInt32 = 0
        let methods = class_copyMethodList(hookClass, &methodCount)
        for hookMethod in (0..<Int(methodCount)).map({methods![$0]}){
            var hookMethodSelector = method_getName(hookMethod)
            let hookPrefix = "hook_"
            let originalStorePrefix = "orig_"
            let classPrefix = "class_"
            let hookMethodName = NSStringFromSelector(hookMethodSelector)
            if !hookMethodName.hasPrefix(originalStorePrefix) && !hookMethodName.hasPrefix(hookPrefix){
                var addClass: AnyClass = targetClass
                let addMethod = class_getInstanceMethod(hookClass, hookMethodSelector)!
                if hookMethodName.hasPrefix(classPrefix){
                    addClass = objc_getMetaClass(NSStringFromClass(targetClass)) as! AnyClass
                    hookMethodSelector = NSSelectorFromString(String(hookMethodName.dropFirst(classPrefix.count)))
                }
                class_addMethod(addClass, hookMethodSelector, method_getImplementation(addMethod), method_getTypeEncoding(addMethod))
            }
            else if hookMethodName.hasPrefix(hookPrefix){
                let targetMethodName = hookMethodName.dropFirst(hookPrefix.count)
                let targetMethodSelector = NSSelectorFromString(String(targetMethodName))
                var targetMethod = class_getInstanceMethod(targetClass, targetMethodSelector)
                var targetMetaClass: Bool = false
                if (targetMethod == nil){
                    targetMetaClass = true
                    targetMethod = class_getClassMethod(targetClass, targetMethodSelector)
                }
                let targetTypeEncoding = method_getTypeEncoding(targetMethod!)
                let hookedTypeEncoding = method_getTypeEncoding(hookMethod)
                if String(cString:targetTypeEncoding!) != String(cString:hookedTypeEncoding!){
                    return
                }
                let hookImp = method_getImplementation(hookMethod)
                let originalStoreMethodName:String = String(format:"%@%@", originalStorePrefix, String(targetMethodName))
                let originalStoreSelector = NSSelectorFromString(originalStoreMethodName)
                let targetImp = method_getImplementation(targetMethod!)
                var addMethodClass: AnyClass = targetClass
                if targetMetaClass{
                    addMethodClass = objc_getMetaClass(class_getName(targetClass)) as! AnyClass
                }
                class_addMethod(addMethodClass, originalStoreSelector, targetImp, targetTypeEncoding)
                class_replaceMethod(targetClass, targetMethodSelector, hookImp, targetTypeEncoding)
            }
        }
    }
    static func implementHooks(hookClass: AnyClass){
        let className = NSStringFromClass(hookClass)
        var metaClass: AnyClass = hookClass
        if(class_isMetaClass(metaClass) == true){
            let potentialMetaClass = objc_getMetaClass(className)
            if ((potentialMetaClass) != nil){
                metaClass = potentialMetaClass as! AnyClass
            }
        }
        let classStrs = className.split(separator:".")
        let prefix = String(format:"%@.Hook", String(classStrs[0]))
        var targetClassStr = String(className.dropFirst(prefix.count))
        if targetClassStr.hasPrefix("Swift"){
            targetClassStr = String(targetClassStr.dropFirst(5)).replacingOccurrences(of:"_", with:".")
        }
        let targetClass = objc_getClass(targetClassStr)
        NSLog("AutoHook target: %@", targetClassStr)
        AutoHookImplementor.implementHooks(hookClass:hookClass, targetClass:targetClass as! AnyClass)
    }
    @objc static func swiftInit(){
        //Call this in your constructor
        var classCount: UInt32 = 0
        let classes = objc_copyClassList(&classCount)
        if (classes == nil){
            return
        }
        for hookClass in (0..<Int(classCount)).map({classes![$0]}){
            let hookClassStr = NSStringFromClass(hookClass)
            let classStrs = hookClassStr.split(separator:".")
            if classStrs.count > 1 && classStrs[1].hasPrefix("Hook"){
                AutoHookImplementor.implementHooks(hookClass:hookClass)
            }
        }
    }
}
