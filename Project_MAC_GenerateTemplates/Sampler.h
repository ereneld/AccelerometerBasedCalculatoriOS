//
//  Sampler.h
//  GestureRecognition
//
//  Created by dogukan ibrahimoglu on 3/11/11.
//  Copyright 2011 Bogazici University. All rights reserved.
//


#import "DataSet.h"
#import "GestureData.h"
#import "Constants.h"
#import "ConfigurationManager.h"

@interface Sampler : NSObject {
	int sampleSize; // Number of sample in one sequence ! 
}

+(Sampler*) getSampler;
+(void) reset;
+(void)sampleDataSet:(DataSet*)currentDataSet;
+(void)sampleGestureData:(GestureData*)currentGestureData;

@end
