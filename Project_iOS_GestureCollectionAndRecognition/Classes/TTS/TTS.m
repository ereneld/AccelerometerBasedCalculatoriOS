//
//  TTS.m
//  GestureDataWithRecognition
//
//  Created by dogukan ibrahimoglu on 5/1/11.
//  Copyright 2011 Bogazici University. All rights reserved.
//

#import "TTS.h"

static FliteTTS* instanceObjectTTS; //singleton object

@implementation TTS

+(FliteTTS*) getTTS{
    if (!instanceObjectTTS) {
        instanceObjectTTS = [[FliteTTS alloc]init];
        //[instanceObjectTTS setPitch:125.0 variance:11.0 speed:1.1];
        //[instanceObjectTTS setVoice:@"cmu_us_kal"]; //cmu_us_kal16 cmu_us_rms cmu_us_awb cmu_us_slt
    }
    return instanceObjectTTS;
}

+(void)startSpeakText:(NSString *)textToSpeak{
    FliteTTS* currentTTS = [TTS getTTS];
    if (currentTTS) {
        [currentTTS speakText:textToSpeak];
    }
}

+(void)stopSpeaking{
    FliteTTS* currentTTS = [TTS getTTS];
    if (currentTTS) {
        [currentTTS stopTalking];
    }
}


@end
