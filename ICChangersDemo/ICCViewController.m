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
@property (nonatomic, weak) IBOutlet UIView *contentView;
@property (nonatomic, weak) IBOutlet UIScrollView *scrollView;

@property (nonatomic, weak) IBOutlet UILabel *pastDaysFootprintLabel;
@property (nonatomic, weak) IBOutlet UILabel *mainFootprintLabel;
@property (nonatomic, weak) IBOutlet UILabel *kilometerLabel;
@property (nonatomic, weak) IBOutlet UILabel *emissionLabel;

@property (nonatomic, strong) NSDate *startDate;

@property (nonatomic, weak) IBOutlet UIImageView *arrowView;
@property (nonatomic, weak) IBOutlet UIImageView *redRotatingBallView;
@property (nonatomic, weak) IBOutlet UIImageView *redRotatingPointerView;
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
    _startDate = [NSDate date];
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
    NSURL *url = [NSURL URLWithString:string];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.responseSerializer = [AFJSONResponseSerializer serializer];
    
    __weak __typeof(self)weakSelf = self;
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"%@", responseObject);
        if ([responseObject[@"status"] intValue] != 0) {
            [weakSelf shownUnknownErrorAlert];
            return;
        }
        if (![responseObject[@"result"] respondsToSelector:@selector(allKeys)]) {
            [weakSelf shownUnknownErrorAlert];
            return;
        }
        NSTimeInterval timeInterval = [[NSDate date] timeIntervalSinceDate:weakSelf.startDate];
        if(timeInterval >= 3.0) {
            [weakSelf processResponseDictionary:responseObject[@"result"]];
        } else {
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (3.0 - timeInterval) * NSEC_PER_SEC);
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                [weakSelf processResponseDictionary:responseObject[@"result"]];
            });
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
    double currentFootprint = [responseDict[kMainFootPrintKey] doubleValue];
    double lastMonthFootprint = [responseDict[kLastMonthFootPrintKey] doubleValue];
    double lastYearFootprint = [responseDict[kLastYearFootprintKey] doubleValue];
    
    _mainFootprintLabel.text = [NSString stringWithFormat:@"%.2f", currentFootprint];
    _emissionLabel.text = responseDict[kCO2EmissionKey];
    
    [self drawArrowWithDelta:(currentFootprint - lastMonthFootprint)];
    [self rotateView:_redRotatingPointerView withFootprintValue:currentFootprint];
    [self rotateView:_redRotatingBallView withFootprintValue:lastYearFootprint];
    
    //IT WAS NOT MENTIONED - WHERE TO GET THIS DATA, SO I USED SOME RANDOM VALUES
    _pastDaysFootprintLabel.text = @"FOR THE LAST MONTH";
    _kilometerLabel.text = responseDict[@"co2avoidedTotal"];
}

- (void)rotateView:(UIView *)viewToRotate withFootprintValue:(double)footstepValue {
    if (footstepValue >= 9.5) {
        [self bumpView:viewToRotate];
        return;
    }
    if (footstepValue > 0) {
        [UIView animateWithDuration:0.5f
                         animations:^{
                             viewToRotate.layer.affineTransform = CGAffineTransformMakeRotation(M_PI - M_PI*footstepValue/10);}];
        return;
    }
    if (footstepValue == 0) {
        [UIView animateWithDuration:0.5f
                         animations:^{
                             viewToRotate.layer.affineTransform = CGAffineTransformMakeRotation(M_PI - 0.01);}];
        return;
    }
    [UIView animateWithDuration:0.3
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         viewToRotate.layer.affineTransform = CGAffineTransformMakeRotation(M_PI - 0.01);
                     }
                     completion:^(BOOL finished) {
                         [UIView animateWithDuration:0.3
                                               delay:0.0
                                             options:UIViewAnimationOptionCurveEaseOut
                                          animations:^{
                                              viewToRotate.layer.affineTransform = CGAffineTransformMakeRotation(M_PI - M_PI*footstepValue/10);
                                          }
                                          completion:^(BOOL finished) {
                                            
                                          }
                          ];
                     }
     ];
}

- (void)bumpView:(UIView *)viewToRotate {
    [UIView animateWithDuration:0.3
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         viewToRotate.layer.affineTransform = CGAffineTransformMakeRotation(M_PI*0.2);
                     }
                     completion:^(BOOL finished) {
                         [UIView animateWithDuration:0.3
                                               delay:0.0
                                             options:UIViewAnimationOptionCurveEaseInOut
                                          animations:^{
                                              viewToRotate.layer.affineTransform = CGAffineTransformMakeRotation(0);
                                          }
                                          completion:^(BOOL finished) {
                                              
                                          }
                          ];
                     }
     ];
}

- (void)drawArrowWithDelta:(int)delta {
    if (delta >=0) {
        _arrowView.image = [UIImage imageNamed:@"ARROW_GREEN_45X56"];
    } else {
        _arrowView.image = [UIImage imageNamed:@"ARROW_RED_45X56"];
    }
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
