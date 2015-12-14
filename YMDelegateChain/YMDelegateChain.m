//
//  YMDelegateChain.m
//  Created by caoyangmin on 15/12/3.


#import "YMDelegateChain.h"
#import "objc/runtime.h"


@implementation YMDelegateChain
{
    __weak id _first;
    __weak id _second;
}

+(nonnull YMDelegateChain*)insert:(nonnull id)newDelegate before:(nullable id)oriDelegate owner:(nullable id)owner
{

    YMDelegateChain* chain = [[YMDelegateChain alloc]initWithInsert:newDelegate before:oriDelegate];

    //通常delegate都是weak熟悉，下面方法是为了持有delegate，避免使用时再去定义一个类变量
    if(owner){
        [YMDelegateChain add:chain toOwner:owner];
    }
    return chain;
}
+(nullable id)remove:(nonnull id)delegate from:(nullable id)root owner:(nullable id)owner
{
    if ([root isKindOfClass:[YMDelegateChain class]]) {
        //Delegate,需要逐个遍历删除
        YMDelegateChain*pos = root;
        
        if (pos->_first == delegate) { //找到
            [YMDelegateChain remove:delegate fromOwner:owner];
            return pos->_second;
        }else{
            pos->_second = [YMDelegateChain remove:delegate from:pos->_second owner:owner];
            return pos;
        }
        
    }else if(root == delegate){
        [YMDelegateChain remove:delegate fromOwner:owner];
        return nil;
    }
    return root;
}

+(id)replace:(id)delegate with:(id)newDelegate from:(id)root owner:(id)owner
{
    if ([root isKindOfClass:[YMDelegateChain class]]) {
        //需要逐个遍历查找
        YMDelegateChain*pos = root;
        
        if (pos->_first == delegate) { //找到
            [YMDelegateChain remove:delegate fromOwner:owner];
            return [YMDelegateChain insert:newDelegate before:pos owner:owner];
            
        }else{
            return [YMDelegateChain replace:delegate with:newDelegate from:pos->_second owner:owner];
        }
        
    }else if(root == delegate){
        return newDelegate;
    }
    return root;
}
+(void)remove:(id)delegate fromOwner:(id)owner
{
    if (owner) {
        NSMutableArray*chains = objc_getAssociatedObject(owner, @"__delegate_chains");
        for(YMDelegateChain* chain in chains) {
            if (chain->_first == delegate) {
                [chains removeObject:chain];
                break;
            }
        }
    }
}
+(void)add:(YMDelegateChain*)chain toOwner:(id)owner
{
    NSMutableArray*chains = objc_getAssociatedObject(owner, @"__delegate_chains");
    if (!chains) {
        chains = [[NSMutableArray alloc]init];
        objc_setAssociatedObject(owner,@"__delegate_chains",chains,OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        
        chains = objc_getAssociatedObject(owner,@"__delegate_chains");
    }
    [chains addObject:chain];
}
/**
 * 继续调用下一个Delegate
 * 默认一旦命中一个Delegate，将停止调用下一个Delegate
 */
+(void) continueChain:(BOOL)ctn{
    [[NSThread currentThread]threadDictionary][@"__delegate_chains_break"] = [NSNumber numberWithBool:ctn] ;
}

+(BOOL) willContinueChain{
    NSNumber* c = [[NSThread currentThread]threadDictionary][@"__delegate_chains_break"];
    if (c && [c boolValue]) {
        return YES;
    }
    return NO;
}

- (id)initWithInsert:new before:ori
{
    if (self = [super init]){
        _first = new;
        _second = ori;
        if(_first){
            objc_setAssociatedObject(_first,@"__delegate_chains_break",[NSNumber numberWithBool:YES],OBJC_ASSOCIATION_COPY_NONATOMIC);
        }
        if(_second){
            objc_setAssociatedObject(_second,@"__delegate_chains_break",[NSNumber numberWithBool:YES],OBJC_ASSOCIATION_COPY_NONATOMIC);
        }
    }
    return self;
}


- (BOOL)respondsToSelector:(SEL)aSelector
{
    if ([super respondsToSelector:aSelector]){
        return YES;
    }
    
    if (_first && [_first respondsToSelector:aSelector]){
        return YES;
    }
    
    if (_second && [_second respondsToSelector:aSelector]){
        return YES;
    }
    
    return NO;
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector
{
    NSMethodSignature* signature = [super methodSignatureForSelector:aSelector];
    
    if (!signature){
        if (_first && [_first respondsToSelector:aSelector]){
            return [_first methodSignatureForSelector:aSelector];
        }
        if (_second && [_second respondsToSelector:aSelector]){
            return [_second methodSignatureForSelector:aSelector];
        }
    }
    return signature;
}

- (void)forwardInvocation:(NSInvocation *)anInvocation
{
    if ([super respondsToSelector:[anInvocation selector]] ){
        [super forwardInvocation:anInvocation];
        return;
    }
    if (_first && [_first respondsToSelector:[anInvocation selector]]){
        [YMDelegateChain continueChain:NO];
        [anInvocation invokeWithTarget:_first];
        
        if (![YMDelegateChain willContinueChain]) { //是否调用下一个可能存在的delegate
            return;
        }
        
    }
    if (_second && [_second respondsToSelector:[anInvocation selector]]){
        [YMDelegateChain continueChain:NO];
        [anInvocation invokeWithTarget:_second];
        return;
    }
    //
}
@end
