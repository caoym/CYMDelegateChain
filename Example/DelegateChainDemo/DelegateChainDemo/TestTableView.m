//
//  TestTableView.m
//  DelegateChainDemo
//
//  Created by caoyangmin on 15/12/14.

#import <objc/runtime.h>
#import "TestTableView.h"
#import "CYMDelegateChain.h"


/** 
 * TestTableViewData
 * 只实现numberOfSectionsInTableView
 */
@implementation TestTableViewData

-(instancetype) init
{
    self = [super init];
    if(self){
        _sections = [[NSMutableArray alloc]init];
    }
    return self;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return _sections.count;
}
@end


/**
 * TestTableViewSectionData
 * 只处理section的数据
 */
@implementation TestTableViewSectionData
    

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (_sectionId == indexPath.section) { //只处理本section的消息
        static NSString *cellId = @"cellId";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault  reuseIdentifier: cellId];
        }
        cell.textLabel.text = [NSString stringWithFormat:@"section %ld | row %ld",(long)indexPath.section, (long)indexPath.row];
        return cell;
    }else{
        //非本section的消息，交给其他delegate处理
        CYMDelegateChainContinue();
        return nil;
    }

}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (_sectionId == section) { //只处理本section的消息
        return 3;
    }else{
        //非本section的消息，交给其他delegate处理
        CYMDelegateChainContinue();
        return 0;
    }
}

@end

/**
 * UITableView
 */
@implementation UITableView(TestSection)

/** 添加section，返回sectionid */
-(NSInteger) addTestSection:(TestTableViewSectionData*) section{
    
    TestTableViewData*data = objc_getAssociatedObject(self, @"__testdata");
    NSInteger sectionId = 0;
    if(!data){
        data = [[TestTableViewData alloc]init];
        objc_setAssociatedObject(self, @"__testdata", data, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        //在链中插入新section,只处理numberOfSectionsInTableView
        CYMDelegateChainInsert(self.dataSource, data, self);
    }
    sectionId = data.sections.count;
    
    
    section.sectionId = sectionId;
    //在链中插入新section,每个section只处理自己的事件
    CYMDelegateChainInsert(self.dataSource, section, self);
    
    [data.sections addObject:section];
    return sectionId;
}
@end
