import Foundation

@objc public class AutoHookImplementor: NSObject{
    static func implementHooks(hookClass: AnyClass, targetClass: AnyClass){
        var methodCount: UInt32 = 0
        let methods = class_copyMethodList(hookClass, &methodCount)
        for hookMethod in (0..<Int(methodCount)).map({methods![$0]}){
            let hookMethodSelector = method_getName(hookMethod)
            let hookPrefix = "hook_"
            let hookMethodName = NSStringFromSelector(hookMethodSelector)
            if hookMethodName.hasPrefix(hookPrefix){
                let targetMethodName = hookMethodName.dropFirst(hookPrefix.count)
                let targetMethodSelector = NSSelectorFromString(String(targetMethodName))
                let targetMethod = class_getInstanceMethod(targetClass, targetMethodSelector)
                let targetTypeEncoding = method_getTypeEncoding(targetMethod!)
                let originalStorePrefix = "orig_"
                let hookImp = method_getImplementation(hookMethod)
                let originalStoreMethodName:String = String(format:"%@%@", originalStorePrefix, String(targetMethodName))
                let originalStoreSelector = NSSelectorFromString(originalStoreMethodName)
                let targetImp = method_getImplementation(targetMethod!)
                class_addMethod(targetClass, originalStoreSelector, targetImp, targetTypeEncoding)
                class_replaceMethod(targetClass, targetMethodSelector, hookImp, targetTypeEncoding)
            }
            else {
                let addMethod = class_getInstanceMethod(hookClass, hookMethodSelector)!
                class_addMethod(targetClass, hookMethodSelector, method_getImplementation(addMethod), method_getTypeEncoding(addMethod))
            }
        }
    }
    static func implementHooks(hookClass: AnyClass){
        let className = NSStringFromClass(hookClass)
        let classStrs = className.split(separator:".")
        let prefix = String(format:"%@.Hook", String(classStrs[0]))
        let targetClassStr = String(className.dropFirst(prefix.count))
        let targetClass = objc_getClass(targetClassStr)
        AutoHookImplementor.implementHooks(hookClass:hookClass, targetClass:targetClass as! AnyClass)
    }
    @objc public static func swiftInit(){
        //Call this in your constructor
        var classCount: UInt32 = 0
        let classes = objc_copyClassList(&classCount)
        for hookClass in Array(UnsafeBufferPointer(start: classes, count: Int(classCount))){
            let hookClassStr = NSStringFromClass(hookClass)
            let classStrs = hookClassStr.split(separator:".")
            if classStrs.count > 1 && classStrs[1].hasPrefix("Hook"){
                AutoHookImplementor.implementHooks(hookClass:hookClass)
            }
        }
    }
}
