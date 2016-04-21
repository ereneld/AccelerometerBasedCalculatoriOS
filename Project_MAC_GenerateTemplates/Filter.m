//
//  Filter.m
//  GestureRecognition
//
//  Created by dogukan ibrahimoglu on 1/19/11.
//  Copyright 2011 Bogazici University. All rights reserved.
//

#import "Filter.h"

#import "LowPassFilter.h"
#import "HighPassFilter.h"
#import "BandPassFilter.h"
#import "KalmanFilter.h"

static Filter* instanceObjectFilter; //singleton object

//Hidden methods ! -> to use for instance object
@interface Filter (PrivateMethods)

-(void)filterGestureData:(GestureData*)gestureData;
-(void)makeFilter:(double)currentX andY:(double)currentY andZ:(double)currentZ;

@end



@implementation Filter
@synthesize filteredX, filteredY, filteredZ, lastX, lastY, lastZ;

+(Filter*) getFilter{
	if (!instanceObjectFilter) {
		switch ((int)[ConfigurationManager getParameterValue:KPN_FILTER_TYPE]) {
			case FilterTypeNONE:
				instanceObjectFilter = nil;
				break;
			case FilterTypeLowPass:
				instanceObjectFilter = [[LowPassFilter alloc]
									   initWithSampleRate:[ConfigurationManager getParameterValue:KPN_FILTER_UPDATE_FREQUENCY] 
									   andCutoffFrequency:[ConfigurationManager getParameterValue:KPN_FILTER_CUTOFF_FREQUENCY] 
									   andIsAdaptive:[ConfigurationManager getParameterBOOLValue:KPN_FILTER_ISADAPTIVE] 
									   andMinStep:[ConfigurationManager getParameterValue:KPN_FILTER_ACCELEROMETER_MIN_STEP] 
									   andNoiseAttenuation:[ConfigurationManager getParameterValue:KPN_FILTER_ACCELEROMETER_NOISE_ATTENUATION]];
				
				
				break;
			case FilterTypeHighPass:
				instanceObjectFilter = [[HighPassFilter alloc]
										initWithSampleRate:[ConfigurationManager getParameterValue:KPN_FILTER_UPDATE_FREQUENCY2] 
										andCutoffFrequency:[ConfigurationManager getParameterValue:KPN_FILTER_CUTOFF_FREQUENCY2] 
										andIsAdaptive:[ConfigurationManager getParameterBOOLValue:KPN_FILTER_ISADAPTIVE2] 
										andMinStep:[ConfigurationManager getParameterValue:KPN_FILTER_ACCELEROMETER_MIN_STEP2] 
										andNoiseAttenuation:[ConfigurationManager getParameterValue:KPN_FILTER_ACCELEROMETER_NOISE_ATTENUATION2]];
				
				break;
			case FilterTypeBandPass:
			{
				LowPassFilter* tempLowPassFilter = [[[LowPassFilter alloc]
													initWithSampleRate:[ConfigurationManager getParameterValue:KPN_FILTER_UPDATE_FREQUENCY] 
													andCutoffFrequency:[ConfigurationManager getParameterValue:KPN_FILTER_CUTOFF_FREQUENCY] 
													andIsAdaptive:[ConfigurationManager getParameterBOOLValue:KPN_FILTER_ISADAPTIVE] 
													andMinStep:[ConfigurationManager getParameterValue:KPN_FILTER_ACCELEROMETER_MIN_STEP] 
													andNoiseAttenuation:[ConfigurationManager getParameterValue:KPN_FILTER_ACCELEROMETER_NOISE_ATTENUATION]] autorelease];
				
				
				HighPassFilter* tempHighPassFilter= [[HighPassFilter alloc]
													 initWithSampleRate:[ConfigurationManager getParameterValue:KPN_FILTER_UPDATE_FREQUENCY2] 
													 andCutoffFrequency:[ConfigurationManager getParameterValue:KPN_FILTER_CUTOFF_FREQUENCY2] 
													 andIsAdaptive:[ConfigurationManager getParameterBOOLValue:KPN_FILTER_ISADAPTIVE2] 
													 andMinStep:[ConfigurationManager getParameterValue:KPN_FILTER_ACCELEROMETER_MIN_STEP2] 
													 andNoiseAttenuation:[ConfigurationManager getParameterValue:KPN_FILTER_ACCELEROMETER_NOISE_ATTENUATION2]];
				
				instanceObjectFilter = [[BandPassFilter alloc]initWithLowFilter:tempLowPassFilter andHighPassFilter:tempHighPassFilter];
			}
				 break;
			case FilterTypeKalman:
				instanceObjectFilter = nil;
				break;
			default:
				instanceObjectFilter = nil;
				break;
		}
	}
	return instanceObjectFilter;
}

+(void) reset{
	[instanceObjectFilter release];
	instanceObjectFilter = nil;
}

+(void)filterDataSet:(DataSet*)currentDataSet{
	Filter* currentFilter = [Filter getFilter];
	if (currentFilter) {
		for(NSArray* tempGestureDataArray in currentDataSet.gestureDataArray){
			for(GestureData* tempGestureData in tempGestureDataArray){
				[currentFilter filterGestureData:tempGestureData];
			}			
		}
		[currentDataSet.operationsequenceArray addObject:K_OPERATION_FILTER];
	}
	else {
		[currentDataSet.operationsequenceArray addObject:K_OPERATION_NONFILTER];
	}
	[Filter reset];
}

+(void)filterGestureData:(GestureData*)currentGestureData{
    Filter* currentFilter = [Filter getFilter];
	if (currentFilter) {
		[currentFilter filterGestureData:currentGestureData];
	}
	else {
		// do nothing
	}
	[Filter reset];
}

-(void)filterGestureData:(GestureData*)gestureData{
	
	NSArray* dataArray = gestureData.gestureData;
	if (dataArray!= nil &&  [dataArray count]>0) {
		NSMutableArray* timeArray = [dataArray objectAtIndex:0];
		NSMutableArray* xArray = [dataArray objectAtIndex:1];
		NSMutableArray* yArray = [dataArray objectAtIndex:2];
		NSMutableArray* zArray = [dataArray objectAtIndex:3];
		
		//Filter initial condition
		filteredX = [(NSNumber*)[xArray objectAtIndex:0] doubleValue];
		filteredY = [(NSNumber*)[yArray objectAtIndex:0] doubleValue];
		filteredZ = [(NSNumber*)[zArray objectAtIndex:0] doubleValue];
		
		lastX = 0.0;
		lastY = 0.0;
		lastZ = 0.0;
		
		for(int i=0; i<[timeArray count]; i++){
			[self makeFilter:[(NSNumber*)[xArray objectAtIndex:i] doubleValue] andY:[(NSNumber*)[yArray objectAtIndex:i] doubleValue] andZ:[[zArray objectAtIndex:i] doubleValue]];
						
			[xArray replaceObjectAtIndex:i withObject:[[NSNumber alloc] initWithDouble:filteredX]];
			[yArray replaceObjectAtIndex:i withObject:[[NSNumber alloc] initWithDouble:filteredY]];
			[zArray replaceObjectAtIndex:i withObject:[[NSNumber alloc] initWithDouble:filteredZ]];
		}
	}
}

-(double)Norm:(double)x andY:(double)y andZ:(double)z
{
	return sqrt(x * x + y * y + z * z);
}

-(double)Clamp:(double) v andMin:(double)min andMax:(double) max
{
	if(v > max){
		return max;
    }
	else if(v < min){
		return min;
    }
	else{
		return v;
    }
}
 
-(void) dealloc{
	[super dealloc];
}

@end
