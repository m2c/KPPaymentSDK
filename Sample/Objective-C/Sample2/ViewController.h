//
//  ViewController.h
//  Sample2
//
//  Created by Zaid M. Said on 01/04/2018.
//  Copyright © 2018 Kiple Sdn Bhd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <KPPaymentSDK/KPPaymentSDK-Swift.h>

@interface ViewController : UIViewController <KPPaymentDelegate>

@property (strong, nonatomic) KPPayment *payment;


@end

