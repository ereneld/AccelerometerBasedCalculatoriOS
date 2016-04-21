//
//  Parameter.m
//  GestureRecognition
//
//  Created by dogukan ibrahimoglu on 1/2/11.
//  Copyright 2011 Bogazici University. All rights reserved.
//

#import "Parameter.h"
#import "Constants.h"

@implementation Parameter

@synthesize name, value, numberOfItemsInRange, rangeMin, rangeMax, isIncludeMinRange, isIncludeMaxRange, isUsedParameters;

- (double)value {
	self.isUsedParameters = YES;
    return value;
}

-(id)initWithDictionary:(NSDictionary*)dictionaryData{
	if (self = [super init])
    {
		self.name = [dictionaryData objectForKey:KDS_PARAMETER_NAME];
		self.value = [[dictionaryData objectForKey:KDS_PARAMETER_VALUE] doubleValue];
		self.numberOfItemsInRange = [[dictionaryData objectForKey:KDS_PARAMETER_NUMBEROFITEMSINRANGE] intValue];
		self.rangeMin = [[dictionaryData objectForKey:KDS_PARAMETER_RANGEMIN] doubleValue];
		self.rangeMax = [[dictionaryData objectForKey:KDS_PARAMETER_RANGEMAX] doubleValue];
		self.isIncludeMinRange = [[dictionaryData objectForKey:KDS_PARAMETER_ISINCLUDEMINRANGE] boolValue];
		self.isIncludeMaxRange = [[dictionaryData objectForKey:KDS_PARAMETER_ISINCLUDEMAXRANGE] boolValue];
		self.isUsedParameters = NO;
    }
    return self;
}

-(id)initWithParameterDetail:(NSString*)parameterName 
					andValue:(double)parameterValue 
	 andNumberOfItemsInRange:(int)parameterNumberOfItemsInRange 
				 andRangeMin:(double)parameterRangeMin 
				 andRangeMax:(double)parameterRangeMax 
		andIsIncludeMinRange:(BOOL)parameterIsIncludeMinRange 
		andIsIncludeMaxRange:(BOOL)parameterIsIncludeMaxRange
{
	if (self = [super init])
    {
		self.name = parameterName;
		self.value = parameterValue;
		self.numberOfItemsInRange = parameterNumberOfItemsInRange;
		self.rangeMin = parameterRangeMin;
		self.rangeMax = parameterRangeMax;
		self.isIncludeMinRange = parameterIsIncludeMinRange;
		self.isIncludeMaxRange = parameterIsIncludeMaxRange;
    }
    return self;
	
}

-(void)updateWithParameter:(Parameter*)otherParameter{
	self.name = otherParameter.name;
	self.value = otherParameter.value;
	self.numberOfItemsInRange = otherParameter.numberOfItemsInRange;
	self.rangeMin = otherParameter.rangeMin;
	self.rangeMax = otherParameter.rangeMax;
	self.isIncludeMinRange = otherParameter.isIncludeMinRange;
	self.isIncludeMaxRange = otherParameter.isIncludeMaxRange;
}

-(int)numberOfAllOptions{
	int returnValue = 0;
	if (isIncludeMaxRange) {
		returnValue ++;
	}
	if (isIncludeMinRange) {
		returnValue ++;
	}
	returnValue += numberOfItemsInRange;
	
	return returnValue;
}

-(void)initialValueAsFirstPossibleValue{
	if (isIncludeMinRange || numberOfItemsInRange == 0) {
		value = rangeMin;
	}
	else {
		value = rangeMin +( (rangeMax - rangeMin) / (numberOfItemsInRange + 1.0) );
	}

}

-(BOOL)setNextPossibleValue{
	BOOL returnValue = NO;
	
	double incrementValue = rangeMin +( (rangeMax - rangeMin) / (numberOfItemsInRange + 1.0) );
	if ( ((value + incrementValue) < rangeMax) || ((value + incrementValue) == rangeMax && isIncludeMaxRange)) {
		value += incrementValue;
		returnValue = YES;
	}
	else {
		returnValue = NO;
	}
	return returnValue;
}


-(NSString*)getParameterString{
	NSString* returnObject = [[[NSString alloc]initWithFormat:@"%@ : %g", name, value] autorelease];
	return returnObject;
}

-(void) dealloc{
	[name release];
	[super dealloc];
}

@end
