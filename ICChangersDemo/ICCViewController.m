//
//  ICCViewController.m
//  ICChangersDemo
//
//  Created by Ivan Chernov on 10/08/14.
//  Copyright (c) 2014 iChernov. All rights reserved.
//

#import "ICCViewController.h"
#import "AFNetworking.h"

static NSString * const BaseURLString = @"http://comm.new.changers.com/services/api/rest/json/";

static NSString * const kCO2EmissionKey = @"co2avoidedTotal";
static NSString * const kMainFootPrintKey = @"indexCurrent";
static NSString * const kLastMonthFootPrintKey = @"indexPrevMonth";
static NSString * const kLastYearFootprintKey = @"indexPrevYear";


@interface ICCViewController ()
@property IBOutlet UIView *contentView;
@property IBOutlet UIScrollView *scrollView;

@property IBOutlet UILabel *pastDaysFootprintLabel;
@property IBOutlet UILabel *mainFootprintLabel;
@property IBOutlet UILabel *kilometerLabel;
@property IBOutlet UILabel *emissionLabel;

@property IBOutlet UIImageView *arrowView;
@property IBOutlet UIImageView *redRotatingBallView;
@property IBOutlet UIImageView *redRotatingPointerView;
@end

@implementation ICCViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor whiteColor]};
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.topItem.title = @"";
    [self setInitialValues];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)setInitialValues {
    _arrowView.image = nil;
    _pastDaysFootprintLabel.text = @"LOADING FOOTPRINT...";
    _mainFootprintLabel.text = @"--";
    _kilometerLabel.text = @"--";
    _emissionLabel.text = @"--";

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self loadData];
}

- (void)loadData {
    NSString *methodParameterString = @"method=statistics.user";
    NSString *apiKeyParameterString = @"api_key=87718188734753b091a72b68571c2a478a8d6961";
    NSString *usernameParameterString = @"username=chardaker";
    NSString *string = [NSString stringWithFormat:@"%@?%@&%@&%@",
                        BaseURLString,
                        methodParameterString,
                        apiKeyParameterString,
                        usernameParameterString];
    NSLog(@"%@", string);

    NSURL *url = [NSURL URLWithString:string];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.responseSerializer = [AFJSONResponseSerializer serializer];
    
    __weak __typeof(self)weakSelf = self;
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([responseObject[@"status"] intValue] != 0) {
            [weakSelf shownUnknownErrorAlert];
        } else {
            [weakSelf processResponseDictionary:responseObject[@"result"]];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Connection error"
                                                            message:[error localizedDescription]
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
        [alertView show];
    }];
    [operation start];
}

- (void)processResponseDictionary:(NSDictionary *)responseDict {

}


- (void)shownUnknownErrorAlert {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Unknown error"
                                                        message:@"Please, try again later"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
    [alertView show];
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
