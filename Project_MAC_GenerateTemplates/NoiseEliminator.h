//
//  NoiseEliminator.h
//  GestureRecognition
//
//  Created by dogukan ibrahimoglu on 3/11/11.
//  Copyright 2011 Bogazici University. All rights reserved.
//


#import "DataSet.h"
#import "GestureData.h"
#import "Constants.h"
#import "ConfigurationManager.h"

@interface NoiseEliminator : NSObject {

}

+(void)eliminateNoiseFromDataSet:(DataSet*)currentDataSet;
+(void)eliminateNoiseFromGestureData:(GestureData*)currentGestureData;

//The data with average amplitute lower than given value (min limit) or greater than given value (max limit) will be eliminated
-(void)eliminateAverageAmplituteNoise:(NSArray*)gestureDataArray;

//The data will be eliminated if the length is lower than given value (min length) or higher than given value (max length)
-(void)eliminateSampleLengthNoise:(NSArray*)gestureDataArray;

@end
