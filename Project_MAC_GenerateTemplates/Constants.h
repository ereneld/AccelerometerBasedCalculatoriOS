/*
 *  Constants.h
 *  GestureRecognition
 *
 *  Created by dogukan ibrahimoglu on 1/2/11.
 *  Copyright 2011 Bogazici University. All rights reserved.
 *
 * Here KPN : Constant Parameter Name (parameters are used with configuration manager)
 *		KDS : Constant Directory String (these strings are located in PLIST as dictionary key / value pair)
 *		K : Constant Program String (Some strings used in program-> exp. operations sequence string)
 */


// The Parameter Names which are used in parameter array 
static NSString *const KPN_FILTER_TYPE = @"KPN_FILTER_TYPE"; 
static NSString *const KPN_FILTER_ISADAPTIVE = @"KPN_FILTER_ISADAPTIVE";	//are used for low pass filter
static NSString *const KPN_FILTER_UPDATE_FREQUENCY = @"KPN_FILTER_UPDATE_FREQUENCY"; 
static NSString *const KPN_FILTER_CUTOFF_FREQUENCY = @"KPN_FILTER_CUTOFF_FREQUENCY"; 
static NSString *const KPN_FILTER_ACCELEROMETER_MIN_STEP = @"KPN_FILTER_ACCELEROMETER_MIN_STEP"; 
static NSString *const KPN_FILTER_ACCELEROMETER_NOISE_ATTENUATION = @"KPN_FILTER_ACCELEROMETER_NOISE_ATTENUATION"; 
static NSString *const KPN_FILTER_ISADAPTIVE2 = @"KPN_FILTER_ISADAPTIVE2"; //are used for high pass filter
static NSString *const KPN_FILTER_UPDATE_FREQUENCY2 = @"KPN_FILTER_UPDATE_FREQUENCY2"; 
static NSString *const KPN_FILTER_CUTOFF_FREQUENCY2 = @"KPN_FILTER_CUTOFF_FREQUENCY2"; 
static NSString *const KPN_FILTER_ACCELEROMETER_MIN_STEP2 = @"KPN_FILTER_ACCELEROMETER_MIN_STEP2"; 
static NSString *const KPN_FILTER_ACCELEROMETER_NOISE_ATTENUATION2 = @"KPN_FILTER_ACCELEROMETER_NOISE_ATTENUATION2"; 

static NSString *const KPN_SAMPLER_TYPE = @"KPN_SAMPLER_TYPE"; 
static NSString *const KPN_SAMPLE_SIZE = @"KPN_SAMPLE_SIZE";	

static NSString *const KPN_NOISEELIMINATOR_DATAAVERAGEAMPLITUTE = @"KPN_NOISEELIMINATOR_DATAAVERAGEAMPLITUTE";
static NSString *const KPN_NOISEELIMINATOR_DATALENGTH = @"KPN_NOISEELIMINATOR_DATAAVERAGEAMPLITUTE";
static NSString *const KPN_NOISEELIMINATOR_MIN_AVERAGE_AMP = @"KPN_NOISEELIMINATOR_MIN_AVERAGE_AMP";
static NSString *const KPN_NOISEELIMINATOR_MAX_AVERAGE_AMP = @"KPN_NOISEELIMINATOR_MAX_AVERAGE_AMP";
static NSString *const KPN_NOISEELIMINATOR_MIN_LENGTH = @"KPN_NOISEELIMINATOR_MIN_LENGTH";
static NSString *const KPN_NOISEELIMINATOR_MAX_LENGTH = @"KPN_NOISEELIMINATOR_MAX_LENGTH";
static NSString *const KPN_NOISEELIMINATOR_MINTIME_LENGTH = @"KPN_NOISEELIMINATOR_MINTIME_LENGTH";
static NSString *const KPN_NOISEELIMINATOR_MAXTIME_LENGTH = @"KPN_NOISEELIMINATOR_MAXTIME_LENGTH";

static NSString *const KPN_DIMENSIONALREDUCTOR_TYPE = @"KPN_DIMENSIONALREDUCTOR_TYPE"; 

static NSString *const KPN_CLUSTER_TYPE = @"KPN_CLUSTER_TYPE"; 
static NSString *const KPN_CLUSTER_DIMENSION = @"KPN_CLUSTER_DIMENSION"; 
static NSString *const KPN_CLUSTER_NUMBER = @"KPN_CLUSTER_NUMBER"; 
static NSString *const KPN_CLUSTER_INITIALIZATION = @"KPN_CLUSTER_INITIALIZATION"; 
static NSString *const KPN_CLUSTER_RANGE_MIN_X = @"KPN_CLUSTER_RANGE_MIN_X"; 
static NSString *const KPN_CLUSTER_RANGE_MAX_X = @"KPN_CLUSTER_RANGE_MAX_X"; 
static NSString *const KPN_CLUSTER_RANGE_MIN_Y = @"KPN_CLUSTER_RANGE_MIN_Y"; 
static NSString *const KPN_CLUSTER_RANGE_MAX_Y = @"KPN_CLUSTER_RANGE_MAX_Y"; 
static NSString *const KPN_CLUSTER_RANGE_MIN_Z = @"KPN_CLUSTER_RANGE_MIN_Z"; 
static NSString *const KPN_CLUSTER_RANGE_MAX_Z = @"KPN_CLUSTER_RANGE_MAX_Z"; 
static NSString *const KPN_CLUSTER_XY_SPLIT = @"KPN_CLUSTER_XY_SPLIT"; 
static NSString *const KPN_CLUSTER_XZ_SPLIT = @"KPN_CLUSTER_XZ_SPLIT"; 
static NSString *const KPN_CLUSTER_YZ_SPLIT = @"KPN_CLUSTER_YZ_SPLIT"; 

static NSString *const KPN_CLASSIFIER_TYPE = @"KPN_CLASSIFIER_TYPE"; 
static NSString *const KPN_CLASSIFIER_STATE_NUMBER = @"KPN_CLASSIFIER_STATE_NUMBER"; 
static NSString *const KPN_CLASSIFIER_OBSERVATION_NUMBER = @"KPN_CLASSIFIER_OBSERVATION_NUMBER"; 
static NSString *const KPN_CLASSIFIER_MAX_ITERATION = @"KPN_CLASSIFIER_MAX_ITERATION"; 

static NSString *const KPN_CROSSVALIDATOR_TYPE = @"KPN_CROSSVALIDATOR_TYPE"; 
static NSString *const KPN_CROSSVALIDATOR_K_NUMBER = @"KPN_CROSSVALIDATOR_K_NUMBER"; 

// The constant string used in Program in order to give user easy to understand information
static NSString *const K_OPERATION_RAW = @"READING RAW DATA"; 
static NSString *const K_OPERATION_FILTER = @"FILTER"; 
static NSString *const K_OPERATION_NONFILTER = @"NONFILTER"; 
static NSString *const K_OPERATION_SAMPLING = @"SAMPLING"; 
static NSString *const K_OPERATION_NONSAMPLING = @"NONSAMPLING"; 
static NSString *const K_OPERATION_CLUSTER = @"CLUSTER"; 
static NSString *const K_OPERATION_NONCLUSTER = @"NONCLUSTER"; 
static NSString *const K_OPERATION_CLASSIFICATION = @"CLASSIFICATION"; 
static NSString *const K_OPERATION_NONCLASSIFICATION = @"NONCLASSIFICATION"; 
static NSString *const K_OPERATION_CROSSVALIDATOR = @"CROSSVALIDATOR"; 
static NSString *const K_OPERATION_NONCROSSVALIDATOR = @"NONCROSSVALIDATOR"; 
static NSString *const K_OPERATION_DIMENSIONALREDUCTION = @"DIMENSIONALREDUCTION"; 
static NSString *const K_OPERATION_NONDIMENSIONALREDUCTION = @"NONDIMENSIONALREDUCTION"; 

static NSString *const K_DEFAULT_HAND = @"R"; //while gathering the data if hand is not given


// The Dictionary Key Names which are used while reading from - or writing to a PLIST  
static NSString *const KDS_PARAMETER_NAME = @"PARAMETER_NAME";
static NSString *const KDS_PARAMETER_VALUE = @"PARAMETER_VALUE";
static NSString *const KDS_PARAMETER_NUMBEROFITEMSINRANGE = @"PARAMETER_NUMBEROFITEMSINRANGE";
static NSString *const KDS_PARAMETER_RANGEMIN = @"PARAMETER_RANGEMIN";
static NSString *const KDS_PARAMETER_RANGEMAX = @"PARAMETER_RANGEMAX";
static NSString *const KDS_PARAMETER_ISINCLUDEMINRANGE = @"PARAMETER_ISINCLUDEMINRANGE";
static NSString *const KDS_PARAMETER_ISINCLUDEMAXRANGE = @"PARAMETER_ISINCLUDEMAXRANGE";

static NSString *const KDS_GESTUREDATA_PATH = @"GESTUREDATA_PATH";
static NSString *const KDS_GESTUREDATA_TITLE = @"GESTUREDATA_TITLE";
static NSString *const KDS_GESTUREDATA_IMAGENUMBER = @"GESTUREDATA_IMAGENUMBER";
static NSString *const KDS_GESTUREDATA_AGE = @"GESTUREDATA_AGE";
static NSString *const KDS_GESTUREDATA_SEX = @"GESTUREDATA_SEX";
static NSString *const KDS_GESTUREDATA_HAND = @"GESTUREDATA_HAND";
static NSString *const KDS_GESTUREDATA_CURRENT_HAND = @"GESTUREDATA_CURRENT_HAND";
static NSString *const KDS_GESTUREDATA_DISABILITY = @"GESTUREDATA_DISABILITY";
static NSString *const KDS_GESTUREDATA_JOBTYPE = @"GESTUREDATA_JOBTYPE";
static NSString *const KDS_GESTUREDATA_EDUCATIONTYPE = @"GESTUREDATA_EDUCATIONTYPE";
static NSString *const KDS_GESTUREDATA_DATE = @"GESTUREDATA_DATE";
static NSString *const KDS_GESTUREDATA_DATA = @"GESTUREDATA_DATA";

static NSString *const KDS_GESTUREDATA_ACTUALCLASS = @"GESTUREDATA_ACTUALCLASS";
static NSString *const KDS_GESTUREDATA_PREDICTEDCLASS = @"GESTUREDATA_PREDICTEDCLASS";
static NSString *const KDS_GESTUREDATA_USEDFORTRAINING = @"GESTUREDATA_USEDFORTRAINING";

static NSString *const KDS_DATASET_TOTALELEMENT = @"DATASET_TOTALELEMENT";
static NSString *const KDS_DATASET = @"DATASET";

// The Configuration PLIST key names
static NSString *const KC_CLUSTER = @"CLUSTER";
static NSString *const KC_CLASSIFIER = @"CLASSIFIER";
static NSString *const KC_CLASS_NUMBER = @"KC_CLASS_NUMBER";


//Enumarations used in PROGRAM

typedef enum {
	FilterTypeNONE,		//0
	FilterTypeLowPass,	//1
	FilterTypeBandPass,	//2
	FilterTypeHighPass,	//3
	FilterTypeKalman,	//4
	FilterTypeNAN	// -> it should be at last element in order to know the limit of type
} FilterType;

typedef enum {
	ClusterTypeNONE,			//0
	ClusterTypeKMeans,			//1
	ClusterTypeKMedoid,			//2
	ClusterTypeLloyd,			//3
	ClusterTypeTrajectoryAngle,	//4
	ClusterTypeAmplitudeFixed,	//5
	ClusterTypeAmplitudeDynamic,	//6
    ClusterTypeALLDynamic,
	ClusterTypeNAN	// -> it should be at last element in order to know the limit of type
} ClusterType;

typedef enum {
	ClusterInializationTypeNONE,							//0
	ClusterInializationTypeRandomInRange,					//1
	ClusterInializationTypeEqualPartitionInRange,			//2
	ClusterInializationTypeSphericalRandomInRange,			//3
	ClusterInializationTypeSphericalRandomInUnitSphere, 		//4 the range is from -1 to 1 both x, y, z directions, centered to 0,0,0
	ClusterInializationTypeNAN	// -> it should be at last element in order to know the limit of type
} ClusterInializationType;

typedef enum {
	ClassifierTypeNONE,					//0
	ClassifierTypeObservableMM,			//1
	ClassifierTypeHMM,					//2
    ClassifierType3DHMM,				//3
	ClassifierTypePreciseHMM,			//4
	ClassifierTypeDTW,					//5
	ClassifierTypeNAN	// -> it should be at last element in order to know the limit of type
} ClassifierType;

typedef enum {
	CrossValidatorTypeNONE,					//0
	CrossValidatorTypeKFold,				//1
	CrossValidatorTypeRandomSubsampling,	//2
	CrossValidatorTypeLeaveOneOut,			//3
	CrossValidatorTypeNAN	// -> it should be at last element in order to know the limit of type
} CrossValidatorType;

typedef enum {
	SamplerTypeNONE,			//0
	SamplerTypeSimple,			//1
	SamplerTypeAverage,			//2
	SamplerTypeMedian,			//3
	SamplerTypeMiddle,			//4
	SamplerTypeNAN				// -> it should be at last element in order to know the limit of type
} SamplerType;

typedef enum {
	DimensionalRecudtorTypeNONE,		//0
	DimensionalRecudtorTypeFFT,			//1
	DimensionalRecudtorTypeLDA,			//2
	DimensionalRecudtorTypePCA,			//3
	DimensionalRecudtorTypeNAN			// -> it should be at last element in order to know the limit of type
} DimensionalRecudtorType;

//Changable variables
static NSString *const K_PATH_GESTUREDATA = @"/Users/ereneld/Documents/Projects/Academic Applications/Thesis Projects/DataSetForDebug/";

static NSString *const K_PATH_GESTUREDATA_TRAINING = @"/Users/ereneld/Documents/Projects/Academic Applications/Thesis Projects/DataSetForDebug/training/";
static NSString *const K_PATH_GESTUREDATA_VALIDATION = @"/Users/ereneld/Documents/Projects/Academic Applications/Thesis Projects/DataSetForDebug/validation/";

static NSString *const K_PATH_GESTUREDATASET = @"/Users/ereneld/Documents/Projects/Academic Applications/Thesis Projects/DataSetAllInOne/";

static NSString *const K_DIRECTORYNAME_01_RAWDATA = @"CorrectedData/data_Raw/";
static NSString *const K_DIRECTORYNAME_02_NOISEELIMINATION = @"CorrectedData/data_After_NoiseElimination/";
static NSString *const K_DIRECTORYNAME_03_FILTERED = @"CorrectedData/data_After_Filter/";
static NSString *const K_DIRECTORYNAME_04_PREPROCESS = @"CorrectedData/data_After_Preprocess/";
static NSString *const K_DIRECTORYNAME_05_SAMPLING = @"CorrectedData/data_After_Sampling/";
static NSString *const K_DIRECTORYNAME_06_CLUSTERING = @"CorrectedData/data_After_Clustering/";
static NSString *const K_DIRECTORYNAME_07_DIMENSIONALREDUCTION = @"CorrectedData/data_After_DimensionalReduction/";

static int K_UPDATE_FREQUENCY = 60.0f;
