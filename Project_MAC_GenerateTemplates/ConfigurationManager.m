//
//  ConfigurationManager.m
//  GestureRecognition
//
//  Created by dogukan ibrahimoglu on 1/2/11.
//  Copyright 2011 Bogazici University. All rights reserved.
//

#import "ConfigurationManager.h"
#import "Constants.h"

#import "Filter.h"
#import "DimensionalReductor.h"
#import "Cluster.h"
#import "Sampler.h"
#import "Preprocessor.h"
#import "NoiseEliminator.h"
#import "CrossValidator.h"
#import "Classifier.h"

static ConfigurationManager* instanceObjectConfigurationManager; //singleton object

//Hidden methods ! -> to use for instance object
@interface ConfigurationManager (PrivateMethods)
-(Parameter*)getParameter:(NSString*)parameterName;
-(double)getParameterValue:(NSString*)parameterName;
-(BOOL)getParameterBOOLValue:(NSString*)parameterName;
-(void)addParameter:(Parameter*)parameter;
-(void)addParameterWithDetail:(NSString*)parameterName 
					 andValue:(double)value 
	  andNumberOfItemsInRange:(int)numberOfItemsInRange 
				  andRangeMin:(double)rangeMin 
				  andRangeMax:(double)rangeMax 
		 andIsIncludeMinRange:(BOOL)isIncludeMinRange 
		 andIsIncludeMaxRange:(BOOL)isIncludeMaxRange; 

-(int)numberOfAllParameterOptions;
-(NSString*)getCurrentParameterConfigurationString;
-(NSString*)getBestParameterConfigurationString;
-(ConfusionMatrix*)getBestConfusionMatrix;

-(void)initialAllParameterValuesAsFirstPossibleValue;
-(void)initializeConfigurationList;
-(void)makeAllParametersUnused;
-(BOOL)setParameterValue:(NSString*)parameterName andNewValue:(double)newValue;
-(BOOL)setNextPossibleParameterValue;
-(BOOL)setNextPossibleParameterValue:(int)parameterIndex; // Recursive function for Parameter Tunning
-(void)saveParameterIfBetterResult:(ConfusionMatrix*)classificationResult;

-(void)addConfiguration:(NSDictionary*)configurationDictionary andName:(NSString*)nameOfConfiguration;
-(void)addConfigurationValue:(id)configurationValue andName:(NSString*)nameOfConfiguration;
-(NSDictionary*)getConfiguration:(NSString*)nameOfConfiguration;
-(id)getConfigurationValue:(NSString*)nameOfConfiguration;
//-(void)saveConfigurationList:(NSString*)fullPath;
//-(void)saveConfigurationList;
-(void)saveConfigurationList:(NSString*)configurationName;
-(NSString*) getDocumentsDirectory;
-(void)loadConfigurationList:(NSString*)configurationName;
//-(void)loadConfigurationList;

@end

@implementation ConfigurationManager

+(ConfigurationManager*) getConfigurationManager{
	if (!instanceObjectConfigurationManager) {
		instanceObjectConfigurationManager = [[ConfigurationManager alloc] init];
	}
	return instanceObjectConfigurationManager;
}

+(double)getParameterValue:(NSString*)parameterName{
	return [[ConfigurationManager getConfigurationManager]getParameterValue:parameterName];
}

+(BOOL)getParameterBOOLValue:(NSString*)parameterName{
	return [[ConfigurationManager getConfigurationManager]getParameterBOOLValue:parameterName];
}

+(void)addParameter:(Parameter*)parameter{
	[[ConfigurationManager getConfigurationManager]addParameter:parameter];
}
+(void)addParameterWithDetail:(NSString*)parameterName 
					 andValue:(double)value 
	  andNumberOfItemsInRange:(int)numberOfItemsInRange 
				  andRangeMin:(double)rangeMin 
				  andRangeMax:(double)rangeMax 
		 andIsIncludeMinRange:(BOOL)isIncludeMinRange 
		 andIsIncludeMaxRange:(BOOL)isIncludeMaxRange
{
	[[ConfigurationManager getConfigurationManager]addParameterWithDetail:parameterName andValue:value andNumberOfItemsInRange:numberOfItemsInRange andRangeMin:rangeMin andRangeMax:rangeMax andIsIncludeMinRange:isIncludeMinRange andIsIncludeMaxRange:isIncludeMaxRange];
}

+(int)numberOfAllParameterOptions{
	return [[ConfigurationManager getConfigurationManager] numberOfAllParameterOptions];
}
+(NSString*)getCurrentParameterConfigurationString{
	return [[ConfigurationManager getConfigurationManager] getCurrentParameterConfigurationString];
}
+(NSString*)getBestParameterConfigurationString{
 return [[ConfigurationManager getConfigurationManager] getBestParameterConfigurationString];   
}
+(ConfusionMatrix*)getBestConfusionMatrix{
     return [[ConfigurationManager getConfigurationManager] getBestConfusionMatrix];
}
+(void)initialAllParameterValuesAsFirstPossibleValue{
	[[ConfigurationManager getConfigurationManager]initialAllParameterValuesAsFirstPossibleValue];
}

+(void)makeAllParametersUnused{
	[[ConfigurationManager getConfigurationManager]makeAllParametersUnused];
}

+(BOOL)setNextPossibleParameterValue{
	return [[ConfigurationManager getConfigurationManager]setNextPossibleParameterValue];
}
+(BOOL)setParameterValue:(NSString*)parameterName andNewValue:(double)newValue{
	return [[ConfigurationManager getConfigurationManager]setParameterValue:parameterName andNewValue:newValue];
}

+(void)saveParameterIfBetterResult:(ConfusionMatrix*)classificationResult{
	[[ConfigurationManager getConfigurationManager]saveParameterIfBetterResult:classificationResult ];
}
+(void)initializeConfigurationList{
    [[ConfigurationManager getConfigurationManager]initializeConfigurationList];
}
+(void)initializeParameters{
    //Dimensional Reduction Parameter Inialization
	[ConfigurationManager addParameterWithDetail:KPN_DIMENSIONALREDUCTOR_TYPE andValue:DimensionalRecudtorTypeFFT andNumberOfItemsInRange:(DimensionalRecudtorTypeNAN-DimensionalRecudtorTypeNONE-1) andRangeMin:DimensionalRecudtorTypeNONE andRangeMax:DimensionalRecudtorTypeNAN andIsIncludeMinRange:YES andIsIncludeMaxRange:NO];
	
	//Filter Parameter Inialization
	[ConfigurationManager addParameterWithDetail:KPN_FILTER_TYPE andValue:FilterTypeLowPass andNumberOfItemsInRange:(FilterTypeNAN-FilterTypeNONE-1) andRangeMin:FilterTypeNONE andRangeMax:FilterTypeNAN andIsIncludeMinRange:YES andIsIncludeMaxRange:NO];
	[ConfigurationManager addParameterWithDetail:KPN_FILTER_ISADAPTIVE andValue:0.0 andNumberOfItemsInRange:0 andRangeMin:0.0 andRangeMax:1.0 andIsIncludeMinRange:YES andIsIncludeMaxRange:YES];
	[ConfigurationManager addParameterWithDetail:KPN_FILTER_UPDATE_FREQUENCY andValue:60.0 andNumberOfItemsInRange:2 andRangeMin:20.0 andRangeMax:60.0 andIsIncludeMinRange:YES andIsIncludeMaxRange:YES];
	[ConfigurationManager addParameterWithDetail:KPN_FILTER_CUTOFF_FREQUENCY andValue:10.0 andNumberOfItemsInRange:5 andRangeMin:1.0 andRangeMax:10.0 andIsIncludeMinRange:YES andIsIncludeMaxRange:YES];
	[ConfigurationManager addParameterWithDetail:KPN_FILTER_ACCELEROMETER_MIN_STEP andValue:0.002 andNumberOfItemsInRange:5 andRangeMin:0.001 andRangeMax:1.0 andIsIncludeMinRange:YES andIsIncludeMaxRange:YES];
	[ConfigurationManager addParameterWithDetail:KPN_FILTER_ACCELEROMETER_NOISE_ATTENUATION andValue:1.0 andNumberOfItemsInRange:5 andRangeMin:0.1 andRangeMax:5.0 andIsIncludeMinRange:YES andIsIncludeMaxRange:YES];
	
	[ConfigurationManager addParameterWithDetail:KPN_FILTER_ISADAPTIVE2 andValue:0.0 andNumberOfItemsInRange:0 andRangeMin:0.0 andRangeMax:1.0 andIsIncludeMinRange:YES andIsIncludeMaxRange:YES];
	[ConfigurationManager addParameterWithDetail:KPN_FILTER_UPDATE_FREQUENCY2 andValue:60.0 andNumberOfItemsInRange:2 andRangeMin:20.0 andRangeMax:60.0 andIsIncludeMinRange:YES andIsIncludeMaxRange:YES];
	[ConfigurationManager addParameterWithDetail:KPN_FILTER_CUTOFF_FREQUENCY2 andValue:15.0 andNumberOfItemsInRange:5 andRangeMin:1.0 andRangeMax:10.0 andIsIncludeMinRange:YES andIsIncludeMaxRange:YES];
	[ConfigurationManager addParameterWithDetail:KPN_FILTER_ACCELEROMETER_MIN_STEP2 andValue:0.02 andNumberOfItemsInRange:5 andRangeMin:0.001 andRangeMax:1.0 andIsIncludeMinRange:YES andIsIncludeMaxRange:YES];
	[ConfigurationManager addParameterWithDetail:KPN_FILTER_ACCELEROMETER_NOISE_ATTENUATION2 andValue:2.0 andNumberOfItemsInRange:5 andRangeMin:0.1 andRangeMax:5.0 andIsIncludeMinRange:YES andIsIncludeMaxRange:YES];
	
    //Sampling Parameters
	[ConfigurationManager addParameterWithDetail:KPN_SAMPLER_TYPE andValue:SamplerTypeAverage andNumberOfItemsInRange:(SamplerTypeNAN-SamplerTypeNONE-1) andRangeMin:SamplerTypeNONE andRangeMax:SamplerTypeNAN andIsIncludeMinRange:YES andIsIncludeMaxRange:NO];
	[ConfigurationManager addParameterWithDetail:KPN_SAMPLE_SIZE andValue:30.0 andNumberOfItemsInRange:5 andRangeMin:20.0 andRangeMax:60.0 andIsIncludeMinRange:YES andIsIncludeMaxRange:YES];
    
	//Noise Elimination Parameters
	[ConfigurationManager addParameterWithDetail:KPN_NOISEELIMINATOR_DATAAVERAGEAMPLITUTE andValue:1 andNumberOfItemsInRange:0 andRangeMin:0 andRangeMax:1 andIsIncludeMinRange:YES andIsIncludeMaxRange:YES];
	[ConfigurationManager addParameterWithDetail:KPN_NOISEELIMINATOR_DATALENGTH andValue:1 andNumberOfItemsInRange:0 andRangeMin:0 andRangeMax:1 andIsIncludeMinRange:YES andIsIncludeMaxRange:YES];
	[ConfigurationManager addParameterWithDetail:KPN_NOISEELIMINATOR_MIN_AVERAGE_AMP andValue:0.95 andNumberOfItemsInRange:0 andRangeMin:0 andRangeMax:2 andIsIncludeMinRange:NO andIsIncludeMaxRange:NO];
	[ConfigurationManager addParameterWithDetail:KPN_NOISEELIMINATOR_MAX_AVERAGE_AMP andValue:2.1 andNumberOfItemsInRange:0 andRangeMin:1.1 andRangeMax:4 andIsIncludeMinRange:NO andIsIncludeMaxRange:NO];
	[ConfigurationManager addParameterWithDetail:KPN_NOISEELIMINATOR_MIN_LENGTH andValue:[ConfigurationManager getParameterValue:KPN_SAMPLE_SIZE] andNumberOfItemsInRange:0 andRangeMin:0 andRangeMax:30 andIsIncludeMinRange:NO andIsIncludeMaxRange:NO];
	[ConfigurationManager addParameterWithDetail:KPN_NOISEELIMINATOR_MAX_LENGTH andValue:205 andNumberOfItemsInRange:0 andRangeMin:60 andRangeMax:140 andIsIncludeMinRange:NO andIsIncludeMaxRange:NO];
	
    [ConfigurationManager addParameterWithDetail:KPN_NOISEELIMINATOR_MINTIME_LENGTH andValue:[ConfigurationManager getParameterValue:KPN_NOISEELIMINATOR_MIN_LENGTH]/K_UPDATE_FREQUENCY andNumberOfItemsInRange:0 andRangeMin:0 andRangeMax:30 andIsIncludeMinRange:NO andIsIncludeMaxRange:NO];
	 [ConfigurationManager addParameterWithDetail:KPN_NOISEELIMINATOR_MAXTIME_LENGTH andValue:[ConfigurationManager getParameterValue:KPN_NOISEELIMINATOR_MAX_LENGTH]/K_UPDATE_FREQUENCY andNumberOfItemsInRange:0 andRangeMin:0 andRangeMax:30 andIsIncludeMinRange:NO andIsIncludeMaxRange:NO];
	
	//Cluster Parameter Inialization
	[ConfigurationManager addParameterWithDetail:KPN_CLUSTER_TYPE andValue:ClusterTypeAmplitudeDynamic andNumberOfItemsInRange:(ClusterTypeNAN - ClusterTypeNONE-1) andRangeMin:ClusterTypeNONE andRangeMax:ClusterTypeNAN andIsIncludeMinRange:NO andIsIncludeMaxRange:NO];
	
	[ConfigurationManager addParameterWithDetail:KPN_CLUSTER_NUMBER andValue:20.0 andNumberOfItemsInRange:5 andRangeMin:5.0 andRangeMax:40.0 andIsIncludeMinRange:YES andIsIncludeMaxRange:YES];
	[ConfigurationManager addParameterWithDetail:KPN_CLUSTER_INITIALIZATION andValue:ClusterInializationTypeSphericalRandomInUnitSphere andNumberOfItemsInRange:4 andRangeMin:ClusterInializationTypeNONE andRangeMax:ClusterInializationTypeNAN andIsIncludeMinRange:NO andIsIncludeMaxRange:NO];
	
	[ConfigurationManager addParameterWithDetail:KPN_CLUSTER_DIMENSION andValue:3.0 andNumberOfItemsInRange:0 andRangeMin:3.0 andRangeMax:3.0 andIsIncludeMinRange:NO andIsIncludeMaxRange:NO];
	[ConfigurationManager addParameterWithDetail:KPN_CLUSTER_RANGE_MIN_X andValue:-2.5 andNumberOfItemsInRange:1 andRangeMin:-4.0 andRangeMax:0.0 andIsIncludeMinRange:YES andIsIncludeMaxRange:YES];
	[ConfigurationManager addParameterWithDetail:KPN_CLUSTER_RANGE_MAX_X andValue:2.5 andNumberOfItemsInRange:1 andRangeMin:0.0 andRangeMax:4.0 andIsIncludeMinRange:YES andIsIncludeMaxRange:YES];
	[ConfigurationManager addParameterWithDetail:KPN_CLUSTER_RANGE_MIN_Y andValue:-2.5 andNumberOfItemsInRange:1 andRangeMin:-4.0 andRangeMax:0.0 andIsIncludeMinRange:YES andIsIncludeMaxRange:YES];
	[ConfigurationManager addParameterWithDetail:KPN_CLUSTER_RANGE_MAX_Y andValue:2.5 andNumberOfItemsInRange:1 andRangeMin:0.0 andRangeMax:4.0 andIsIncludeMinRange:YES andIsIncludeMaxRange:YES];
	[ConfigurationManager addParameterWithDetail:KPN_CLUSTER_RANGE_MIN_Z andValue:-2.5 andNumberOfItemsInRange:1 andRangeMin:-4.0 andRangeMax:0.0 andIsIncludeMinRange:YES andIsIncludeMaxRange:YES];
	[ConfigurationManager addParameterWithDetail:KPN_CLUSTER_RANGE_MAX_Z andValue:2.5 andNumberOfItemsInRange:1 andRangeMin:0.0 andRangeMax:4.0 andIsIncludeMinRange:YES andIsIncludeMaxRange:YES];
    //If the clustering type is trajectory angle
	[ConfigurationManager addParameterWithDetail:KPN_CLUSTER_XY_SPLIT andValue:1 andNumberOfItemsInRange:2 andRangeMin:1.0 andRangeMax:4.0 andIsIncludeMinRange:YES andIsIncludeMaxRange:YES];
	[ConfigurationManager addParameterWithDetail:KPN_CLUSTER_XZ_SPLIT andValue:36 andNumberOfItemsInRange:2 andRangeMin:1.0 andRangeMax:4.0 andIsIncludeMinRange:YES andIsIncludeMaxRange:YES];
	[ConfigurationManager addParameterWithDetail:KPN_CLUSTER_YZ_SPLIT andValue:1 andNumberOfItemsInRange:2 andRangeMin:1.0 andRangeMax:4.0 andIsIncludeMinRange:YES andIsIncludeMaxRange:YES];
	
	
	//Classification
	[ConfigurationManager addParameterWithDetail:KPN_CLASSIFIER_TYPE andValue:ClassifierTypeDTW andNumberOfItemsInRange:(ClassifierTypeNAN - ClassifierTypeNONE-1) andRangeMin:ClassifierTypeNONE andRangeMax:ClassifierTypeNAN andIsIncludeMinRange:NO andIsIncludeMaxRange:NO];
	[ConfigurationManager addParameterWithDetail:KPN_CLASSIFIER_STATE_NUMBER andValue:8.0 andNumberOfItemsInRange:1 andRangeMin:0.0 andRangeMax:4.0 andIsIncludeMinRange:YES andIsIncludeMaxRange:YES];
	[ConfigurationManager addParameterWithDetail:KPN_CLASSIFIER_OBSERVATION_NUMBER andValue:20.0 andNumberOfItemsInRange:1 andRangeMin:0.0 andRangeMax:4.0 andIsIncludeMinRange:YES andIsIncludeMaxRange:YES];
	[ConfigurationManager addParameterWithDetail:KPN_CLASSIFIER_MAX_ITERATION andValue:5.0 andNumberOfItemsInRange:1 andRangeMin:0.0 andRangeMax:40.0 andIsIncludeMinRange:YES andIsIncludeMaxRange:YES];
	
	//Cross Validation Parameters
	[ConfigurationManager addParameterWithDetail:KPN_CROSSVALIDATOR_TYPE andValue:CrossValidatorTypeLeaveOneOut andNumberOfItemsInRange:(CrossValidatorTypeNAN - CrossValidatorTypeNONE-1) andRangeMin:CrossValidatorTypeNONE andRangeMax:CrossValidatorTypeNAN andIsIncludeMinRange:YES andIsIncludeMaxRange:NO];
	[ConfigurationManager addParameterWithDetail:KPN_CROSSVALIDATOR_K_NUMBER andValue:10.0 andNumberOfItemsInRange:1 andRangeMin:10.0 andRangeMax:20.0 andIsIncludeMinRange:YES andIsIncludeMaxRange:YES];
}

+(void)addConfiguration:(NSDictionary*)configurationDictionary andName:(NSString*)nameOfConfiguration{
    [[ConfigurationManager getConfigurationManager]addConfiguration:configurationDictionary andName:nameOfConfiguration];
}

+(void)addConfigurationValue:(id)configurationValue andName:(NSString*)nameOfConfiguration{
    [[ConfigurationManager getConfigurationManager]addConfigurationValue:configurationValue andName:nameOfConfiguration];
}
+(NSDictionary*)getConfiguration:(NSString*)nameOfConfiguration{
    return [[ConfigurationManager getConfigurationManager]getConfiguration:nameOfConfiguration];
}

+(id)getConfigurationValue:(NSString*)nameOfConfiguration{
     return [[ConfigurationManager getConfigurationManager]getConfigurationValue:nameOfConfiguration];
}
+(void)saveConfigurationList:(NSString*)configurationName{
    [[ConfigurationManager getConfigurationManager]saveConfigurationList:configurationName];
}
+(void)saveConfigurationList{
    [[ConfigurationManager getConfigurationManager]saveConfigurationList:@""];
}

+(void)loadConfigurationList:(NSString*)configurationName{
    [[ConfigurationManager getConfigurationManager]loadConfigurationList:configurationName];   
}
+(void)loadConfigurationList{
    [[ConfigurationManager getConfigurationManager]loadConfigurationList:@""];   
}

+(void)saveDTWTemplates:(NSString*)directoryToSave{
	NSString* stringDTWTemplate=@"";
    NSString* stringUpperBound=@"";
    NSString* stringLowerBound=@"";
    NSString* stringDTWDistanceMinAvgMax=@"";
    NSString* stringWarpingWindowSizesForX=@"";
    NSString* stringWarpingWindowSizesForY=@"";
    NSString* stringWarpingWindowSizesForZ=@"";
    
    double currentT = 0.0, currentX = 0.0, currentY=0.0, currentZ=0.0;
	int clusterNumber=0;
	
    int numberOfModel = [[ConfigurationManager getConfigurationValue:@"numberOfModel"] intValue];
    for (int i=0; i<numberOfModel; i++) {
        stringDTWTemplate=@"";stringUpperBound=@"";stringLowerBound=@"";
        NSDictionary* configurationFile = [ConfigurationManager getConfiguration:[NSString stringWithFormat:@"%@_%d",KC_CLASSIFIER,i]];
      
        //NSMutableArray* arrayVariance = [configurationFile objectForKey:@"arrayVariance"];
        //NSMutableArray* arrayMean = [configurationFile objectForKey:@"arrayMean"];
        NSMutableArray* arrayTemplateT = [configurationFile objectForKey:@"arrayTemplateT"];
        NSMutableArray* arrayTemplateX = [configurationFile objectForKey:@"arrayTemplateX"];
        NSMutableArray* arrayTemplateY = [configurationFile objectForKey:@"arrayTemplateY"];
        NSMutableArray* arrayTemplateZ = [configurationFile objectForKey:@"arrayTemplateZ"];
        NSMutableArray* arrayTemplateC = [configurationFile objectForKey:@"arrayTemplateC"];
        
        NSMutableArray* arrayUpperLimitAll = [configurationFile objectForKey:@"arrayUpperLimitAll"];
        NSMutableArray* arrayLowerLimitAll = [configurationFile objectForKey:@"arrayLowerLimitAll"];
        
        NSMutableArray* arrayDTWDistanceMinAvgMax = [configurationFile objectForKey:@"arrayDistanceDTWAll"];
        NSMutableArray* arrayWarpingWindowAll = [configurationFile objectForKey:@"arrayWarpingWindowAll"];
        
        stringDTWDistanceMinAvgMax = [stringDTWDistanceMinAvgMax 
                                       stringByAppendingString:[NSString stringWithFormat:@"%g,%g,%g,%g,%g,%g\n" ,
                                                                [[[arrayDTWDistanceMinAvgMax objectAtIndex:0] objectAtIndex:0] doubleValue], 
                                                                [[[arrayDTWDistanceMinAvgMax objectAtIndex:0] objectAtIndex:2] doubleValue], 
                                                                [[[arrayDTWDistanceMinAvgMax objectAtIndex:1] objectAtIndex:0] doubleValue], 
                                                                [[[arrayDTWDistanceMinAvgMax objectAtIndex:1] objectAtIndex:2] doubleValue],
                                                                [[[arrayDTWDistanceMinAvgMax objectAtIndex:2] objectAtIndex:0] doubleValue], 
                                                                [[[arrayDTWDistanceMinAvgMax objectAtIndex:2] objectAtIndex:2] doubleValue]
                                                                ]
                                       ];
        
        
        for(int j=0; j< [arrayTemplateX count] ; j++){
			currentT = [(NSNumber*)[arrayTemplateT objectAtIndex:j] doubleValue];
			currentX = [(NSNumber*)[arrayTemplateX objectAtIndex:j] doubleValue];
			currentY = [(NSNumber*)[arrayTemplateY objectAtIndex:j] doubleValue];
			currentZ = [(NSNumber*)[arrayTemplateZ objectAtIndex:j] doubleValue];
			clusterNumber = [(NSNumber*)[arrayTemplateC objectAtIndex:j] intValue];
			stringDTWTemplate = [stringDTWTemplate stringByAppendingString:[NSString stringWithFormat:@"%g,%g,%g,%g,%d\n" , currentT, currentX, currentY, currentZ, clusterNumber]];
            
            currentX = [(NSNumber*)[[arrayUpperLimitAll objectAtIndex:0] objectAtIndex:j] doubleValue];
			currentY = [(NSNumber*)[[arrayUpperLimitAll objectAtIndex:1] objectAtIndex:j] doubleValue];
			currentZ = [(NSNumber*)[[arrayUpperLimitAll objectAtIndex:2] objectAtIndex:j] doubleValue];
			clusterNumber = [(NSNumber*)[[arrayUpperLimitAll objectAtIndex:3] objectAtIndex:j] doubleValue];
			stringUpperBound = [stringUpperBound stringByAppendingString:[NSString stringWithFormat:@"%g,%g,%g,%d\n" , currentX, currentY, currentZ, clusterNumber]];
            
            currentX = [(NSNumber*)[[arrayLowerLimitAll objectAtIndex:0] objectAtIndex:j] doubleValue];
			currentY = [(NSNumber*)[[arrayLowerLimitAll objectAtIndex:1] objectAtIndex:j] doubleValue];
			currentZ = [(NSNumber*)[[arrayLowerLimitAll objectAtIndex:2] objectAtIndex:j] doubleValue];
			clusterNumber = [(NSNumber*)[[arrayLowerLimitAll objectAtIndex:3] objectAtIndex:j] doubleValue];
			stringLowerBound = [stringLowerBound stringByAppendingString:[NSString stringWithFormat:@"%g,%g,%g,%d\n" , currentX, currentY, currentZ, clusterNumber]];
            
            stringWarpingWindowSizesForX = [stringWarpingWindowSizesForX stringByAppendingString:[NSString stringWithFormat:@"%g," ,[[[arrayWarpingWindowAll objectAtIndex:0]objectAtIndex:j] doubleValue]]];
            stringWarpingWindowSizesForY = [stringWarpingWindowSizesForY stringByAppendingString:[NSString stringWithFormat:@"%g," ,[[[arrayWarpingWindowAll objectAtIndex:1]objectAtIndex:j] doubleValue]]];
            stringWarpingWindowSizesForZ = [stringWarpingWindowSizesForZ stringByAppendingString:[NSString stringWithFormat:@"%g," ,[[[arrayWarpingWindowAll objectAtIndex:2]objectAtIndex:j] doubleValue]]];
		}
        stringWarpingWindowSizesForX = [stringWarpingWindowSizesForX stringByAppendingString:@"\n"];
        stringWarpingWindowSizesForY = [stringWarpingWindowSizesForY stringByAppendingString:@"\n"];
        stringWarpingWindowSizesForZ = [stringWarpingWindowSizesForZ stringByAppendingString:@"\n"];
        NSError* error;
        [stringDTWTemplate writeToFile:[directoryToSave stringByAppendingFormat:@"TEMPLATE_%d.txt",i+1] atomically:YES encoding:NSUTF8StringEncoding error:&error];
        [stringUpperBound writeToFile:[directoryToSave stringByAppendingFormat:@"UPPER_%d.txt",i+1] atomically:YES encoding:NSUTF8StringEncoding error:&error];
        [stringLowerBound writeToFile:[directoryToSave stringByAppendingFormat:@"LOWER_%d.txt",i+1] atomically:YES encoding:NSUTF8StringEncoding error:&error];
        [stringDTWDistanceMinAvgMax writeToFile:[directoryToSave stringByAppendingString:@"DTWALLDISTANCE.txt"] atomically:YES encoding:NSUTF8StringEncoding error:&error];
        [stringWarpingWindowSizesForX writeToFile:[directoryToSave stringByAppendingString:@"WARPINGSIZE_X.txt"] atomically:YES encoding:NSUTF8StringEncoding error:&error];
        [stringWarpingWindowSizesForY writeToFile:[directoryToSave stringByAppendingString:@"WARPINGSIZE_Y.txt"] atomically:YES encoding:NSUTF8StringEncoding error:&error];
        [stringWarpingWindowSizesForZ writeToFile:[directoryToSave stringByAppendingString:@"WARPINGSIZE_Z.txt"] atomically:YES encoding:NSUTF8StringEncoding error:&error];
    }
}


+(int)getClassificationResult:(GestureData*)currentGestureData{
    int returnValue = -1;
    [NoiseEliminator eliminateNoiseFromGestureData:currentGestureData];
    if ([currentGestureData.gestureData objectAtIndex:0] && [[currentGestureData.gestureData objectAtIndex:0] count] > 0) {
        [Filter filterGestureData:currentGestureData]; //Filter is selected by the parameter and values determines from it
        [Sampler sampleGestureData:currentGestureData]; //Sample is selected by the parameter and values determines from it
        [Cluster clusterGestureData:currentGestureData];
        
        int classifierType = (int)[ConfigurationManager getParameterValue:KPN_CLASSIFIER_TYPE];
        
        if (classifierType == ClassifierTypeDTW) {
             returnValue = [Classifier classifyGestureDataWithDTW:currentGestureData]+1;
        }else{
             returnValue = [Classifier classifyGestureData:currentGestureData]+1;
        }
       
    }
    else{ // Now, the gesture data is empty !!! 
        returnValue = -1;
    }
    return returnValue;
}

-(id)init{
    self=[super init];
	if (self) {
		parameterList = [[NSMutableArray alloc]init];
		bestParameterList = [[NSMutableArray alloc]init];
        configurationList = [[NSMutableDictionary alloc]init];
        bestConfusionMatrix = nil;
	}
	return self;
}

-(double)getParameterValue:(NSString*)parameterName{
	double returnValue= 0.0;
	for(Parameter* parameterItem in parameterList){
		if([parameterItem.name isEqualToString:parameterName]){
			returnValue = parameterItem.value;
			break;
		}
	}
	return returnValue;
}

-(BOOL)getParameterBOOLValue:(NSString*)parameterName{
	BOOL returnValue= YES;
	for(Parameter* parameterItem in parameterList){
		if([parameterItem.name isEqualToString:parameterName]){
			if (parameterItem.value <= 0.0) {
				returnValue = NO;
			}
			else {
				returnValue = YES;
			}
			break;
		}
	}
	return returnValue;
	
}

-(Parameter*)getParameter:(NSString*)parameterName{
	Parameter* returnObject= nil;
	for(Parameter* parameterItem in parameterList){
		if([parameterItem.name isEqualToString:parameterName]){
			returnObject =parameterItem;
			break;
		}
	}
	return returnObject;
}

-(void)addParameter:(Parameter*)parameter{
	if (!parameterList) {
		parameterList = [[NSMutableArray alloc]init];
	}
	Parameter* sameParameter = [self getParameter:parameter.name];
	if (sameParameter) {
		[sameParameter updateWithParameter:parameter];
	}
	else {
		[parameterList addObject:parameter];
	}
}

-(void)addParameterWithDetail:(NSString*)parameterName 
					 andValue:(double)value 
	  andNumberOfItemsInRange:(int)numberOfItemsInRange 
				  andRangeMin:(double)rangeMin 
				  andRangeMax:(double)rangeMax 
		 andIsIncludeMinRange:(BOOL)isIncludeMinRange 
		 andIsIncludeMaxRange:(BOOL)isIncludeMaxRange{
		
	Parameter* newParameter = [[Parameter alloc]initWithParameterDetail:parameterName andValue:value andNumberOfItemsInRange:numberOfItemsInRange andRangeMin:rangeMin andRangeMax:rangeMax andIsIncludeMinRange:isIncludeMinRange andIsIncludeMaxRange:isIncludeMaxRange];
	[self addParameter:newParameter];
}

-(int)numberOfAllParameterOptions{
	int returnValue = 1;
	for(Parameter* parameter in parameterList){
		returnValue = returnValue * [parameter numberOfAllOptions];
	}
	return returnValue;
}

-(void)initializeConfigurationList{
	if (configurationList) {
        [configurationList removeAllObjects];
    }
    else{
        //do nothing
    }

}

-(void)initialAllParameterValuesAsFirstPossibleValue{
	for(Parameter* parameter in parameterList){
		[parameter initialValueAsFirstPossibleValue];
	}
}

-(void)makeAllParametersUnused{
	for(Parameter* parameter in parameterList){
		parameter.isUsedParameters = NO;
	}
}


-(BOOL)setParameterValue:(NSString*)parameterName andNewValue:(double)newValue{
	BOOL returnValue = NO;
	Parameter* sameParameter = [self getParameter:parameterName];
	if (sameParameter) {
		sameParameter.value = newValue;
		returnValue = YES;
	}
	else {
		returnValue = NO;
	}
	return returnValue;
}

-(BOOL)setNextPossibleParameterValue{
	return [self setNextPossibleParameterValue:0];
}

//when it return NO -> it means the method reach the top most value for each parameter and initialize all of them
-(BOOL)setNextPossibleParameterValue:(int)parameterIndex{
	BOOL returnValue = NO;
	if (parameterList && [parameterList count]>parameterIndex) {
		Parameter* parameter = [parameterList objectAtIndex:parameterIndex];
		if (parameter.isUsedParameters) {
			returnValue = [parameter setNextPossibleValue];
			if (!returnValue) {			//it the parameter value reach the top most value, we can set to the next
				// then increment the next parameter, and initialize the current one
				returnValue = [self setNextPossibleParameterValue:parameterIndex+1];
				[parameter initialValueAsFirstPossibleValue];
			}
		}
		else {
			//if parameter is not used in the first run then we are not going to increment it! 
			returnValue = [self setNextPossibleParameterValue:parameterIndex+1];
		}

	}
	return returnValue;
}

-(NSString*)getCurrentParameterConfigurationString{
	NSString* returnValue = @"";
	for(Parameter* parameter in parameterList){
		//NSLog(@"paremeter - ", [parameter getParameterString]);
		if (parameter.isUsedParameters) {
			returnValue = [returnValue stringByAppendingFormat:@"%@ \n",[parameter getParameterString]];
		}
		
	}
	return returnValue;
}
-(NSString*)getBestParameterConfigurationString{
	NSString* returnValue = @"";
	for(Parameter* parameter in bestParameterList){
		//NSLog(@"paremeter - ", [parameter getParameterString]);
		if (parameter.isUsedParameters) {
			returnValue = [returnValue stringByAppendingFormat:@"%@ \n",[parameter getParameterString]];
		}
		
	}
	return returnValue;
}

-(ConfusionMatrix*)getBestConfusionMatrix{
    return bestConfusionMatrix;
}

-(void)saveParameterIfBetterResult:(ConfusionMatrix*)classificationResult{
	if (bestConfusionMatrix == nil || [bestConfusionMatrix getRecallOfAll] > [classificationResult getRecallOfAll]) {
		bestConfusionMatrix = classificationResult;
        [bestParameterList removeAllObjects];
		for(Parameter* parameter in parameterList){
			[bestParameterList addObject:[[Parameter alloc]
										  initWithParameterDetail:parameter.name 
										  andValue:parameter.value 
										  andNumberOfItemsInRange:parameter.numberOfItemsInRange 
										  andRangeMin:parameter.rangeMin 
										  andRangeMax:parameter.rangeMax 
										  andIsIncludeMinRange:parameter.isIncludeMinRange 
										  andIsIncludeMaxRange:parameter.isIncludeMaxRange]];
		}
	}
}

-(void)addConfiguration:(NSDictionary*)configurationDictionary andName:(NSString*)nameOfConfiguration{
    if (configurationList) {
        [configurationList setObject:configurationDictionary forKey:nameOfConfiguration];
    }
    else{
        //do nothing
    }
}
-(void)addConfigurationValue:(id)configurationValue andName:(NSString*)nameOfConfiguration{
    if (configurationList) {
        [configurationList setObject:configurationValue forKey:nameOfConfiguration];
    }
    else{
        //do nothing
    }
}
-(NSDictionary*)getConfiguration:(NSString*)nameOfConfiguration{
    NSDictionary* returningConfiguration = nil;
    if (configurationList) {
        returningConfiguration = [configurationList objectForKey:nameOfConfiguration];
    }
    else{
        //do nothing
    }
    return returningConfiguration;
}
-(id)getConfigurationValue:(NSString*)nameOfConfiguration{
    return [configurationList objectForKey:nameOfConfiguration];
}

//-(void)saveConfigurationList:(NSString*)fullPath{
//    if (configurationList) {
//        [configurationList writeToFile:fullPath atomically:YES];
//    }
//    else{
//        //do nothing
//    }
//}

-(void)saveConfigurationList:(NSString*)configurationName{
    NSString *pathForFile = nil ;
    if (configurationName == nil || [configurationName isEqualToString:@""]) {
        pathForFile =[[self getDocumentsDirectory] stringByAppendingString:@"/configurationGR.plist"] ;
    }
    else{
        pathForFile =[[self getDocumentsDirectory] stringByAppendingFormat:@"/%@.plist", configurationName] ;
    }
    
    if (configurationList) {
        [configurationList writeToFile:pathForFile atomically:YES];
    }
    else{
        //do nothing
    }
    //[self saveConfigurationList:pathForFile];
}

-(NSString*) getDocumentsDirectory{  
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);  
    return [paths objectAtIndex:0];  
}

//-(void)loadConfigurationList:(NSString*)fullPath{
//    if (configurationList) {
//        [configurationList removeAllObjects];
//        configurationList = [[NSMutableDictionary alloc]initWithContentsOfFile:fullPath];
//    }
//    else{
//        //do nothing
//    }
//}
-(void)loadConfigurationList:(NSString*)configurationName{
    NSString *pathForFile = nil;
    if (configurationName==nil || [configurationName isEqualToString:@""]) {
        pathForFile =  [[self getDocumentsDirectory] stringByAppendingString:@"/configurationGR.plist"] ;
    }
    else{
        pathForFile =  [[self getDocumentsDirectory] stringByAppendingFormat:@"/%@.plist", configurationName] ;
    }
    
    if (configurationList) {
        [configurationList removeAllObjects];
        configurationList = [[NSMutableDictionary alloc]initWithContentsOfFile:pathForFile];
    }
    else{
        //do nothing
    }
    
   // [self loadConfigurationList:pathForFile];
}

-(void) dealloc{
	[parameterList release];
	[bestParameterList release];
	[super dealloc];
}

@end
