//
//  ViewController.m
//  MXURLConnectionDemo
//
//  Created by eric on 15/8/6.
//  Copyright (c) 2015年 Eric Lung. All rights reserved.
//

#import "ViewController.h"
#import "MXURLConnection.h"

@interface ViewController ()

@property (nonatomic, strong) MXURLConnection *cnnt;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.view.backgroundColor = [UIColor lightGrayColor];
}

- (IBAction)pushViewCotroller
{
    ViewController *vc = [ViewController new];
    [vc testDownload];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)testDownload
{
//    NSURL *url = [NSURL URLWithString:@"http://www.rzds.net/data/excel/20140807/1407402423600552.pdf"];
    NSURL *url = [NSURL URLWithString:@"http://www.baidu.com"];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    MXURLConnection *cnnt = [[MXURLConnection alloc] initWithRequest:request];
    [cnnt start];
    self.cnnt = cnnt;
    [cnnt setDownloadingBlock:^(MXURLConnection *connection, long long currentBytes, long long totalBytes, NSError *error) {
        NSLog(@"%lld, %lld, %f", currentBytes, totalBytes, (float)currentBytes/(float)totalBytes);
    }];
    [cnnt setResponseBlock:^(MXURLConnection *connection, NSData *responseData, NSError *error) {
        if (!error) {
            NSString *string = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
            NSLog(@"%@", string);
        }
        else {
            NSLog(@"%@", error.localizedFailureReason);
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [self.cnnt cancel];
    NSLog(@"%@ dealloc",NSStringFromClass([self class]));
}

@end
