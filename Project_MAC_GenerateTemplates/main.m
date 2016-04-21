// File: args.m
// Compile with: gcc -o args args.m -framework Foundation
#import <Foundation/Foundation.h>

#import <GestureRecognition/ConfigurationManager.h>
#import <GestureRecognition/Constants.h>
#import <GestureRecognition/DataSet.h>
#import <GestureRecognition/GestureData.h>
#import <GestureRecognition/Filter.h>
#import <GestureRecognition/DimensionalReductor.h>
#import <GestureRecognition/Cluster.h>
#import <GestureRecognition/Sampler.h>
#import <GestureRecognition/Preprocessor.h>
#import <GestureRecognition/NoiseEliminator.h>
#import <GestureRecognition/CrossValidator.h>
#import <GestureRecognition/Classifier.h>


typedef enum {
	ProgramRunningTypeDebugMode,			//0
	ProgramRunningTypeParameterTunning,		//1
	ProgramRunningTypeTest,					//2
    ProgramRunningTypeGenerateComparisions  //3
} ProgramRunningType;

#define PROGRAM_MODE ProgramRunningTypeDebugMode

NSString* logString;
NSString* logStringForBest;

// the initial parameters and the dataset is used in order to classify the data and
// after one parameter iteration, the learning and classification continue till the best classification result.
// The parameter tunning will finish, after each parameter options is considered. Then the learning classification model
// is saved in order to use it later.
void runProgramForParameterTunning(){
	[ConfigurationManager initializeParameters];
	DataSet* myCurrentDataSet = nil;
	[ConfigurationManager initialAllParameterValuesAsFirstPossibleValue];
    
    NSString* logTextFullPathString = [NSString stringWithFormat:@"%@LOG.txt",K_PATH_GESTUREDATASET];
    NSString* logBestFullPathString = [NSString stringWithFormat:@"%@LOG_BEST.txt",K_PATH_GESTUREDATASET];
    
	do{
		[ConfigurationManager makeAllParametersUnused];
		myCurrentDataSet  = [[DataSet alloc]initWithGestureDataPath:K_PATH_GESTUREDATA];
		[Filter filterDataSet:myCurrentDataSet];	//Filter the dataset - Filter is selected by the parameter and values determines from it
		[Sampler sampleDataSet:myCurrentDataSet]; //Sample is selected by the parameter and values determines from it
		[Cluster clusterDataSet:myCurrentDataSet];	//Cluster the gesture data - the clustering is done by reading the data and determine the cluster int value and write it to the 5.element in array; the gesture data = ( t, x, y, z, cluster no)
		ConfusionMatrix* myClassificationResult = [Classifier classifyDataSet:myCurrentDataSet];
		
		[ConfigurationManager saveParameterIfBetterResult:myClassificationResult];
		
		logString = [logString stringByAppendingFormat:@"---------------- \nParameters :\n%@\nConfusion Matrix:\n%@\nRecall Average: %g", [ConfigurationManager getCurrentParameterConfigurationString], [myClassificationResult toString], [myClassificationResult getRecallOfAll]];
		
		[logString writeToFile:logTextFullPathString atomically:YES];
		logStringForBest = [NSString stringWithFormat:@"---------------- \nParameters :\n%@\nConfusion Matrix:\n%@\nRecall Average: %g", [ConfigurationManager getBestParameterConfigurationString], [[ConfigurationManager getBestConfusionMatrix] toString], [[ConfigurationManager getBestConfusionMatrix] getRecallOfAll]];
        [logStringForBest writeToFile:logBestFullPathString atomically:YES];
		
		myCurrentDataSet=nil;
	
	}while ([ConfigurationManager setNextPossibleParameterValue]);
	
}

void deleteAllFilesInDirectory(NSString* directoryName){
    NSFileManager *fileManager = [NSFileManager defaultManager];
	NSError* error;
	NSArray *fileArrayInDirectory = nil;
	NSString* fullPathDirectory = nil;
    
    fullPathDirectory =[NSString stringWithFormat:@"%@%@",K_PATH_GESTUREDATASET,directoryName];
    fileArrayInDirectory =[fileManager contentsOfDirectoryAtPath:fullPathDirectory error:&error]  ;
	for(NSString* filePath in fileArrayInDirectory){
		[fileManager removeItemAtPath:[fullPathDirectory stringByAppendingString:filePath] error:&error];
	}
}

void deleteAllFilesInDirectories(){
    deleteAllFilesInDirectory(K_DIRECTORYNAME_01_RAWDATA);
    deleteAllFilesInDirectory(K_DIRECTORYNAME_02_NOISEELIMINATION);
    deleteAllFilesInDirectory(K_DIRECTORYNAME_03_FILTERED);
    deleteAllFilesInDirectory(K_DIRECTORYNAME_04_PREPROCESS);
    deleteAllFilesInDirectory(K_DIRECTORYNAME_05_SAMPLING);
    deleteAllFilesInDirectory(K_DIRECTORYNAME_06_CLUSTERING);
    deleteAllFilesInDirectory(K_DIRECTORYNAME_07_DIMENSIONALREDUCTION);
}

void saveDataItems(DataSet* currentDataSet, NSString* directoryName){
    int indexNumber = 1;
	for (NSArray* gestureArray in currentDataSet.gestureDataArray) {
		indexNumber = 1;
		for (GestureData* currentGestureData in gestureArray) {
			NSString* gestureFullPathString = [NSString stringWithFormat:@"%@%@%@_%d.txt",K_PATH_GESTUREDATASET,directoryName,currentGestureData.gestureTitle,indexNumber];
			[currentGestureData saveAsText:gestureFullPathString];
			indexNumber++;
		}
	}
}

NSString* getDocumentsDirectory(){  
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);  
    return [paths objectAtIndex:0];  
}


//void showComparisionResult(NSString* comparisionResultName){
//    [ConfigurationManager initializeParameters];
//    DataSet* myCurrentDataSet2 = [[DataSet alloc]initWithGestureDataPath:K_PATH_GESTUREDATA];
//    [NoiseEliminator eliminateNoiseFromDataSet:myCurrentDataSet2];
//	[Filter filterDataSet:myCurrentDataSet2]; //Filter is selected by the parameter and values determines from it
//	[Sampler sampleDataSet:myCurrentDataSet2]; //Sample is selected by the parameter and values determines from it
//	[Cluster clusterDataSet:myCurrentDataSet2];
//    ConfusionMatrix* myClassificationResult = [Classifier classifyHeuristic:myCurrentDataSet2 andThresholdControl:NO];
//    NSLog(@"ClassificationResult %@: \n%@", comparisionResultName, [myClassificationResult toString]);
//   
//}

NSString* runClassificationForCompare(BOOL isFilter, BOOL isThreshold, BOOL isWarpingDynamic){
    [ConfigurationManager initializeParameters];
    [ConfigurationManager initializeConfigurationList];
    [ConfigurationManager loadConfigurationList:@"configurationGR_TEMP"];
    DataSet* myCurrentDataSet = [[DataSet alloc]initWithGestureDataPath:K_PATH_GESTUREDATA]; 
    [NoiseEliminator eliminateNoiseFromDataSet:myCurrentDataSet];
    if(isFilter){
        [Filter filterDataSet:myCurrentDataSet];
    }
    [Sampler sampleDataSet:myCurrentDataSet]; //Sample is selected by the parameter and values determines from it
    ConfusionMatrix* myClassificationResult = [Classifier classifyHeuristic:myCurrentDataSet andThresholdControl:isThreshold];
    [myCurrentDataSet release];
    return [myClassificationResult toString];
}

void runValidationForCompare(BOOL isFilter, BOOL isThreshold, BOOL isWarpingDynamic){
    [ConfigurationManager loadConfigurationList:@"configurationGR_TEMP"];
    DataSet* myCurrentDataSet = [[DataSet alloc]initWithGestureDataPath:K_PATH_GESTUREDATA]; 
    [NoiseEliminator eliminateNoiseFromDataSet:myCurrentDataSet];
    if(isFilter){
        [Filter filterDataSet:myCurrentDataSet];
    }
    [Sampler sampleDataSet:myCurrentDataSet]; //Sample is selected by the parameter and values determines from it
    [Classifier trainingForDTWDistances:myCurrentDataSet];
    [ConfigurationManager saveConfigurationList:@"configurationGR_TEMP"];
    [myCurrentDataSet release];
}

void runTrainingForCompare(BOOL isFilter, BOOL isSameMean, BOOL isSameVariance, BOOL isThreshold, BOOL isWarpingDynamic){
    [ConfigurationManager initializeParameters];
    [ConfigurationManager initializeConfigurationList];
    //int combinationNumber = 0;
    if(isWarpingDynamic){
        [ConfigurationManager loadConfigurationList];
    }
    DataSet* myCurrentDataSet = [[DataSet alloc]initWithGestureDataPath:K_PATH_GESTUREDATA]; 
    [NoiseEliminator eliminateNoiseFromDataSet:myCurrentDataSet];
    if(isFilter){
        [Filter filterDataSet:myCurrentDataSet];
    }
    [Preprocessor preprocessTrainingDataSet:myCurrentDataSet andMakeSameMean:isSameMean andMakeSameVariance:isSameVariance];
    [Sampler sampleDataSet:myCurrentDataSet]; //Sample is selected by the parameter and values determines from it
    [Classifier trainingWithAllDataSet:myCurrentDataSet];
    [ConfigurationManager saveConfigurationList:@"configurationGR_TEMP"];
    [myCurrentDataSet release];
}
void runProgramForGenerateComparisionConfigurations(){
  /*  
    BOOL isFilter = YES;
    BOOL isSameMean= YES;
    BOOL isSameVariance= YES;
    BOOL isThreshold= YES;
    BOOL isWarpingDynamic = YES;
    
    runTrainingForCompare(isFilter, isSameMean, isSameVariance, isThreshold, isWarpingDynamic);
    runValidationForCompare(isFilter, isThreshold, isWarpingDynamic);
    NSString* classificationResult = runClassificationForCompare(isFilter, isThreshold, isWarpingDynamic);
    NSLog(@"ClassificationResult %d-%d-%d-%d-%d: \n%@",isFilter, isSameMean, isSameVariance, isThreshold, isWarpingDynamic,classificationResult);
    */
     
    for(int i=0;i<32;i++){
        BOOL isFilter = (i%2!=0);
        BOOL isSameMean= (i/2)%2!=0;
        BOOL isSameVariance= (i/4)%2!=0;
        BOOL isThreshold= (i/8)%2!=0;
        BOOL isWarpingDynamic = (i/16)%2!=0;
        
        runTrainingForCompare(isFilter, isSameMean, isSameVariance, isThreshold, isWarpingDynamic);
        runValidationForCompare(isFilter, isThreshold, isWarpingDynamic);
        NSString* classificationResult = runClassificationForCompare(isFilter, isThreshold, isWarpingDynamic);
        NSLog(@"ClassificationResult %d-%d-%d-%d-%d: \n%@",isFilter, isSameMean, isSameVariance, isThreshold, isWarpingDynamic,classificationResult);
    }
    
    /*
   
    [ConfigurationManager initializeParameters];
    //[ConfigurationManager loadConfigurationList];
    DataSet* myCurrentDataSet = [[DataSet alloc]initWithGestureDataPath:K_PATH_GESTUREDATA]; [NoiseEliminator eliminateNoiseFromDataSet:myCurrentDataSet];
    [Filter filterDataSet:myCurrentDataSet];
    [Preprocessor preprocessTrainingDataSet:myCurrentDataSet andMakeSameMean:YES andMakeSameVariance:YES];
    [Sampler sampleDataSet:myCurrentDataSet]; //Sample is selected by the parameter and values determines from it
    [Classifier trainingWithAllDataSet:myCurrentDataSet];
    ConfusionMatrix* myClassificationResult = [Classifier classifyHeuristic:myCurrentDataSet andThresholdControl:NO];
    NSLog(@"ClassificationResult 1: \n%@", [myClassificationResult toString]);
    
    [myCurrentDataSet release];
    [ConfigurationManager initializeParameters];
    myCurrentDataSet = [[DataSet alloc]initWithGestureDataPath:K_PATH_GESTUREDATA];
    [NoiseEliminator eliminateNoiseFromDataSet:myCurrentDataSet];
    [Filter filterDataSet:myCurrentDataSet];
    [Preprocessor preprocessTrainingDataSet:myCurrentDataSet andMakeSameMean:NO andMakeSameVariance:YES];
    [Sampler sampleDataSet:myCurrentDataSet]; //Sample is selected by the parameter and values determines from it
	[Cluster clusterDataSet:myCurrentDataSet];
    [Classifier trainingWithAllDataSet:myCurrentDataSet];
    [ConfigurationManager saveConfigurationList:@"configurationGRWithoutSameMean"];
    showComparisionResult(@" - without same mean - ");
    
    [myCurrentDataSet release];
    [ConfigurationManager initializeParameters];
    myCurrentDataSet = [[DataSet alloc]initWithGestureDataPath:K_PATH_GESTUREDATA];
    [NoiseEliminator eliminateNoiseFromDataSet:myCurrentDataSet];
    [Filter filterDataSet:myCurrentDataSet];
    [Preprocessor preprocessTrainingDataSet:myCurrentDataSet andMakeSameMean:YES andMakeSameVariance:NO];
    [Sampler sampleDataSet:myCurrentDataSet]; //Sample is selected by the parameter and values determines from it
	[Cluster clusterDataSet:myCurrentDataSet];
    [Classifier trainingWithAllDataSet:myCurrentDataSet];
    [ConfigurationManager saveConfigurationList:@"configurationGRWithoutSameVariance"];
    showComparisionResult(@" - without same variance - ");
    */
}

void runProgramForDebugMode(){
	//!!!: The code is for debug purpose ... 
	[ConfigurationManager initializeParameters];
    //[ConfigurationManager loadConfigurationList];
    
	DataSet* myCurrentDataSet = [[DataSet alloc]initWithGestureDataPath:K_PATH_GESTUREDATA];
    saveDataItems(myCurrentDataSet, K_DIRECTORYNAME_01_RAWDATA);
    
	[myCurrentDataSet saveAsPlist:[K_PATH_GESTUREDATASET stringByAppendingString:@"DATASET_RAW.plist"]];
	
    //[DimensionalReductor dimensionReduction:myCurrentDataSet];saveDataItems(myCurrentDataSet, K_DIRECTORYNAME_03_DIMENSIONALREDUCTION);
    //saveDataItems(myCurrentDataSet, K_DIRECTORYNAME_03_DIMENSIONALREDUCTION);
    [NoiseEliminator eliminateNoiseFromDataSet:myCurrentDataSet];
    saveDataItems(myCurrentDataSet, K_DIRECTORYNAME_02_NOISEELIMINATION);
    
	[Filter filterDataSet:myCurrentDataSet]; //Filter is selected by the parameter and values determines from it
	saveDataItems(myCurrentDataSet, K_DIRECTORYNAME_03_FILTERED);
    
    [Preprocessor preprocessTrainingDataSet:myCurrentDataSet];
    saveDataItems(myCurrentDataSet, K_DIRECTORYNAME_04_PREPROCESS);
    
	[Sampler sampleDataSet:myCurrentDataSet]; //Sample is selected by the parameter and values determines from it
	saveDataItems(myCurrentDataSet, K_DIRECTORYNAME_05_SAMPLING);
    
	[Cluster clusterDataSet:myCurrentDataSet];
    //saveDataItems(myCurrentDataSet, K_DIRECTORYNAME_06_CLUSTERING);
	
    //[Preprocessor postProcessTrainingDataSet:myCurrentDataSet];
    //saveDataItems(myCurrentDataSet, @"CorrectedData/data_After_Postprocess/");
    
    //[DimensionalReductor dimensionReduction:myCurrentDataSet];
    //saveDataItems(myCurrentDataSet, K_DIRECTORYNAME_07_DIMENSIONALREDUCTION);
    
    [Classifier trainingWithAllDataSet:myCurrentDataSet];
    [ConfigurationManager saveDTWTemplates:[K_PATH_GESTUREDATASET stringByAppendingString:@"CorrectedData/"]];
    [ConfigurationManager saveConfigurationList];
    
    [myCurrentDataSet release];
    
    
     [ConfigurationManager loadConfigurationList];
    myCurrentDataSet = [[DataSet alloc]initWithGestureDataPath:K_PATH_GESTUREDATA_TRAINING];
    [NoiseEliminator eliminateNoiseFromDataSet:myCurrentDataSet];
	[Filter filterDataSet:myCurrentDataSet]; //Filter is selected by the parameter and values determines from it
	[Sampler sampleDataSet:myCurrentDataSet]; //Sample is selected by the parameter and values determines from it
	[Cluster clusterDataSet:myCurrentDataSet];
    saveDataItems(myCurrentDataSet, @"CorrectedData/data_After_Clustering2/");
    [Classifier makeDTWBestWithValidationDataSet:myCurrentDataSet];
    [ConfigurationManager saveConfigurationList];
    
    
    [ConfigurationManager loadConfigurationList];
    DataSet* myCurrentDataSet2 = [[DataSet alloc]initWithGestureDataPath:K_PATH_GESTUREDATA_VALIDATION];
    saveDataItems(myCurrentDataSet2, K_DIRECTORYNAME_01_RAWDATA);
    [NoiseEliminator eliminateNoiseFromDataSet:myCurrentDataSet2];
    saveDataItems(myCurrentDataSet2, K_DIRECTORYNAME_02_NOISEELIMINATION);
	[Filter filterDataSet:myCurrentDataSet2]; //Filter is selected by the parameter and values determines from it
    saveDataItems(myCurrentDataSet2, K_DIRECTORYNAME_03_FILTERED);
	[Sampler sampleDataSet:myCurrentDataSet2]; //Sample is selected by the parameter and values determines from it
    saveDataItems(myCurrentDataSet2, K_DIRECTORYNAME_05_SAMPLING);
	[Cluster clusterDataSet:myCurrentDataSet2];
    saveDataItems(myCurrentDataSet2, K_DIRECTORYNAME_06_CLUSTERING);
    saveDataItems(myCurrentDataSet2, @"CorrectedData/data_After_Clustering3/");
    
    //[Classifier makeDTWBestWithValidationDataSet:myCurrentDataSet2];
    //[ConfigurationManager saveConfigurationList];
    ConfusionMatrix* myClassificationResult = [Classifier classifyHeuristic:myCurrentDataSet2 andThresholdControl:YES];
    NSLog(@"ClassificationResult : \n%@", [myClassificationResult toString]);
    saveDataItems(myCurrentDataSet2, @"CorrectedData/data_After_Preprocess2/");
    
	//ConfusionMatrix* myClassificationResult = [Classifier classifyDataSet:myCurrentDataSet];
	//NSLog(@"ClassificationResult : \n%@", [myClassificationResult toString]);
    
    
    
	/*
     NSMutableArray* tempArray = [[myCurrentDataSet gestureDataArray]objectAtIndex:0];
     [(GestureData*)[tempArray objectAtIndex:0] saveAsText:[K_PATH_GESTUREDATASET stringByAppendingString:@"GESTURE_RAW.txt"]];
     [myCurrentDataSet saveAsPlist:[K_PATH_GESTUREDATASET stringByAppendingString:@"DATASET_FILTERED.plist"]];
     [(GestureData*)[tempArray objectAtIndex:0] saveAsText:[K_PATH_GESTUREDATASET stringByAppendingString:@"GESTURE_FILTERED.txt"]];
     [myCurrentDataSet saveAsPlist:[K_PATH_GESTUREDATASET stringByAppendingString:@"DATASET_SAMPLED.plist"]];
     [(GestureData*)[tempArray objectAtIndex:0] saveAsText:[K_PATH_GESTUREDATASET stringByAppendingString:@"DATASET_SAMPLED.txt"]];
     [myCurrentDataSet saveAsPlist:[K_PATH_GESTUREDATASET stringByAppendingString:@"DATASET_CLUSTERED.plist"]];
     [(GestureData*)[tempArray objectAtIndex:0] saveAsText:[K_PATH_GESTUREDATASET stringByAppendingString:@"DATASET_CLUSTERED.txt"]];
     

     
	[Cluster clusterDataSet:myCurrentDataSet];
	[(GestureData*)[[[myCurrentDataSet gestureDataArray]objectAtIndex:1]objectAtIndex:1] saveAsText:[K_PATH_GESTUREDATASET stringByAppendingString:@"GESTURE_CLUSTERED.txt"]];
	
	[CrossValidator determineTrainingAndValidationSet:myCurrentDataSet];
	for (NSArray* tempGestureDataArray in myCurrentDataSet.gestureDataArray) {
		for (int i = 0; i< [CrossValidator totalTrainigTry:tempGestureDataArray]; i++) {
			[Classifier train:tempGestureDataArray];	//train HMM with given trainin set
			[Classifier validate:tempGestureDataArray andSaveResult:myCurrentDataSet andFoldNumber:i]; //confusion matrix generation according to validation result
		}
	}
	 
    // [NoiseEliminator eliminateNoiseFromDataSet:myCurrentDataSet];
	 */
}


// the parameters and the dataset is used in order to classify the data and gives the result
void runProgramAsNormalMode(){
    
    [ConfigurationManager initializeParameters];
    [ConfigurationManager loadConfigurationList];
    //[ConfigurationManager saveDTWTemplates:[K_PATH_GESTUREDATASET stringByAppendingString:@"CorrectedData/"]];
    DataSet* myCurrentDataSet2 = [[DataSet alloc]initWithGestureDataPath:K_PATH_GESTUREDATA];
    //[myCurrentDataSet2 saveAsPlist:[K_PATH_GESTUREDATASET stringByAppendingString:@"DATASET_RAW.plist"]];
    [NoiseEliminator eliminateNoiseFromDataSet:myCurrentDataSet2];
	[Filter filterDataSet:myCurrentDataSet2]; //Filter is selected by the parameter and values determines from it
	[Sampler sampleDataSet:myCurrentDataSet2]; //Sample is selected by the parameter and values determines from it
	[Cluster clusterDataSet:myCurrentDataSet2];
    saveDataItems(myCurrentDataSet2, @"CorrectedData/data_After_Clustering2/");
    
    //[Classifier trainingForDTWDistances:myCurrentDataSet2];
    //[Classifier makeDTWBestWithValidationDataSet:myCurrentDataSet2];
    //[ConfigurationManager saveConfigurationList];
    ConfusionMatrix* myClassificationResult = [Classifier classifyHeuristic:myCurrentDataSet2 andThresholdControl:YES];
    NSLog(@"ClassificationResult : \n%@", [myClassificationResult toString]);
    saveDataItems(myCurrentDataSet2, @"CorrectedData/data_After_Preprocess2/");
	/*[ConfigurationManager initializeParameters];
	DataSet* myCurrentDataSet = [[DataSet alloc]initWithGestureDataPath:K_PATH_GESTUREDATA];
	
	[Filter filterDataSet:myCurrentDataSet];	//Filter the dataset - Filter is selected by the parameter and values determines from it
	[Cluster clusterDataSet:myCurrentDataSet];	//Cluster the gesture data - the clustering is done by reading the data and determine the cluster int value and write it to the 5.element in array; the gesture data = ( t, x, y, z, cluster no)
	[CrossValidator determineTrainingAndValidationSet:myCurrentDataSet]; //Preapere the training and validation data in order to check the result (cross validation)
	[Classifier classifyDataSet:myCurrentDataSet];
	[logString stringByAppendingFormat:@"----------------\n %@ \n %@", [myCurrentDataSet getClassificationResultString], [ConfigurationManager getCurrentParameterConfigurationString]];
	*/
}

int main(int argc, char *argv[]) {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	NSUserDefaults *args = [NSUserDefaults standardUserDefaults];
	logString = @"";
    logStringForBest=@"";
    
    deleteAllFilesInDirectories();
    
	if (PROGRAM_MODE==ProgramRunningTypeParameterTunning) {
		runProgramForParameterTunning();
	}
	else if(PROGRAM_MODE==ProgramRunningTypeDebugMode){
		runProgramForDebugMode();
	}
    else if(PROGRAM_MODE==ProgramRunningTypeGenerateComparisions){
		runProgramForGenerateComparisionConfigurations();
	}
	else {
		runProgramAsNormalMode();
	}

	NSString* logTextFullPathString = [NSString stringWithFormat:@"%@LOG.txt",K_PATH_GESTUREDATASET];
	[logString writeToFile:logTextFullPathString atomically:YES];
	
	[pool release];
	
	return 0;
}

