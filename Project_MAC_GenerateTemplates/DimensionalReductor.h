//
//  DimensionalReduction.h
//  GestureRecognition
//
//  Created by dogukan ibrahimoglu on 3/11/11.
//  Copyright 2011 Bogazici University. All rights reserved.
//


#import "DataSet.h"
#import "GestureData.h"
#import "Constants.h"
#import "ConfigurationManager.h"

@interface DimensionalReductor : NSObject {

}

+(DimensionalReductor*) getDimensionReductor;
+(void) reset;
+(void)dimensionReduction:(DataSet*)currentDataSet;
+(void)dimensionReductionGestureData:(GestureData*)currentGestureData;

@end
