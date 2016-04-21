//
//  ConfigurationManager.h
//  GestureRecognition
//
//  Created by dogukan ibrahimoglu on 1/2/11.
//  Copyright 2011 Bogazici University. All rights reserved.
//


#import "Parameter.h"
#import "ConfusionMatrix.h"

@class GestureData;

@interface ConfigurationManager : NSObject {
	NSMutableArray* parameterList;
	NSMutableArray* bestParameterList;
    
    ConfusionMatrix* bestConfusionMatrix;
	
    NSMutableDictionary* configurationList; // it holds all the configuration for clustering and classification to use in standalone
}

//TODO: init from plist
+(void)initializeParameters;
+(void)initializeConfigurationList;
+(double)getParameterValue:(NSString*)parameterName;
+(BOOL)getParameterBOOLValue:(NSString*)parameterName;
+(void)addParameter:(Parameter*)parameter;
+(void)addParameterWithDetail:(NSString*)parameterName 
					 andValue:(double)value 
	  andNumberOfItemsInRange:(int)numberOfItemsInRange 
				  andRangeMin:(double)rangeMin 
				  andRangeMax:(double)rangeMax 
		 andIsIncludeMinRange:(BOOL)isIncludeMinRange 
		 andIsIncludeMaxRange:(BOOL)isIncludeMaxRange;

+(int)numberOfAllParameterOptions;
+(NSString*)getCurrentParameterConfigurationString;
+(NSString*)getBestParameterConfigurationString;
+(ConfusionMatrix*)getBestConfusionMatrix;

+(void)initialAllParameterValuesAsFirstPossibleValue; //make all parameters value to the initial value
+(void)makeAllParametersUnused; //make all parameters as unused to determine which are used!
+(BOOL)setNextPossibleParameterValue;			// the next possible parameter value -> we need to increment it step by step to find the best value according to given parameters
+(BOOL)setParameterValue:(NSString*)parameterName andNewValue:(double)newValue;

+(void)saveParameterIfBetterResult:(ConfusionMatrix*)classificationResult;

+(void)addConfiguration:(NSDictionary*)configurationDictionary andName:(NSString*)nameOfConfiguration;
+(void)addConfigurationValue:(id)configurationValue andName:(NSString*)nameOfConfiguration;
+(NSDictionary*)getConfiguration:(NSString*)nameOfConfiguration;
+(id)getConfigurationValue:(NSString*)nameOfConfiguration;
+(void)saveConfigurationList:(NSString*)configurationName;
+(void)saveConfigurationList;
+(void)loadConfigurationList;
+(void)loadConfigurationList:(NSString*)configurationName;
+(void)saveDTWTemplates:(NSString*)directoryToSave;

+(int)getClassificationResult:(GestureData*)currentGestureData;
@end
