//
//  CellViewProbability.h
//  GestureDataWithRecognition
//
//  Created by dogukan ibrahimoglu on 4/12/11.
//  Copyright 2011 Bogazici University. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "GestureData.h"

@interface CellViewProbability : UITableViewCell {
    
    IBOutlet UILabel* labelClass;
    IBOutlet UILabel* labelModelProbability;
    IBOutlet UILabel* labelSequenceProbability;
    IBOutlet UILabel* labelResultProbability;
}

-(void)showGestureData:(GestureData*)gestureData andClass:(int)classIndex;

@end
