//
//  ViewController.m
//  DelegateChainDemo
//
//  Created by caoyangmin on 15/12/14.
//

#import "ViewController.h"
#import "TestTableView.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //测试section
    TestTableViewSectionData* sec0 = [[TestTableViewSectionData alloc]init];
    TestTableViewSectionData* sec1 = [[TestTableViewSectionData alloc]init];
    TestTableViewSectionData* sec2 = [[TestTableViewSectionData alloc]init];
    [_tabView addTestSection:sec0];
    [_tabView addTestSection:sec1];
    [_tabView addTestSection:sec2];
}

@end
