//
//  BandPassFilter.m
//  GestureRecognition
//
//  Created by dogukan ibrahimoglu on 1/19/11.
//  Copyright 2011 Bogazici University. All rights reserved.
//

#import "BandPassFilter.h"

@implementation BandPassFilter

@synthesize lowPassFilter, highPassFilter;

-(id)initWithLowFilter:(LowPassFilter*)lowPassFiltr andHighPassFilter:(HighPassFilter*)highPassFiltr{
	if(self = [super init])
	{
		self.lowPassFilter = lowPassFiltr;
		self.highPassFilter = highPassFiltr;
	}
	return self;
}


-(void)makeFilter:(double)currentX andY:(double)currentY andZ:(double)currentZ{
	
	[lowPassFilter makeFilter:currentX andY:currentY andZ:currentZ];
	
	[highPassFilter makeFilter:lowPassFilter.filteredX andY:lowPassFilter.filteredY andZ:lowPassFilter.filteredZ];
	
	filteredX = highPassFilter.filteredX;
	filteredY = highPassFilter.filteredY;
	filteredZ = highPassFilter.filteredZ;
}

@end
