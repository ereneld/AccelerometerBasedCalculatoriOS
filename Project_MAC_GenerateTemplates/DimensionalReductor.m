//
//  DimensionalReduction.m
//  GestureRecognition
//
//  Created by dogukan ibrahimoglu on 3/11/11.
//  Copyright 2011 Bogazici University. All rights reserved.
//

#import "DimensionalReductor.h"
#import "FFT.h"

static DimensionalReductor* instanceObjectDimensionalReductor; //singleton object

//Hidden methods ! -> to use for instance object
@interface DimensionalReductor (PrivateMethods)

-(void)makeDimensionReduction:(NSArray*) gestureDataArray;

@end

@implementation DimensionalReductor

+(DimensionalReductor*) getDimensionReductor{
    if (!instanceObjectDimensionalReductor) {
        switch ((int)[ConfigurationManager getParameterValue:KPN_DIMENSIONALREDUCTOR_TYPE]) {
			case DimensionalRecudtorTypeNONE:
				instanceObjectDimensionalReductor = nil;
				break;
            case DimensionalRecudtorTypeFFT:
				instanceObjectDimensionalReductor = [[FFT alloc] init];
				break;
			default:
				instanceObjectDimensionalReductor = nil;
				break;

        }
    }
    return instanceObjectDimensionalReductor;
}

+(void) reset{
    [instanceObjectDimensionalReductor release];
    instanceObjectDimensionalReductor = nil;
}

+(void)dimensionReduction:(DataSet*)currentDataSet{
    DimensionalReductor* currentDimensionalReductor = [DimensionalReductor getDimensionReductor];
	if (currentDimensionalReductor) {
		for(NSArray* tempGestureDataArray in currentDataSet.gestureDataArray){
			[currentDimensionalReductor makeDimensionReduction:tempGestureDataArray];			
		}
		[currentDataSet.operationsequenceArray addObject:K_OPERATION_DIMENSIONALREDUCTION];
	}
	else {
		[currentDataSet.operationsequenceArray addObject:K_OPERATION_NONDIMENSIONALREDUCTION];
	}
	[DimensionalReductor reset];
}
+(void)dimensionReductionGestureData:(GestureData*)currentGestureData{
    DimensionalReductor* currentDimensionalReductor = [DimensionalReductor getDimensionReductor];
	if (currentDimensionalReductor) {
        NSMutableArray* tempArray = [[NSMutableArray alloc]initWithCapacity:1];
        [tempArray addObject:currentGestureData];
		[currentDimensionalReductor makeDimensionReduction:tempArray];
        [tempArray removeAllObjects];
        [tempArray release];
        tempArray = nil;
	}
	else {
		//do nothing
	}
	[DimensionalReductor reset];
}

@end


