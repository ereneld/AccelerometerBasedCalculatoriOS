//
//  KFoldValidator.h
//  GestureRecognition
//
//  Created by dogukan ibrahimoglu on 1/26/11.
//  Copyright 2011 Bogazici University. All rights reserved.
//


#import "CrossValidator.h"

@interface KFoldValidator : CrossValidator {

}

-(id)initWithKNumber:(int)kFoldNumberValue andNumberOfData:(int)numberOfDataValue;
-(void)makeTrainingAndValidationSet:(NSArray*)gestureDataArray; //should be defined in each cross validation algorithm

-(void)setupTrainingAndValidationFoldSet; // it is used for setup the fold index values for each data array

@end
