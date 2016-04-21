//
//  LeaveOneOut.h
//  GestureRecognition
//
//  Created by dogukan ibrahimoglu on 1/26/11.
//  Copyright 2011 Bogazici University. All rights reserved.
//


#import "CrossValidator.h"

@interface LeaveOneOut : CrossValidator {

}


-(id)initWithKNumber:(int)numberOfDataValue;
-(void)makeTrainingAndValidationSet:(NSArray*)gestureDataArray; //should be defined in each cross validation algorithm

@end
