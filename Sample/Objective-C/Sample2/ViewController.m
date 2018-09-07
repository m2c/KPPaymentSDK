//
//  ViewController.m
//  Sample2
//
//  Created by Zaid M. Said on 31/08/2018.
//  Copyright © 2018 Kiple Sdn Bhd. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

@synthesize payment;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    payment = [[KPPayment alloc] initWithMerchantId:123
                                             secret:@"abc123"
                                       isProduction:NO];
    payment.delegate = self;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)paymentDidFinishSuccessfully:(BOOL)flag withMessage:(NSString *)message andPayload:(NSDictionary<NSString *,NSString *> *)payload {
    if (flag) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Sample App" message:@"Payment is successful" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil];
        [alert addAction:action];
        [self presentViewController:alert animated:YES completion:nil];
    } else {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Sample App" message:@"Payment is NOT successful" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil];
        [alert addAction:action];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

- (IBAction)payButtonTapped:(id)sender {
    [payment makePaymentForStoreId:123
                   withReferenceId:@"abc123"
                         andAmount:12.34];
}

@end
