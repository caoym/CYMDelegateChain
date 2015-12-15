//
//  TestTableView.h
//  DelegateChainDemo
//
//  Created by caoyangmin on 15/12/14.
//

#import <UIKit/UIKit.h>


/** TestTableViewData */
@interface TestTableViewData : NSObject<UITableViewDataSource>

@property NSMutableArray* sections;

@end

/** TestTableViewSectionData */
@interface TestTableViewSectionData : NSObject<UITableViewDataSource>
@property NSInteger sectionId;
@end


/** UITableView+TestSection */
@interface UITableView(TestSection)

/** 添加section，返回sectionid */
-(NSInteger) addTestSection:(TestTableViewSectionData*)section;

@end