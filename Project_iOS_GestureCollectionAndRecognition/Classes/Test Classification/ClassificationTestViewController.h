//
//  ClassificationTestViewController.h
//  GestureDataWithRecognition
//
//  Created by dogukan ibrahimoglu on 3/17/11.
//  Copyright 2011 Bogazici University. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GestureData.h"

/*
#import <GestureRecognition/ConfigurationManager.h>
#import <GestureRecognition/Constants.h>
#import <GestureRecognition/DataSet.h>
#import <GestureRecognition/GestureData.h>
#import <GestureRecognition/Filter.h>
#import <GestureRecognition/DimensionalReductor.h>
#import <GestureRecognition/Cluster.h>
#import <GestureRecognition/Sampler.h>
#import <GestureRecognition/Preprocessor.h>
#import <GestureRecognition/NoiseEliminator.h>
#import <GestureRecognition/CrossValidator.h>
#import <GestureRecognition/Classifier.h>
*/
@class ClassificationTestDetail;

@interface ClassificationTestViewController : UIViewController <UIAccelerometerDelegate>{

    ClassificationTestDetail* detailViewController;
    
    IBOutlet UILabel* labelQuestionMark;
    IBOutlet UIImageView* imageClassificationResult;
    
    IBOutlet UIButton* buttonShowData;
    IBOutlet UIButton* buttonShowProbability;
    
    BOOL isStopped;
    GestureData* currentGestureData;
    NSTimeInterval startingTimeInterval;
    
}

-(IBAction) startRecordGestureData:(id)sender;
-(IBAction) stopRecordGestureData:(id)sender;

-(void)showClassificationResult;


-(IBAction)showDataView;
-(IBAction)showProbabityView;

@end
