/*
 *  Constants.h
 *  GestureRecognition
 *
 *  Created by dogukan ibrahimoglu on 9/6/10.
 *  Copyright 2010 Bogazici University. All rights reserved.
 *
 */

/*
typedef enum {
	DataSetDirectory_FromDisk,
	DataSetDirectory_FromiPhone_Dataset,
	DataSetDirectory_FromiPhone_TestData
} DataSetDirectoryType;

typedef enum {
	ProgramOutputType_TextDocument,
	ProgramOutputType_DataDocumentForGrapher,
	ProgramOutputType_DataDocumentForMatlab
} ProgramOutputType;

typedef enum {
	FilterType_NONE,
	FilterType_HighPass,
	FilterType_LowPass
} FilterType;

typedef enum {
	NoiseType_NONE,		
	NoiseType_MinMax,	//The min and max values according to threshold value is elimiated
	NoiseType_ExpectedStateSize	//if the expected state size is low, than eliminated
} NoiseType;

typedef enum {
	NormalizationType_NONE,				//-> value 0
	NormalizationType_TimeSpaceNormalization, //for wavelength	
	NormalizationType_RotateAccordingToPosition,
	NormalizationType_MinMax_Amplitude //-> value 3
} NormalizationType;

typedef enum {
	kMeanInitialization_Random_inRange,		
	kMeanInitialization_EqualPartition_inRange, 	
	//kMeanInitialization_Spherical_EqualPartition_inRange,
	kMeanInitialization_Spherical_Random_inRange,
	kMeanInitialization_Spherical_Random_inUnitSphere
} kMeanInitialization;

typedef enum {
	kClusteringType_KMean,
	kClusteringType_KMedoid,
	kClusteringType_KHistogram
} kClusteringType;

typedef enum {
	kTrainingSetDetermination_Random_inPercent,	
	kTrainingSetDetermination_MonteCarlo,
	kTrainingSetDetermination_KFold,
	kTrainingSetDetermination_KFold2,
	kTrainingSetDetermination_LeaveOneOut,
	kTrainingSetDetermination_Test64
} kTrainingSetDetermination;

static kMeanInitialization K_KMEAN_INITIALIZATION = kMeanInitialization_Spherical_Random_inRange;
static DataSetDirectoryType K_DATASET_TYPE = DataSetDirectory_FromDisk;
static FilterType K_FILTER_TYPE = FilterType_LowPass;
static kTrainingSetDetermination K_DATASET_DETERMINATION = kTrainingSetDetermination_KFold;
static kClusteringType K_CLUSTER_TYPE = kClusteringType_KMean;


static NSString *const K_DIRECTORYNAME_RAW_DATA = @"%@/DataSet/";
static NSString *const K_DIRECTORYNAME_CURRENTAPP = @"MatlabPreperation/build/Debug/MatlabPreperation.app/";
static NSString *const K_DIRECTORYNAME_CLUSTER_DATA = @"%@/CorrectedData/dataForMatlab_states/";

static NSString *const K_DIRECTORYNAME_01_RAWDATA = @"%@/CorrectedData/data_Raw/";
static NSString *const K_DIRECTORYNAME_02_FILTERED = @"%@/CorrectedData/data_After_Filter/";
static NSString *const K_DIRECTORYNAME_03_ROTATION = @"%@/CorrectedData/data_After_Rotation/";
static NSString *const K_DIRECTORYNAME_04_NOISEELIMINATION = @"%@/CorrectedData/data_After_NoiseElimination/";
static NSString *const K_DIRECTORYNAME_05_QUANTIZATION = @"%@/CorrectedData/data_After_Quantization/";
static NSString *const K_DIRECTORYNAME_06_CLUSTERING = @"%@/CorrectedData/data_After_Clustering/";
static NSString *const K_DIRECTORYNAME_07_SAMPLING = @"%@/CorrectedData/data_After_Sampling/";


#define K_IS_FILTER_ON 1
#define K_USE_ROTATION_OPERATION 1
#define K_USE_NOISEELIMINATION_OPERATION 1
#define K_USE_QUANTIZATION_OPERATION 1
#define K_USE_TIMEAVERAGING_OPERATION 0
#define K_USE_CLUSTERING_OPERATION 1 
#define K_USE_SAMPLING_OPERATION 1

#define K_IS_DTW_FOR_DIRECT_EUCLIDIAN 0 //else differentiate it 

#define K_IS_ADAPTIVE_FILTER 1
#define K_UPDATE_FREQUENCY 60.0f
#define K_CUTOFF_FREQUENCY 5.0f
#define K_ACCELEROMETER_MIN_STEP		0.02
#define K_ACCELEROMETER_NOISE_ATTENUATION	2.0


#define K_ROTATION_INITIAL_POSITION_PERCENT 0.08f   //First %10 data get for initial position
#define K_ROTATION_INITIAL_X 0.0f
#define K_ROTATION_INITIAL_Y -1.0f
#define K_ROTATION_INITIAL_Z 0.0f

#define K_TIMEAVERAGING_TIMEQUANT 5 

#define K_QUANTIZATION_X_QUANT 0.3f  // Used for determining the state number.
#define K_QUANTIZATION_Y_QUANT 0.3f  // The value / Threshold as int gives the state value in int
#define K_QUANTIZATION_Z_QUANT 0.3f

#define K_QUANTIZATION_X_INIT 0.0f  
#define K_QUANTIZATION_Y_INIT -1.0f 
#define K_QUANTIZATION_Z_INIT 0.0f 


#define TRESHOLD_MIN_ELEMENT_COUNT_IN_DATA (K_UPDATE_FREQUENCY * 0.3)  //Each gesture should finished at least in 0.3 second
#define TRESHOLD_MAX_ELEMENT_COUNT_IN_DATA (K_UPDATE_FREQUENCY * 2.6)  //Each gesture should finished at most in 1.6 second

#define K_KMEAN_CLUSTERNUMBER 20
#define K_KMEAN_DIMENSION 3 //x y z 

#define K_KMEAN_RANGE_X_MIN -1.0f //should be -1 to 1 if spherical x and y values => z is determining according to them
#define K_KMEAN_RANGE_X_MAX 1.0f
#define K_KMEAN_RANGE_Y_MIN -1.0f
#define K_KMEAN_RANGE_Y_MAX 1.0f
#define K_KMEAN_RANGE_Z_MIN -1.0f
#define K_KMEAN_RANGE_Z_MAX 1.0f

#define K_TRAINING_FOREACH_MAINGESTURE 1 //if 1 -> for each 7 main gesture the training data generated else for each 52 gesture
#define K_TRAINING_SET_PERCENT 0.8f
#define K_TRAINING_SET_K_NUMBER 10
#define K_TRAINING_SET_CURRENT_K_NUMBER 1


// #define K_CLUSTER_SEQUENCE_SKIP 3 // write 1 in each 3 squence step j = j + K_CLUSTER_SEQUENCE_SKIP in string convertion of squence
#define K_SAMPLE_SEQUENCE_LENGTH 20 // each squence should be in the same lenth
#define K_IS_SAMEDIRECTORY 1

//#define K_VALIDATION_SET_PERCENT 0.0f
//#define K_TEST_SET_PERCENT 0.2f
#define K_HMM_CLASS_NUMBER 13

#define K_ROTATION_POSSIBLE_NUMBER 512 //8 x 8 x 8 -> along x , y, z axis by 8 on each axis

#define K_DISTANCE_PRIORITY_X 1
#define K_DISTANCE_PRIORITY_Y 1
#define K_DISTANCE_PRIORITY_Z 1

 */

#define K_UPDATE_FREQUENCY 60.0f
