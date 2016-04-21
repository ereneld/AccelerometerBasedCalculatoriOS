//
//  ProgramRootController.h
//  GestureDataWithRecognition
//
//  Created by dogukan ibrahimoglu on 3/16/11.
//  Copyright 2011 Bogazici University. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MainViewController.h"
#import "RootViewController.h"
#import "GestureTrainingViewController.h"
#import "ClassificationTestViewController.h"
#import "CalculatorMainViewController.h"
#import "ProgramDetailViewController.h"

@interface ProgramRootController : UIViewController {

	MainViewController* partAccelerometer;
	RootViewController* partDataCollection;
	GestureTrainingViewController* partTraining;
	ClassificationTestViewController* partTestClassification;
	CalculatorMainViewController* partCalculator;
	
	ProgramDetailViewController* partDetail;
	
	BOOL isDetailOpening;
}

-(IBAction)openAccelerometerUnderstand;
-(IBAction)openDataCollection;
-(IBAction)openGestureTraining;
-(IBAction)openTestClassification;
-(IBAction)openTestCalculator;

-(IBAction)openProgramDetail;

@end
