//
//  Sampler.m
//  GestureRecognition
//
//  Created by dogukan ibrahimoglu on 3/11/11.
//  Copyright 2011 Bogazici University. All rights reserved.
//

#import "Sampler.h"

#import "SimpleSampler.h"
#import "AverageSampler.h"
#import "MedianSampler.h"
#import "MiddleSampler.h"

static Sampler* instanceObjectSampler; //singleton object

//Hidden methods ! -> to use for instance object
@interface Sampler (PrivateMethods)

-(id)initWithSampleCount:(int)sampleSizeValue;	//Each sampling algorithm has the same initial method, so we can put it in their parent
-(void)sampleGestureData:(NSArray*)gestureDataArray;

@end

@implementation Sampler

+(Sampler*) getSampler{
	if (!instanceObjectSampler) {
		switch ((int)[ConfigurationManager getParameterValue:KPN_SAMPLER_TYPE]) {
			case SamplerTypeNONE:
				instanceObjectSampler = nil;
				break;
			case SamplerTypeSimple:
				instanceObjectSampler = [[SimpleSampler alloc]
										 initWithSampleCount:[ConfigurationManager getParameterValue:KPN_SAMPLE_SIZE]];
				break;
			case SamplerTypeAverage:
				instanceObjectSampler = [[AverageSampler alloc]
										 initWithSampleCount:[ConfigurationManager getParameterValue:KPN_SAMPLE_SIZE]];
				
				break;
			case SamplerTypeMedian:
				instanceObjectSampler = [[MedianSampler alloc]
										 initWithSampleCount:[ConfigurationManager getParameterValue:KPN_SAMPLE_SIZE]];
				break;
			case SamplerTypeMiddle:
				instanceObjectSampler = [[MiddleSampler alloc]
										 initWithSampleCount:[ConfigurationManager getParameterValue:KPN_SAMPLE_SIZE]];
				break;
			default:
				instanceObjectSampler = nil;
				break;
		}
	}
	return instanceObjectSampler;
}

+(void) reset{
	[instanceObjectSampler release];
	instanceObjectSampler = nil;
}

+(void)sampleDataSet:(DataSet*)currentDataSet{
	Sampler* currentSampler = [Sampler getSampler];
	if (currentSampler) {
		for(NSArray* tempGestureDataArray in currentDataSet.gestureDataArray){
			for(GestureData* tempGestureData in tempGestureDataArray){
				[currentSampler sampleGestureData:tempGestureData.gestureData];
			}			
		}
		[currentDataSet.operationsequenceArray addObject:K_OPERATION_SAMPLING];
	}
	else {
		[currentDataSet.operationsequenceArray addObject:K_OPERATION_NONSAMPLING];
	}
	[Sampler reset];
}

+(void)sampleGestureData:(GestureData*)currentGestureData{
    Sampler* currentSampler = [Sampler getSampler];
	if (currentSampler) {
		[currentSampler sampleGestureData:currentGestureData.gestureData];
	}
	else {
        //do nothing
	}
	[Sampler reset];
}
-(id)initWithSampleCount:(int)sampleSizeValue{
    self = [super init];
	if(self)
	{
		sampleSize = sampleSizeValue;
	}
	return self;
}


@end
