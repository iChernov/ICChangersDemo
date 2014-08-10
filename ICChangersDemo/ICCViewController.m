//
//  ICCViewController.m
//  ICChangersDemo
//
//  Created by Ivan Chernov on 10/08/14.
//  Copyright (c) 2014 iChernov. All rights reserved.
//

#import "ICCViewController.h"

@interface ICCViewController ()
@property IBOutlet UIView *contentView;
@property IBOutlet UIScrollView *scrollView;

@property IBOutlet UILabel *pastDaysFootprintLabel;
@property IBOutlet UILabel *mainFootprintLabel;
@property IBOutlet UILabel *kilometerLabel;
@property IBOutlet UILabel *emissionLabel;

@property IBOutlet UIView *arrowView;
@property IBOutlet UIView *redRotatingBallView;
@property IBOutlet UIView *redRotatingPointerView;

@end

@implementation ICCViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor whiteColor]};
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.topItem.title = @"";

	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [_scrollView layoutIfNeeded];
    _scrollView.contentSize = _contentView.bounds.size;
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    _scrollView.frame = CGRectMake(-20, 37, 340, CGRectGetHeight(screenRect) - (37+65));
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
