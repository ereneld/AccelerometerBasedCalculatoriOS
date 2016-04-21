//
//  CalculatorMainViewController.h
//  GestureDataWithRecognition
//
//  Created by dogukan ibrahimoglu on 3/17/11.
//  Copyright 2011 Bogazici University. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CalculatorDetailViewController.h"
#import "GestureData.h"

#import "Calculator.h"

@interface CalculatorMainViewController : UIViewController <UIAccelerometerDelegate>{

	CalculatorDetailViewController* detailViewController;
    Calculator* calculator;
    
    IBOutlet UILabel* labelCalculator;
    IBOutlet UILabel* labelLastGesture;
    IBOutlet UILabel* labelLastRealGestureNo;
    IBOutlet UIImageView* imageRealGesture;
    
    BOOL isStopped;
    GestureData* currentGestureData;
    NSTimeInterval startingTimeInterval;
}

-(IBAction)showDetail;

-(void)addCalculatorString:(int)classifiedClass;
-(void)updateCalculatorText;

-(IBAction) startRecordGestureData:(id)sender;
-(IBAction) stopRecordGestureData:(id)sender;

@end
