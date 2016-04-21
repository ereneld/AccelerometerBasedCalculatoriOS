//
//  HighPassFilter.m
//  GestureRecognition
//
//  Created by dogukan ibrahimoglu on 1/19/11.
//  Copyright 2011 Bogazici University. All rights reserved.
//

#import "HighPassFilter.h"


@implementation HighPassFilter

@synthesize filterConstant, isAdaptive, minStep, noiseAttenuation;

-(id)initWithSampleRate:(double)updateFrequency andCutoffFrequency:(double)cutoffFrequency andIsAdaptive:(BOOL)isAdaptiveFilter andMinStep:(double)minStepFilter andNoiseAttenuation:(double)noiseAttenuationFilter
{
	if(self = [super init])
	{
		double dt = 1.0 / updateFrequency;
		double RC = 1.0 / cutoffFrequency;
		self.filterConstant = dt / (dt + RC);
		
		self.isAdaptive = isAdaptiveFilter;
		self.minStep = minStepFilter;
		self.noiseAttenuation = noiseAttenuationFilter;
	}
	return self;
}

-(void)makeFilter:(double)currentX andY:(double)currentY andZ:(double)currentZ
{
	double alpha = filterConstant;
	
	if(isAdaptive==1)
	{
        double differenceMean = (fabs(  [self Norm:filteredX andY:filteredY andZ:filteredZ] - [self Norm:currentX andY:currentY andZ:currentZ] ) / minStep) - 1.0;
		double d =  [self Clamp:differenceMean andMin:0.0 andMax:1.0];
		alpha = d * filterConstant / noiseAttenuation + (1.0 - d) * filterConstant;
	}
	
	filteredX = alpha * (filteredX + currentX - lastX);
	filteredY = alpha * (filteredY + currentY - lastY);
	filteredZ = alpha * (filteredZ + currentZ - lastZ);
	
	lastX = currentX;
	lastY = currentY;
	lastZ = currentZ;
	
	/*
	 x = alpha * (x + accel.x - lastX);
	 y = alpha * (y + accel.y - lastY);
	 z = alpha * (z + accel.z - lastZ);
	 
	 lastX = accel.x;
	 lastY = accel.y;
	 lastZ = accel.z;
	 
	 -------
	 lastV . x = (v . x ∗ kHighPas sFi l terFactor ) + ( lastV . x ∗ (1.0 − kHighPas sFi l terFactor ) ) ;
	 lastV . y = (v . y ∗ kHighPas sFi l terFactor ) + ( lastV . y ∗ (1.0 − kHighPas sFi l terFactor ) ) ;
	 lastV . z = (v . z ∗ kHighPas sFi l terFactor ) + ( lastV . z ∗ (1.0 − kHighPas sFi l terFactor ) ) ;
	 v . x = v . x − lastV . x ; 
	 v . y = v . y − lastV . y ; 
	 v . z = v . z − lastV . z ;
	 
	 */
}

@end

