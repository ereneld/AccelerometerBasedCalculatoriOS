//
//  GestureData.m
//  GestureData
//
//  Created by dogukan erenel on 4/11/10.
//  Copyright 2010 Bogazici University. All rights reserved.
//

#import "GestureData.h"
#import "ConfigurationManager.h"
#import "Constants.h"

@implementation GestureData

@synthesize gestureData, gestureFullPath, gestureTitle, gestureImageNumber, gestureClassNumberActual, gestureClassNumberPredicted, isForTraining;
@synthesize personAge, personSex, personHandUsage, personCurrentHand,	personDisability, personJob, personEducation, gestureDate;

@synthesize gestureNumber, gestureMainType, gestureMovementType, variance;

-(double*)getNewDoubleArray:(int)firstDimension{
	
	double* returnArray;
	if ((returnArray = malloc(firstDimension * sizeof(double))) == NULL)
	{
		fprintf(stderr,"Memory allocation error (returnArray 1)\n");
	}
	else {
		for(int i=0; i < firstDimension; i++){
			returnArray[i] = 0.0;
		}
	}
	return returnArray;
}

-(void)prepareGestureDataInfo{
    variance = [self getNewDoubleArray:4];
    mean = [self getNewDoubleArray:4];
    length = 0.0;
    
    // Calculating the mean points
    NSArray* dataArray = gestureData;
    if (dataArray!= nil &&  [dataArray count]>0 && [(NSMutableArray*)[dataArray objectAtIndex:0] count] > 0) {
        NSMutableArray* timeArray = [dataArray objectAtIndex:0];
        NSMutableArray* xArray = [dataArray objectAtIndex:1];
        NSMutableArray* yArray = [dataArray objectAtIndex:2];
        NSMutableArray* zArray = [dataArray objectAtIndex:3];
        NSMutableArray* clusterArray = [dataArray objectAtIndex:4];
        
        for(int j=0; j<[timeArray count]; j++) {    // the length of observations
            // we are taking the average of x, y, z, cluster values to make a template....
            mean[0] += [[xArray objectAtIndex:j]doubleValue] / [timeArray count];
            mean[1] += [[yArray objectAtIndex:j]doubleValue] / [timeArray count];
            mean[2] += [[zArray objectAtIndex:j]doubleValue] / [timeArray count];
            mean[3] += [[clusterArray objectAtIndex:j]doubleValue] / [timeArray count];
        }
        length = [[timeArray lastObject]doubleValue];
        
        for(int j=0; j<[timeArray count]; j++) {    // the length of observations
            // we are taking the average of x, y, z, cluster values to make a template....
            variance[0] += pow([[xArray objectAtIndex:j]doubleValue] - mean[0], 2) / [timeArray count] ; // X variance
            variance[1] += pow([[yArray objectAtIndex:j]doubleValue] - mean[1], 2) / [timeArray count]; // Y variance
            variance[2] += pow([[zArray objectAtIndex:j]doubleValue] - mean[2], 2) / [timeArray count]; // Z variance
            variance[3] += pow([[clusterArray objectAtIndex:j]doubleValue] - mean[3], 2) / [timeArray count]; // Amplitute variance
            
        }
    } 
   
}

-(id)initWithDictionary:(NSDictionary*)plistDictionary{
	self=[super init];
	if (self) {
		self.gestureFullPath = [plistDictionary objectForKey:KDS_GESTUREDATA_PATH];
		self.gestureTitle = [plistDictionary objectForKey:KDS_GESTUREDATA_TITLE];
		self.gestureImageNumber =  [[plistDictionary objectForKey:KDS_GESTUREDATA_IMAGENUMBER] intValue];
		self.gestureClassNumberActual = 0;
		self.gestureClassNumberPredicted = 0;	
		self.isForTraining = NO;
		
		self.personAge =  [[plistDictionary objectForKey:KDS_GESTUREDATA_AGE]intValue];
		self.personSex =  [plistDictionary objectForKey:KDS_GESTUREDATA_SEX];
		self.personHandUsage =  [plistDictionary objectForKey:KDS_GESTUREDATA_HAND];
        self.personCurrentHand = [plistDictionary objectForKey:KDS_GESTUREDATA_CURRENT_HAND];
		self.personDisability = [[plistDictionary objectForKey:KDS_GESTUREDATA_DISABILITY]boolValue];
		self.personJob =  [[plistDictionary objectForKey:KDS_GESTUREDATA_JOBTYPE]intValue];
		self.personEducation =  [[plistDictionary objectForKey:KDS_GESTUREDATA_EDUCATIONTYPE]intValue];
		self.gestureDate = [plistDictionary objectForKey:KDS_GESTUREDATA_DATE];
		
		self.gestureData = [[NSArray alloc]initWithArray:[plistDictionary objectForKey:KDS_GESTUREDATA_DATA]];
        
        [self prepareGestureDataInfo];
	}
	return self;
}

-(id)initWithPath:(NSString*)fullPathString{
    self=[super init];
	if (self) {
		NSDictionary* gestureDictionary = [[NSDictionary alloc]initWithContentsOfFile:fullPathString];
		if ([gestureDictionary objectForKey:KDS_GESTUREDATA_TITLE]) {
			//New data is gathering from datainside
			self.gestureFullPath = fullPathString;
            
            //NSRange tempRange = [fullPathString rangeOfString:@"/" options:NSBackwardsSearch];
			//NSString* gestureTitleString = [[fullPathString substringFromIndex:tempRange.location + 1] stringByReplacingOccurrencesOfString:@".plist" withString:@""];
            
			self.gestureTitle = [gestureDictionary objectForKey:KDS_GESTUREDATA_TITLE];
			self.gestureImageNumber =  [[gestureDictionary objectForKey:KDS_GESTUREDATA_IMAGENUMBER] intValue];
			
			self.personAge =  [[gestureDictionary objectForKey:KDS_GESTUREDATA_AGE]intValue];
			self.personSex =  [gestureDictionary objectForKey:KDS_GESTUREDATA_SEX];
			self.personHandUsage =  [gestureDictionary objectForKey:KDS_GESTUREDATA_HAND];
            self.personCurrentHand = [gestureDictionary objectForKey:KDS_GESTUREDATA_CURRENT_HAND];
			self.personDisability = [[gestureDictionary objectForKey:KDS_GESTUREDATA_DISABILITY]boolValue];
			self.personJob =  [[gestureDictionary objectForKey:KDS_GESTUREDATA_JOBTYPE]intValue];
			self.personEducation =  [[gestureDictionary objectForKey:KDS_GESTUREDATA_EDUCATIONTYPE]intValue];
			self.gestureDate = [gestureDictionary objectForKey:KDS_GESTUREDATA_DATE];
			
			self.gestureData = [[NSArray alloc]initWithArray:[gestureDictionary objectForKey:KDS_GESTUREDATA_DATA]];
		}
		else { 
			//Old data is gathering just from path
			// GESTURENAME_AGE_SEX_DISABILITY_EDUCATION_JOB (exp: A2_22_M_Y_2_01 )
			// GESTURENAME_AGE_SEX_HANDUSAGE_DISABILITY_EDUCATION_JOB (exp: A2_22_M_Y_2_01 )
			NSRange tempRange = [fullPathString rangeOfString:@"/" options:NSBackwardsSearch];
			NSString* gestureTitleString = [[fullPathString substringFromIndex:tempRange.location + 1] stringByReplacingOccurrencesOfString:@".plist" withString:@""];
			NSArray* gestureDetailStringArray = [gestureTitleString componentsSeparatedByString:@"_"];
			
			self.gestureFullPath = fullPathString;
			self.gestureTitle = gestureTitleString;
			self.gestureImageNumber = [[gestureDetailStringArray objectAtIndex:0] intValue];
			
			self.personAge = [[gestureDetailStringArray objectAtIndex:1] intValue];
			self.personSex = [gestureDetailStringArray objectAtIndex:2];
			
			int isHandIncluded = 0;
			if ([gestureDetailStringArray count]==8) {
				isHandIncluded = 1;
				self.personHandUsage =  [gestureDetailStringArray objectAtIndex:3];
			}
			else {
				isHandIncluded = 0;
				self.personHandUsage =  K_DEFAULT_HAND;
			}
            self.personCurrentHand = self.personHandUsage;
            
			if ([[gestureDetailStringArray objectAtIndex:3 + isHandIncluded] isEqualToString:@"N"]) {
				self.personDisability = NO;
			}
			else {
				self.personDisability = YES;
			}
			
			self.personJob =  [[gestureDetailStringArray objectAtIndex:4 + isHandIncluded] intValue];
			self.personEducation =  [[gestureDetailStringArray objectAtIndex:5 + isHandIncluded] intValue];
			
			NSMutableArray* existingGestureData = [[NSMutableArray alloc]initWithContentsOfFile:fullPathString];
			if ([existingGestureData count]==4) {  //t x y z
				[existingGestureData addObject:[[NSMutableArray alloc] init]];
				NSArray* timeArray = [existingGestureData objectAtIndex:0];
				for (int i = 0 ; i< [timeArray count];i++) {
					[(NSMutableArray*)[existingGestureData objectAtIndex:4] addObject: [NSNumber numberWithInt:0]];
				}
				//t x y z clusterNumber -> now
			}
			else if([existingGestureData count]==5){ //t x y z W but should be t x y z clusterNumber= 0 (initially)
				NSArray* timeArray = [existingGestureData objectAtIndex:0];
				for (int i = 0 ; i< [timeArray count];i++) {
					[(NSMutableArray*)[existingGestureData objectAtIndex:4] replaceObjectAtIndex:i withObject:[[NSNumber alloc] initWithInt:0]];
				}
			}
			self.gestureData = existingGestureData;
			self.gestureDate = [NSDate date];
		}

		self.gestureClassNumberActual = 0;
		self.gestureClassNumberPredicted = 0;	
		self.isForTraining = NO;
		
        [self prepareGestureDataInfo];
	}
	return self;
}

-(NSDictionary*)getDictionaryFileOfGestureData{
	NSDictionary* dictionaryFile = [[[NSDictionary alloc]
									initWithObjects: [[NSArray alloc]initWithObjects:
													  gestureTitle,
													  [NSNumber numberWithInt:gestureImageNumber],
													  [NSNumber numberWithInt:gestureClassNumberActual],
													  [NSNumber numberWithInt:gestureClassNumberPredicted],
													  [NSNumber numberWithBool:isForTraining],
													  [NSNumber numberWithInt:personAge],
													  personSex,
													  personHandUsage,
													  [NSNumber numberWithBool:personDisability],
													  [NSNumber numberWithInt:personJob],
													  [NSNumber numberWithInt:personEducation],
													  gestureDate,
													  gestureData,  
													  nil] 
									forKeys:[[NSArray alloc]initWithObjects:
											 KDS_GESTUREDATA_TITLE, 
											 KDS_GESTUREDATA_IMAGENUMBER,
											 KDS_GESTUREDATA_ACTUALCLASS,
											 KDS_GESTUREDATA_PREDICTEDCLASS,
											 KDS_GESTUREDATA_USEDFORTRAINING,
											 KDS_GESTUREDATA_AGE,
											 KDS_GESTUREDATA_SEX,
											 KDS_GESTUREDATA_HAND,
											 KDS_GESTUREDATA_DISABILITY,
											 KDS_GESTUREDATA_JOBTYPE,
											 KDS_GESTUREDATA_EDUCATIONTYPE,
											 KDS_GESTUREDATA_DATE,
											 KDS_GESTUREDATA_DATA,
											 nil]] autorelease];	
	
	return dictionaryFile;
}
/*

-(bool)resetDataSetFromGivenPath:(NSString*)pathOfGestureData{
	
	NSArray *dirContents = [[NSFileManager defaultManager] directoryContentsAtPath:pathOfGestureData];
	NSArray *onlyPlists = [dirContents filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self ENDSWITH '.plist'"]];
	onlyPlists = [onlyPlists sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
	
	for(NSString * plistName in onlyPlists) {
		
		GestureData* gestureDataCaptured = [[GestureData alloc]init];
		gestureDataCaptured.gestureNumber = gestureNumber;
		gestureDataCaptured.isForTraining = NO;
		gestureDataCaptured.gestureTitle = [plistName stringByReplacingOccurrencesOfString:@".plist" withString:@""];
		gestureDataCaptured.gestureFullPath = fullPathOfPlist;
		
		NSString* fullPathOfPlist = [[[self getDataSetDirectory] stringByAppendingString:@"/"] stringByAppendingString:plistName];
		NSMutableArray* existingGestureData = [[NSMutableArray alloc]initWithContentsOfFile:fullPathOfPlist];
		if ([existingGestureData count]==4) {  //t x y z
			[existingGestureData addObject:[[NSMutableArray alloc] init]];
			NSArray* timeArray = [existingGestureData objectAtIndex:0];
			for (int i = 0 ; i< [timeArray count];i++) {
				[(NSMutableArray*)[existingGestureData objectAtIndex:4] addObject: [NSNumber numberWithInt:0]];
			}
			//t x y z clusterNumber -> now
		}
		else if([existingGestureData count]==5){ //t x y z W but should be t x y z clusterNumber= 0 (initially)
			NSArray* timeArray = [existingGestureData objectAtIndex:0];
			for (int i = 0 ; i< [timeArray count];i++) {
				[(NSMutableArray*)[existingGestureData objectAtIndex:4] replaceObjectAtIndex:i withObject:[[NSNumber alloc] initWithInt:0]];
			}
		}
		gestureDataCaptured.gestureData = existingGestureData;
		
		[gestureDataArray addObject:gestureDataCaptured];
	}
	
	
	
	
	for(NSString * plistName in onlyPlists) {
		countMainGestureDataArray[gestureNumber - 1] = countMainGestureDataArray[gestureNumber - 1] + 1;
		countEachGestureDataArray[i] = countEachGestureDataArray[i] + 1;
		
		NSLog(@"Plist Name : %@", plistName);
		NSString* fullPathOfPlist = [[[self getDataSetDirectory] stringByAppendingString:@"/"] stringByAppendingString:plistName];
		if ([[NSFileManager defaultManager] fileExistsAtPath:fullPathOfPlist]) {
			GestureData* gestureDataCaptured = [[GestureData alloc]init];
			gestureDataCaptured.gestureMovementType = gestureMovementType;
			gestureDataCaptured.gestureMainType = gestureType;
			gestureDataCaptured.gestureNumber = gestureNumber;
			NSMutableArray* existingGestureData = [[NSMutableArray alloc]initWithContentsOfFile:fullPathOfPlist];
			if ([existingGestureData count]==4) {  //t x y z
				[existingGestureData addObject:[[NSMutableArray alloc] init]];
				NSArray* timeArray = [existingGestureData objectAtIndex:0];
				for (int i = 0 ; i< [timeArray count];i++) {
					[(NSMutableArray*)[existingGestureData objectAtIndex:4] addObject: [NSNumber numberWithInt:0]];
				}
				//t x y z clusterNumber -> now
			}
			else if([existingGestureData count]==5){ //t x y z W but should be t x y z clusterNumber= 0 (initially)
				NSArray* timeArray = [existingGestureData objectAtIndex:0];
				for (int i = 0 ; i< [timeArray count];i++) {
					[(NSMutableArray*)[existingGestureData objectAtIndex:4] replaceObjectAtIndex:i withObject:[[NSNumber alloc] initWithInt:0]];
				}
			}
			
			gestureDataCaptured.isForTraining = NO;
			gestureDataCaptured.gestureData = existingGestureData;
			gestureDataCaptured.gestureTitle = [plistName stringByReplacingOccurrencesOfString:@".plist" withString:@""];
			gestureDataCaptured.gestureFullPath = fullPathOfPlist;
			[arrayForAllRawDataCaptured addObject:gestureDataCaptured];
		}
	}
	
}
returnArray = [NSArray arrayWithArray:arrayForAllRawDataCaptured];
[arrayForAllRawDataCaptured release];
return returnArray;
}
*/


-(bool) isGestureFilled{
	return ([(NSMutableArray*)[gestureData objectAtIndex:0] count]!=0);
}

-(NSString*)getDataStringForMatlab{
	NSString* returnValue=@"";
	double currentT = 0.0, currentX = 0.0, currentY=0.0, currentZ=0.0;
	int clusterNumber=0;
	if (gestureData!= nil &&  [gestureData count]>0 && [(NSMutableArray*)[gestureData objectAtIndex:0] count]>0) {
		for(int j=0; j< [(NSMutableArray*)[gestureData objectAtIndex:0] count] ; j++){
			currentT = [(NSNumber*)[(NSMutableArray*)[gestureData objectAtIndex:0] objectAtIndex:j] doubleValue];
			currentX = [(NSNumber*)[(NSMutableArray*)[gestureData objectAtIndex:1] objectAtIndex:j] doubleValue];
			currentY = [(NSNumber*)[(NSMutableArray*)[gestureData objectAtIndex:2] objectAtIndex:j] doubleValue];
			currentZ = [(NSNumber*)[(NSMutableArray*)[gestureData objectAtIndex:3] objectAtIndex:j] doubleValue];
			clusterNumber = [(NSNumber*)[(NSMutableArray*)[gestureData objectAtIndex:4] objectAtIndex:j] intValue];
			returnValue = [returnValue stringByAppendingString:[NSString stringWithFormat:@"%g,%g,%g,%g,%d\n" , currentT, currentX, currentY, currentZ, clusterNumber]];
		}
	}
	return returnValue;
}

-(NSString*)getGestureDataInfoString{
	NSString* returnValue = [NSString stringWithFormat:@"Length :%g \n", length];
    double varianceTotal = variance[0] + variance[1] + variance[2];
    double factorVariance = 1 / varianceTotal;
    
    for (int i=0; i<4; i++) {
        returnValue = [returnValue stringByAppendingFormat:@"  Dimension: %d, Variance: %g (unit variance: %g), Mean: %g \n",i, variance[i],factorVariance*variance[i], mean[i]];
    }
    return returnValue;
}

-(BOOL)saveDataSetToPath:(NSString*)pathToSaveGestureData andSavingMethod:(kGestureDataSavingType)gestureDataSavingType{
	BOOL returnValue = NO;
	
	switch (gestureDataSavingType) {
		case kGestureDataSavingTypeText:
			returnValue = [self saveAsText:pathToSaveGestureData];
			break;
		case kGestureDataSavingTypeMatlab:
			returnValue = [self saveAsMatlab:pathToSaveGestureData];
			break;
		case kGestureDataSavingTypePlist:
			returnValue = [self saveAsPlist:pathToSaveGestureData];
			break;
		default:
			break;
	}
	return returnValue;
}

-(BOOL)saveAsText:(NSString*)pathToSaveGestureData{
	//TODO: save as text
	BOOL returnValue = NO;
	returnValue = [[self getDataStringForMatlab]writeToFile:pathToSaveGestureData atomically:YES];
	return returnValue;
}

-(BOOL)saveAsMatlab:(NSString*)pathToSaveGestureData{
	//TODO: save as matlab file
	BOOL returnValue = NO;
	return returnValue;
}

-(BOOL)saveAsPlist:(NSString*)pathToSaveGestureData{
	//TODO: save as pList file
	BOOL returnValue = NO;
	return returnValue;
}


/*
-(NSString*)getClustersequenceStringForMatlab{
	NSString* returnValue=@"";
	int clusterNumber=0;
	int samplesequenceLength= [[ConfigurationManager getParameterValue:KDS_SAMPLE_LENGTH] intValue];
	if (gestureData!= nil &&  [gestureData count]>0 && [(NSMutableArray*)[gestureData objectAtIndex:0] count] >= samplesequenceLength ) {
		int sequenceLength = [(NSMutableArray*)[gestureData objectAtIndex:0] count];
		for(float i=0; i< samplesequenceLength; i++){
			clusterNumber = [(NSNumber*)[(NSMutableArray*)[gestureData objectAtIndex:4] objectAtIndex:(i * ((float)sequenceLength / samplesequenceLength)) ] intValue];
			if (i==0) {
				returnValue = [returnValue stringByAppendingString:[NSString stringWithFormat:@"%d" , clusterNumber]];
			}
			else {
				returnValue = [returnValue stringByAppendingString:[NSString stringWithFormat:@",%d" , clusterNumber]];
			}
		}
	}
	return returnValue;
}
*/

-(void) dealloc{
	[gestureData release];
	[gestureFullPath release];
	[gestureTitle release];
	[personSex release];
	[personHandUsage release];
	[super dealloc];
}
/*
-(NSString*)getStatementIntString{
	NSString* returnValue=@"";
	int currentStateX = 0, currentStateY=0, currentStateZ=0;
	NSMutableArray* tempStateIntArray = gestureStateData_int;
	if (tempStateIntArray!= nil &&  [tempStateIntArray count]>0 && [(NSMutableArray*)[tempStateIntArray objectAtIndex:0] count]>0) {
		for(int j=0; j< [(NSMutableArray*)[tempStateIntArray objectAtIndex:0] count] ; j++){
			currentStateX = [(NSNumber*)[(NSMutableArray*)[tempStateIntArray objectAtIndex:0] objectAtIndex:j] intValue];
			currentStateY = [(NSNumber*)[(NSMutableArray*)[tempStateIntArray objectAtIndex:1] objectAtIndex:j] intValue];
			currentStateZ = [(NSNumber*)[(NSMutableArray*)[tempStateIntArray objectAtIndex:2] objectAtIndex:j] intValue];
			returnValue = [returnValue stringByAppendingString:[NSString stringWithFormat:@"%d,%d,%d,%d\n",j , currentStateX, currentStateY, currentStateZ]];
		}
	}
	return returnValue;
}
*/
/*

-(NSString*)getStatementIntString{
	NSString* returnValue=@"";
	int currentStateX = 0, currentStateY=0, currentStateZ=0;
	NSMutableArray* tempStateIntArray = gestureStateData_int;
	if (tempStateIntArray!= nil &&  [tempStateIntArray count]>0 && [(NSMutableArray*)[tempStateIntArray objectAtIndex:0] count]>0) {
		returnValue = [returnValue stringByAppendingString:@"X: "];
		for(int j=0; j< [(NSMutableArray*)[tempStateIntArray objectAtIndex:0] count] ; j++){
			currentStateX = [(NSNumber*)[(NSMutableArray*)[tempStateIntArray objectAtIndex:0] objectAtIndex:j] intValue];
			returnValue = [returnValue stringByAppendingString:[NSString stringWithFormat:@"%d, \t" , currentStateX]];
		}
		returnValue = [returnValue stringByAppendingString:@" \n"];
		
		returnValue = [returnValue stringByAppendingString:@"Y: "];
		for(int j=0; j< [(NSMutableArray*)[tempStateIntArray objectAtIndex:1] count] ; j++){
			currentStateY = [(NSNumber*)[(NSMutableArray*)[tempStateIntArray objectAtIndex:1] objectAtIndex:j] intValue];
			returnValue = [returnValue stringByAppendingString:[NSString stringWithFormat:@"%d, \t" , currentStateY]];
		}
		returnValue = [returnValue stringByAppendingString:@" \n"];
		
		returnValue = [returnValue stringByAppendingString:@"Z: "];
		for(int j=0; j< [(NSMutableArray*)[tempStateIntArray objectAtIndex:2] count] ; j++){
			currentStateZ = [(NSNumber*)[(NSMutableArray*)[tempStateIntArray objectAtIndex:2] objectAtIndex:j] intValue];
			returnValue = [returnValue stringByAppendingString:[NSString stringWithFormat:@"%d, \t" , currentStateZ]];
		}
		returnValue = [returnValue stringByAppendingString:@" \n"];
		
	}
	return returnValue;
}
*/

@end
