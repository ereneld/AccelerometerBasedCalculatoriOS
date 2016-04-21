//
//  DataSet.m
//  GestureRecognition
//
//  Created by dogukan ibrahimoglu on 1/2/11.
//  Copyright 2011 Bogazici University. All rights reserved.
//

#import "DataSet.h"
#import "GestureData.h"
#import "Constants.h"

//#import "mat.h"

@implementation DataSet

@synthesize gestureDataArray, gestureDataArrayAllWithoutClass, operationsequenceArray, sequenceDataArray, trainingDataArray, validationDataArray, totalNumberOfGestureData;

-(id)initWithGestureDataPath:(NSString*)pathOfGestureData{
	if (self = [super init]){
		gestureDataArray = [[NSMutableArray alloc]init];
        gestureDataArrayAllWithoutClass= [[NSMutableArray alloc]init];
		operationsequenceArray = [[NSMutableArray alloc]init];
		
		NSArray *dirContents = [[NSFileManager defaultManager] directoryContentsAtPath:pathOfGestureData];
		NSArray *onlyPlists = [dirContents filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self ENDSWITH '.plist'"]];
		onlyPlists = [onlyPlists sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
		
		//Reverse addition -> because we get the elements from the end and classify it according to image number
		for (int i= [onlyPlists count] - 1; i >= 0; i--) {
			NSString* fullPathOfPlist = [pathOfGestureData stringByAppendingString:[onlyPlists objectAtIndex:i]];
			GestureData* gestureDataCaptured = [[GestureData alloc]initWithPath:fullPathOfPlist];
			if ([gestureDataCaptured isGestureFilled]) {
				[gestureDataArray addObject:gestureDataCaptured];
			}
		}
	
		[operationsequenceArray addObject:K_OPERATION_RAW];
		[self setupDataSetAccordingToClassNumber];
		[self setDataSetAnalytics];
	}
	return self;
}

-(id)initWithDateSetPath:(NSString*)pathOfDataSet{
	if (self = [super init]){
		gestureDataArray = [[NSMutableArray alloc]init];
        gestureDataArrayAllWithoutClass= [[NSMutableArray alloc]init];
		operationsequenceArray = [[NSMutableArray alloc]init];
		
		NSArray *dirContents = [[NSFileManager defaultManager] directoryContentsAtPath:pathOfDataSet];
		NSArray *onlyPlists = [dirContents filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"(self BEGINSWITH 'GESTURE_DATASET') AND (self ENDSWITH '.plist')"]];
		onlyPlists = [onlyPlists sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
		if ([onlyPlists count] > 0) {
			NSString* fullPathOfPlist = [pathOfDataSet stringByAppendingString:[onlyPlists objectAtIndex:0]];
			NSDictionary* dataSetDictionary = [[NSDictionary alloc]initWithContentsOfFile:fullPathOfPlist];
			//[dataSetDictionary setValue:fullPathOfPlist forKey:KDS_GESTUREDATA_PATH];
			NSArray* tempGestureDataArray = [dataSetDictionary objectForKey:@""];
			for(NSDictionary* tempGestureDictionary in tempGestureDataArray){
				GestureData* gestureDataCaptured= [[GestureData alloc]initWithDictionary:tempGestureDictionary];
				[gestureDataArray addObject:gestureDataCaptured];
			}
			
		}
		else {
			//do nothing
		}
		[operationsequenceArray addObject:K_OPERATION_RAW];
		[self setupDataSetAccordingToClassNumber];
		[self setDataSetAnalytics];
	}
	return self;
}

-(void)setupDataSetAccordingToClassNumber{
	totalNumberOfGestureClass = [self getNumberOfClass];
	if ((arrayOfGestureClass = malloc(totalNumberOfGestureClass * sizeof(int))) == NULL)
	{
		fprintf(stderr,"Memory allocation error (arrayOfGestureClass 1)\n");
	}
	else {
		for(int i=0; i < totalNumberOfGestureClass; i++){
			arrayOfGestureClass[i] = -1;
		}
	}
	
	//The class arrays - others will be deleted
	for (int i=0; i<totalNumberOfGestureClass; i++) {
		[gestureDataArray insertObject:[[NSMutableArray alloc]init] atIndex:0];
	}
	
	while ([gestureDataArray count] > totalNumberOfGestureClass) {
		GestureData* tempGestureData = [gestureDataArray lastObject];
		int indexGestureDataInClassArray = [self indexGestureDataInClassArray:tempGestureData];
		if (indexGestureDataInClassArray >= 0) {	//Existing class data
			tempGestureData.gestureClassNumberActual = indexGestureDataInClassArray + 1;
			NSMutableArray* arrayExistingClass = [gestureDataArray objectAtIndex:indexGestureDataInClassArray];
			[arrayExistingClass addObject:tempGestureData]; //The sequence array
		}
		else {										//New class data
			int newClassNumber = [self getNextEmptyIndex];
			arrayOfGestureClass[newClassNumber] = tempGestureData.gestureImageNumber;
			
			tempGestureData.gestureClassNumberActual = newClassNumber + 1;
			NSMutableArray* arrayNewClass = [gestureDataArray objectAtIndex:newClassNumber];
			[arrayNewClass addObject:tempGestureData];	//The sequence array
		}
		[gestureDataArrayAllWithoutClass addObject:tempGestureData];
		[gestureDataArray removeLastObject];
	}
	
}

-(void)makeAllDataAsTraining{
    for(NSArray* gestureArray in gestureDataArray){
        for (GestureData* gestureData in gestureArray) {
            [gestureData setIsForTraining:YES];
        }
    }
}

-(void)setupTrainingAndValidationData{
	
	if (!trainingDataArray || !validationDataArray) {
		validationDataArray = [[NSMutableArray alloc]init];
		trainingDataArray = [[NSMutableArray alloc]init]; 
	}
	
	[trainingDataArray removeAllObjects];
	[validationDataArray removeAllObjects];
	
	for (int i=0; i<[gestureDataArray count]; i++) {
		NSArray* tempGestureDataArray = [gestureDataArray objectAtIndex:i];
		
		NSMutableArray* tempTrainingDataArray = [[NSMutableArray alloc]init];
		[trainingDataArray addObject:tempTrainingDataArray];
		
		NSMutableArray* tempValidationDataArray = [[NSMutableArray alloc]init];
		[validationDataArray addObject:tempValidationDataArray];
		
		for (GestureData* tempGestureData in tempGestureDataArray) {
			if (tempGestureData.isForTraining) {
				[tempTrainingDataArray addObject:tempGestureData.gestureData];
			}
			else {
				[tempValidationDataArray addObject:tempGestureData.gestureData];
			}
		}
	}
		
	
}



-(void)initializeObservationsequenceArray{
	
	totalNumberOfGestureClass = [self getNumberOfClass];
	if ((arrayOfGestureClass = malloc(totalNumberOfGestureClass * sizeof(int))) == NULL)
	{
		fprintf(stderr,"Memory allocation error (arrayOfGestureClass 1)\n");
	}
	else {
		for(int i=0; i < totalNumberOfGestureClass; i++){
			arrayOfGestureClass[i] = -1;
			//NSLog(@"%d - %d", i, )
			//*(arrayOfGestureClass+i) = -1 ;
		}
	}
	
	[self setGestureClassAndArray];
}

-(void)setGestureClassAndArray{
	if (gestureDataArray && [gestureDataArray count]>0) {
		if (!sequenceDataArray) {
			sequenceDataArray = [[NSMutableArray alloc]init];
		}
		else {
			[sequenceDataArray removeAllObjects];
		}

		for (int i=0;i< [gestureDataArray count]; i++) {
			GestureData* tempGestureData = [gestureDataArray objectAtIndex:i];
			int indexGestureDataInClassArray = [self indexGestureDataInClassArray:tempGestureData];
			if (indexGestureDataInClassArray >= 0) {
				NSMutableArray* arrayExistingClass = [sequenceDataArray objectAtIndex:indexGestureDataInClassArray];
				[arrayExistingClass addObject:[(NSArray*)tempGestureData.gestureData objectAtIndex:4]]; //The sequence array
				tempGestureData.gestureClassNumberActual = indexGestureDataInClassArray;
			}
			else {
				NSMutableArray* arrayNewClass = [[NSMutableArray alloc]init];
				[arrayNewClass addObject:[(NSArray*)tempGestureData.gestureData objectAtIndex:4]];	//The sequence array
				[sequenceDataArray addObject:arrayNewClass];
				
				int newClassNumber = [self getNextEmptyIndex];
				arrayOfGestureClass[newClassNumber] = tempGestureData.gestureImageNumber;
				tempGestureData.gestureClassNumberActual = newClassNumber;
				
			}
		}
	}
	else {
		//do nothing
		self.sequenceDataArray = nil;
	}

}

-(int)getNextEmptyIndex{
	int returnValue = -1;
	for (int i=0; i<totalNumberOfGestureClass; i++) {
		if (arrayOfGestureClass[i]==-1) {
			returnValue = i;
			break;
		}
	}
	return returnValue;
}

-(int)indexGestureDataInClassArray:(GestureData*) currentGestureData{
	int returnValue = -1;
	for (int i=0; i<totalNumberOfGestureClass; i++) {
		if (currentGestureData.gestureImageNumber == arrayOfGestureClass[i]) {
			returnValue = i;
			break;
		}
	}
	 
	/*if (classGestureDataArray && [classGestureDataArray count]>0) {
		for (int i=0; i<[classGestureDataArray count]; i++) {
			NSArray* tempGestureDataArray = [classGestureDataArray objectAtIndex:i];
			if (tempGestureDataArray && [tempGestureDataArray count]>0 && [(GestureData*)[tempGestureDataArray objectAtIndex:0] gestureImageNumber] == currentGestureData.gestureImageNumber) {
				returnValue = i;
				break;
			}
		}
	}*/
	
	return returnValue;
}

-(void)setDataSetAnalytics{
	//TODO:
	if (gestureDataArray != nil && [gestureDataArray count] > 0) {
		// do nothing
		totalNumberOfGestureData = 0;
		for (NSArray* tempGestureArray in gestureDataArray) {
			for (GestureData* tempGestureData in tempGestureArray) {
				totalNumberOfGestureData ++;
			}
		}
		totalNumberOfGestureClass = [gestureDataArray count];
	}
	else {
		arrayOfGestureClass = nil;
		arrayOfGestureCount = nil;
		
		totalNumberOfGestureData = 0;
		totalNumberOfGestureClass = 0;
		totalNumberOfUniquePeople = 0;
		totalNumberOfMen = 0;
		totalNumberOfWomen = 0;
		totalNumberOfLeftHanded = 0;
		totalNumberOfRightHanded = 0;
		totalNumberOfDisability = 0;
		totalNumberOfNonDisability = 0;
	}
}


-(int) getNumberOfClass{
	int returnValue = 0;
	if (gestureDataArray && [gestureDataArray count]>0) {
		BOOL isFoundSameClass = NO;
		for (int i=0; i<[gestureDataArray count]; i++) {
			isFoundSameClass = NO;
			for (int j=0; j<i; j++) {
				if ([(GestureData*)[gestureDataArray objectAtIndex:i] gestureImageNumber] == [(GestureData*)[gestureDataArray objectAtIndex:j] gestureImageNumber]) {
					isFoundSameClass = YES;
					break;
				}
			}
			if (!isFoundSameClass) {
				returnValue++;
			}
		}
	}
	return returnValue;
}

-(BOOL)saveDataSetToPath:(NSString*)pathToSaveDataSet andSavingMethod:(kDataSetSavingType)dataSetSavingType{
	BOOL returnValue = NO;
	
	switch (dataSetSavingType) {
		case kDataSetSavingTypeText:
			returnValue = [self saveAsText:pathToSaveDataSet];
			break;
		case kDataSetSavingTypeMatlab:
			returnValue = [self saveAsMatlab:pathToSaveDataSet];
			break;
		case kDataSetSavingTypePlist:
			returnValue = [self saveAsPlist:pathToSaveDataSet];
			break;
		default:
			break;
	}
	return returnValue;
}

-(BOOL)saveAsText:(NSString*)pathToSaveDataSet{
	//TODO: save as text
	BOOL returnValue = NO;
	return returnValue;
}

-(BOOL)saveAsMatlab:(NSString*)pathToSaveDataSet{
	//TODO: save as matlab file
	BOOL returnValue = NO;
	return returnValue;
}

-(BOOL)saveAsPlist:(NSString*)pathToSaveDataSet{
	BOOL returnValue = NO;
	
	NSMutableArray* tempDatasetArray = [[NSMutableArray alloc]initWithCapacity:[gestureDataArray count]];
	
	for(int i=0; i<[gestureDataArray count]; i++){
		NSMutableArray* tempDatasetArrayClass  =  [gestureDataArray objectAtIndex:i];
		NSMutableArray* newClassArray = [[NSMutableArray alloc]initWithCapacity:[tempDatasetArrayClass count]];
		[tempDatasetArray addObject:newClassArray];
		for(GestureData* tempGestureData in tempDatasetArrayClass){
			[newClassArray addObject:[tempGestureData getDictionaryFileOfGestureData]];
		}
	}
	
	
	NSDictionary* tempDictionaryToSaveData = [[NSDictionary alloc]
											  initWithObjects: [[NSArray alloc]initWithObjects: 
																[NSNumber numberWithInt:[tempDatasetArray count]],  
																tempDatasetArray,
																nil] 
											  forKeys:[[NSArray alloc]initWithObjects:
																KDS_DATASET_TOTALELEMENT, 
																KDS_DATASET,
																nil]];
	
	returnValue = [tempDictionaryToSaveData writeToFile:pathToSaveDataSet atomically:YES];
	return returnValue;
}

-(NSString*)getClassificationResultString{
	//TODO:	
}
-(NSString*)getDataAnaliyticString{
	//TODO:
}

-(void)dealloc{
	[gestureDataArray release];
	[operationsequenceArray release];
	[super dealloc];
}

@end
