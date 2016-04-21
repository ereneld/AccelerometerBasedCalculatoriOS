//
//  Parameter.h
//  GestureRecognition
//
//  Created by dogukan ibrahimoglu on 1/2/11.
//  Copyright 2011 Bogazici University. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Parameter : NSObject {

	NSString* name;
	double value;
	int numberOfItemsInRange;
	double rangeMin;
	double rangeMax;
	BOOL isIncludeMinRange;
	BOOL isIncludeMaxRange;
	
	BOOL isUsedParameters; // it is used to check that the parameter is used in program or not
}

@property(nonatomic, retain)NSString* name;
@property(nonatomic, assign)double value;
@property(nonatomic, assign)int numberOfItemsInRange;
@property(nonatomic, assign)double rangeMin;
@property(nonatomic, assign)double rangeMax;
@property(nonatomic, assign)BOOL isIncludeMinRange;
@property(nonatomic, assign)BOOL isIncludeMaxRange;
@property(nonatomic, assign)BOOL isUsedParameters;

-(id)initWithDictionary:(NSDictionary*)dictionaryData;
-(id)initWithParameterDetail:(NSString*)parameterName 
					andValue:(double)parameterValue 
	 andNumberOfItemsInRange:(int)parameterNumberOfItemsInRange 
				 andRangeMin:(double)parameterRangeMin 
				 andRangeMax:(double)parameterRangeMax 
		andIsIncludeMinRange:(BOOL)parameterIsIncludeMinRange 
		andIsIncludeMaxRange:(BOOL)parameterIsIncludeMaxRange;

-(void)updateWithParameter:(Parameter*)otherParameter;
-(int)numberOfAllOptions;

-(void)initialValueAsFirstPossibleValue;
-(BOOL)setNextPossibleValue;

-(NSString*)getParameterString;

@end
