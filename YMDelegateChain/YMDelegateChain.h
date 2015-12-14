//
//  YMDelegateChain.h
//  Created by caoyangmin on 15/12/3.


#import <Foundation/Foundation.h>
/**
 * Delegate 链
 * 解决通常Delegate只能设置单个的问题
 * 消息将会顺着链路逐级调用，直到执行第一个已实现的方法
 */
@interface YMDelegateChain : NSObject

/**
 * 在Delegate链前端插入delegate
 */
+(nonnull YMDelegateChain*)insert:(nonnull id)newDelegate before:(nullable id)oriDelegate owner:(nullable id)owner;

/**
 * 删除已存在的delegate
 */
+(nullable id)remove:(nonnull id)delegate from:(nullable id)root owner:(nullable id)owner;
/**
 * 替换已存在的delegate
 */
+(nullable id)replace:(nonnull id)delegate with:(nonnull id)newDelegate from:(nullable id)root owner:(nullable id)owner;
/**
 * 设置continue标志，指定当前delegate方法返回后，继续调用下一个Delegate
 * 默认一旦命中一个Delegate，将停止调用下一个Delegate
 * (利用TLS实现，只在当前线程有效)
 */
+(void) continueChain:(BOOL)ctn;

/**
 * 判断continue标志是否被设置
 */
+(BOOL) willContinueChain;


@end

/**
 * 在Delegate链前端插入delegate
 * @param root 链表的根节点，可以为空
 * @param delegate_ 新插入的delegate
 * @param owner_ 因为delegate通常只保持weak引用，所以需要设置一个所有者，用于持有此方法内部创建的实例
 */
#define YMDelegateChainInsert(root_,delegate_, owner_)\
root_ = (__typeof(root_))[YMDelegateChain insert:delegate_ before:root_ owner:owner_];

/**
 * 删除已存在的delegate
 */
#define YMDelegateChainRemove(root_,delegate_, owner_)\
root_ = (__typeof(root_))[YMDelegateChain remove:delegate_ from:root_ owner:owner_];

/**
 * 设置continue标志，指定当前delegate方法返回后，继续调用下一个Delegate
 * 默认一旦命中一个Delegate，将停止调用下一个Delegate
 * (利用TLS实现，只在当前线程有效)
 */
#define YMDelegateChainContinue()\
[YMDelegateChain continueChain:YES];

/**
 * 替换已存在的delegate
 */
#define YMDelegateChainReplace(root_,src_,dest_, owner_)\
root_ = (__typeof(root_))[YMDelegateChain replace:src_ with:dest_ from:root_ owner:owner_];
