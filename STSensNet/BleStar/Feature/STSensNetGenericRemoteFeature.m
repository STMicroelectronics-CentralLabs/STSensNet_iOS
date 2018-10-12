/*
 * Copyright (c) 2017  STMicroelectronics – All rights reserved
 * The STMicroelectronics corporate logo is a trademark of STMicroelectronics
 *
 * Redistribution and use in source and binary forms, with or without modification,
 * are permitted provided that the following conditions are met:
 *
 * - Redistributions of source code must retain the above copyright notice, this list of conditions
 *   and the following disclaimer.
 *
 * - Redistributions in binary form must reproduce the above copyright notice, this list of
 *   conditions and the following disclaimer in the documentation and/or other materials provided
 *   with the distribution.
 *
 * - Neither the name nor trademarks of STMicroelectronics International N.V. nor any other
 *   STMicroelectronics company nor the names of its contributors may be used to endorse or
 *   promote products derived from this software without specific prior written permission.
 *
 * - All of the icons, pictures, logos and other images that are provided with the source code
 *   in a directory whose title begins with st_images may only be used for internal purposes and
 *   shall not be redistributed to any third party or modified in any way.
 *
 * - Any redistributions in binary form shall not include the capability to display any of the
 *   icons, pictures, logos and other images that are provided with the source code in a directory
 *   whose title begins with st_images.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR
 * IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY
 * AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER
 * OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
 * THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
 * OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY
 * OF SUCH DAMAGE.
 */

#include <limits.h>
#include <float.h>
#include "STSensNetGenericRemoteFeature.h"

#import <BlueSTSDK/BlueSTSDKFeature_pro.h>
#import <BlueSTSDK/BlueSTSDKFeatureField.h>
#import <BlueSTSDK/NSData+NumberConversion.h>

///// type id used for undesteand what value read next
#define  TYPE_ID_PRESSURE 0x01
#define  TYPE_ID_HUMIDITY 0x02
#define  TYPE_ID_TEMPERATURE 0x03
#define  TYPE_ID_LED_STATUS 0x04
#define  TYPE_ID_PROXIMITY 0x05
#define  TYPE_ID_MOTION_DETECTION 0x06
#define  TYPE_ID_MIC_LEVEL 0x07
#define  TYPE_ID_LUMINOSITY 0x08

#define FEATURE_NAME @"Generic Remote"

#define REMOTE_NODE_ID_INDEX 0
#define REMOTE_NODE_ID_NAME @"Node Id"
#define REMOTE_NODE_ID_UNIT nil
#define REMOTE_NODE_ID_DATA_MAX ((1<<16)-1)
#define REMOTE_NODE_ID_DATA_MIN  0

#define PRESSURE_INDEX 1
#define PRESSURE_DATA_NAME @"Pressure"
#define PRESSURE_UNIT @"mBar"
#define PRESSURE_DATA_MAX 2000
#define PRESSURE_DATA_MIN 0

#define  TEMPERATURE_INDEX 2
#define TEMPERATURE_DATA_NAME @"Temperature"
// celsius degree
#define TEMPERATURE_UNIT @"\u2103"
#define TEMPERATURE_DATA_MAX 100
#define TEMPERATURE_DATA_MIN 0

#define HUMIDITY_INDEX 3
#define HUMIDITY_DATA_NAME @"Humidity"
#define HUMIDITY_UNIT @"%"
#define HUMIDITY_DATA_MAX 100
#define HUMIDITY_DATA_MIN 0

#define LED_INDEX 4
#define LED_NAME @"LED"
#define LED_UNIT nil
#define LED_DATA_NAME @"Status"
#define LED_DATA_MAX 1
#define LED_DATA_MIN 0

#define PROXIMITY_INDEX 5
#define PROXIMITY_DATA_NAME @"Proximity"
#define PROXIMITY_UNIT  @"mm"
#define  PROXIMITY_DATA_MAX  254
#define  PROXIMITY_DATA_MIN 0
#define  PROXIMITY_OUT_OF_RANGE_VALUE 0xFFFF

#define  MOTION_DETECTION_INDEX 6
#define  MOTION_DETECTION_DATA_NAME @"Last Moviment"
#define  MOTION_DETECTION_UNIT  @"s"
#define  MOTION_DETECTION_DATA_MAX DBL_MAX
#define  MOTION_DETECTION_DATA_MIN -1

#define  MIC_LEVEL_INDEX 7
#define  MIC_LEVEL_DATA_NAME @"Mic Level"
#define  MIC_LEVEL_UNIT  @"db"
#define  MIC_LEVEL_DATA_MAX 255
#define  MIC_LEVEL_DATA_MIN 0

#define  LUX_INDEX 8
#define  LUX_DATA_NAME @"Lux"
#define  LUX_UNIT  @"Lux"
#define  LUX_DATA_MAX (1<<16)
#define  LUX_DATA_MIN 0

#define PROXIMITY_TYPE_INDEX 9

/**
 * @memberof STSensNetGenericRemoteFeature
 *  array with the description of field exported by the feature
 */
static NSArray<BlueSTSDKFeatureField*> *sFieldDesc;

@implementation STSensNetGenericRemoteFeature

+(void)initialize{
    if(self == [STSensNetGenericRemoteFeature class]){
        sFieldDesc = @[[BlueSTSDKFeatureField  createWithName:REMOTE_NODE_ID_NAME
                                                         unit:REMOTE_NODE_ID_UNIT
                                                         type:BlueSTSDKFeatureFieldTypeUInt16
                                                          min:@REMOTE_NODE_ID_DATA_MIN
                                                          max:@REMOTE_NODE_ID_DATA_MIN],
                       
                       [BlueSTSDKFeatureField  createWithName:PRESSURE_DATA_NAME
                                                         unit:PRESSURE_UNIT
                                                         type:BlueSTSDKFeatureFieldTypeFloat
                                                          min:@PRESSURE_DATA_MAX
                                                          max:@PRESSURE_DATA_MIN],
                       
                       [BlueSTSDKFeatureField  createWithName:TEMPERATURE_DATA_NAME
                                                         unit:TEMPERATURE_UNIT
                                                         type:BlueSTSDKFeatureFieldTypeFloat
                                                          min:@TEMPERATURE_DATA_MAX
                                                          max:@TEMPERATURE_DATA_MIN],
                       
                       [BlueSTSDKFeatureField  createWithName:HUMIDITY_DATA_NAME
                                                         unit:HUMIDITY_UNIT
                                                         type:BlueSTSDKFeatureFieldTypeFloat
                                                          min:@HUMIDITY_DATA_MAX
                                                          max:@HUMIDITY_DATA_MIN],
                       
                       [BlueSTSDKFeatureField  createWithName:HUMIDITY_DATA_NAME
                                                         unit:HUMIDITY_UNIT
                                                         type:BlueSTSDKFeatureFieldTypeFloat
                                                          min:@HUMIDITY_DATA_MAX
                                                          max:@HUMIDITY_DATA_MIN],
                       
                       [BlueSTSDKFeatureField  createWithName:LED_DATA_NAME
                                                         unit:LED_UNIT
                                                         type:BlueSTSDKFeatureFieldTypeUInt8
                                                          min:@LED_DATA_MAX
                                                          max:@LED_DATA_MIN],
                       
                       [BlueSTSDKFeatureField  createWithName:PROXIMITY_DATA_NAME
                                                         unit:PROXIMITY_UNIT
                                                         type:BlueSTSDKFeatureFieldTypeUInt16
                                                          min:@PROXIMITY_DATA_MAX
                                                          max:@PROXIMITY_DATA_MIN],
                       
                       [BlueSTSDKFeatureField  createWithName:MOTION_DETECTION_DATA_NAME
                                                         unit:MOTION_DETECTION_UNIT
                                                         type:BlueSTSDKFeatureFieldTypeDouble
                                                          min:@MOTION_DETECTION_DATA_MAX
                                                          max:@MOTION_DETECTION_DATA_MIN],
                       
                       [BlueSTSDKFeatureField  createWithName:MIC_LEVEL_DATA_NAME
                                                         unit:MIC_LEVEL_UNIT
                                                         type:BlueSTSDKFeatureFieldTypeInt16
                                                          min:@MIC_LEVEL_DATA_MAX
                                                          max:@MIC_LEVEL_DATA_MIN],

                       [BlueSTSDKFeatureField  createWithName:LUX_DATA_NAME
                                                         unit:LUX_UNIT
                                                         type:BlueSTSDKFeatureFieldTypeUInt16
                                                          min:@LUX_DATA_MAX
                                                          max:@LUX_DATA_MIN],

                       
                       ];
    }//if
}//initialize


-(instancetype) initWhitNode:(BlueSTSDKNode *)node{
    self = [super initWhitNode:node name:FEATURE_NAME];
    return self;
}

-(NSArray*) getFieldsDesc{
    return sFieldDesc;
}

/**
 *  read int16 for build the humidity value, create the new sample and
 * and notify it to the delegate
 *
 *  @param timestamp data time stamp
 *  @param rawData   array of byte send by the node
 *  @param offset    offset where we have to start reading the data
 *
 *  @throw exception if there are no 2 bytes available in the rawdata array
 *  @return humidity + number of read bytes (2)
 */
-(BlueSTSDKExtractResult*) extractData:(uint64_t)timestamp data:(NSData*)rawData dataOffset:(uint32_t)offset{
    
    
    if (rawData.length-offset < 3) //2 (node Id)+1 (type id)
        @throw [NSException
                exceptionWithName:@"Invalid Generic Remote data"
                reason:@"There are no 3 bytes available to read"
                userInfo:nil];
    
    float pressure=NAN;
    float temperature=NAN;
    float humidity=NAN;
    int8_t ledStatus=-1;
    int proximity=-1;
    bool isLowRangeProximity=true;
    double movimentDetection=-1;
    int16_t micLevel=-1;
    int luxValue=-1;
    
    uint32_t readData = offset;
    
    int nodeID = [rawData extractLeUInt16FromOffset:readData];
    
    readData+=2;
    
    BOOL validDataId =true;
    while (validDataId && readData<rawData.length){
        switch ([rawData extractUInt8FromOffset:readData]){
            case TYPE_ID_PRESSURE:
                pressure= [rawData extractLeInt32FromOffset:readData+1]/100.0f;
                readData+=4;
                break;
            case TYPE_ID_TEMPERATURE:
                temperature = [rawData extractLeInt16FromOffset:readData+1]/10.0f;
                readData+=2;
                break;
            case TYPE_ID_HUMIDITY:
                humidity = [rawData extractLeInt16FromOffset:readData+1]/10.0f;
                readData+=2;
                break;
            case TYPE_ID_LED_STATUS:
                ledStatus= [rawData extractInt8FromOffset:readData+1];
                readData++;
                break;
            case TYPE_ID_PROXIMITY:
                proximity = [rawData extractLeUInt16FromOffset:readData+1];
                isLowRangeProximity = isLowRangeSensor(proximity);
                proximity = extractLuxValue(proximity);
                readData+=2;
                break;
            case TYPE_ID_MOTION_DETECTION:
                movimentDetection = [NSDate timeIntervalSinceReferenceDate];
                break;
            case TYPE_ID_MIC_LEVEL:
                micLevel= [rawData extractInt8FromOffset:readData+1];
                readData++;
                break;
            case TYPE_ID_LUMINOSITY:
                luxValue= [rawData extractLeUInt16FromOffset:readData+1];
                readData+=2;
                break;
            default://else
                validDataId=false;
        }
        readData++; //+1 for the typeid
    }
    
    NSArray *data = @[@(nodeID),@(pressure),@(temperature),
                      @(humidity),@(ledStatus),@(proximity),
                      @(movimentDetection),@(micLevel),@(luxValue),@(isLowRangeProximity)];
    
    BlueSTSDKFeatureSample *sample =
    [BlueSTSDKFeatureSample sampleWithTimestamp:timestamp data:data ];
    return [BlueSTSDKExtractResult resutlWithSample:sample nReadData:readData-offset];
    
}

#define LOW_RANGE_DATA_MAX 0x00FE
#define HIGH_RANGE_DATA_MAX 0X7FFE

static bool isLowRangeSensor(int value){
    return (value & 0x8000)==0;
}

static int getRangeValue(int value){
    return (value & ~0x8000);
}
static int extarctLowRagngeData(int value){
    int rangeValue = getRangeValue(value);
    if(rangeValue > LOW_RANGE_DATA_MAX){
        rangeValue = PROXIMITY_OUT_OF_RANGE_VALUE;
    }
    
    return rangeValue;
}

static int extarctHightRagngeData(int value){
    int rangeValue = getRangeValue(value);
    if(rangeValue > HIGH_RANGE_DATA_MAX){
        rangeValue = PROXIMITY_OUT_OF_RANGE_VALUE;
    }
    return rangeValue;
}

static int extractLuxValue(int rawValue){
    
    if(isLowRangeSensor(rawValue)){
        return extarctLowRagngeData(rawValue);
    }//else
    return extarctHightRagngeData(rawValue);
}

+(uint16_t)getNodeId:(BlueSTSDKFeatureSample *)sample{
    if(sample.data.count<REMOTE_NODE_ID_INDEX)
        return -1;
    return[[sample.data objectAtIndex:REMOTE_NODE_ID_INDEX] floatValue];
}

+(float)getTemperature:(BlueSTSDKFeatureSample *)sample{
    if(sample.data.count<TEMPERATURE_INDEX)
        return NAN;
    return[[sample.data objectAtIndex:TEMPERATURE_INDEX] floatValue];
}

+(NSString*)getTemperatureUnit{
    return TEMPERATURE_UNIT;
}

+(float)getHumidity:(BlueSTSDKFeatureSample *)sample{
    if(sample.data.count<HUMIDITY_INDEX)
        return NAN;
    return[[sample.data objectAtIndex:HUMIDITY_INDEX] floatValue];
}

+(NSString*)getHumidityUnit{
    return HUMIDITY_UNIT;
}

+(float)getPressure:(BlueSTSDKFeatureSample *)sample{
    if(sample.data.count<PRESSURE_INDEX)
        return NAN;
    return[[sample.data objectAtIndex:PRESSURE_INDEX] floatValue];
}

+(NSString*)getPressureUnit{
    return PRESSURE_UNIT;
}

+(int32_t)getProximity:(BlueSTSDKFeatureSample *)sample{
    if(sample.data.count<PROXIMITY_INDEX)
        return -1;
    return [[sample.data objectAtIndex:PROXIMITY_INDEX] intValue];
}

+(BOOL)isLowRangeProximity:(BlueSTSDKFeatureSample *)sample{
    if(sample.data.count<PROXIMITY_TYPE_INDEX)
        return false;
    return [[sample.data objectAtIndex:PROXIMITY_TYPE_INDEX] boolValue];
}

+(NSString*)getProximityUnit{
    return PROXIMITY_UNIT;
}

+(uint16_t)getProximityMaxValue{
    return PROXIMITY_DATA_MAX;
}

+(uint16_t)getProximityOutOfRangeValue{
    return PROXIMITY_OUT_OF_RANGE_VALUE;
}

+(NSString*)getMicLevelUnit{
    return MIC_LEVEL_UNIT;
}

+(NSString*)getLuminosityUnit{
    return LUX_UNIT;
}

+(uint16_t)getMicLevelMaxValue{
    return MIC_LEVEL_DATA_MAX;
}

+(int8_t)getLedStatus:(BlueSTSDKFeatureSample *)sample{
    if(sample.data.count<LED_INDEX)
        return NAN;
    return[[sample.data objectAtIndex:LED_INDEX] floatValue];
}

+(NSTimeInterval)getLastMovimentDetected:(BlueSTSDKFeatureSample *)sample{
    if(sample.data.count<MOTION_DETECTION_INDEX)
        return -1;
    return [[sample.data objectAtIndex:MOTION_DETECTION_INDEX] doubleValue];
}


+(int16_t)getMicLevel:(BlueSTSDKFeatureSample *)sample{
    if(sample.data.count<MIC_LEVEL_INDEX)
        return -1;
    return[[sample.data objectAtIndex:MIC_LEVEL_INDEX] shortValue];
}

+(int)getLuminosity:(BlueSTSDKFeatureSample *)sample{
    if(sample.data.count<LUX_INDEX)
        return -1;
    return[[sample.data objectAtIndex:LUX_INDEX] intValue];
}

-(void)sendEnableCommand:(uint8_t)commandId nodeId:(uint16_t)nodeId
                  enable:(bool)enable{
    NSMutableData *msg = [NSMutableData data];
    nodeId = CFSwapInt16HostToBig(nodeId);
    uint8_t newStatus = enable ? 0x1 : 0x0;
    [msg appendBytes:&nodeId length:sizeof(nodeId)];
    [msg appendBytes:&commandId length:sizeof(commandId)];
    [msg appendBytes:&newStatus length:sizeof(newStatus)];
    [self writeData:msg];
}

-(void)setSwitchStatus:(uint16_t)nodeId newState:(bool)state{
    [self sendEnableCommand:TYPE_ID_LED_STATUS nodeId:nodeId enable:state];
}

-(void)enableProximityForNode:(uint16_t)nodeId enabled:(bool)state{
    [self sendEnableCommand:TYPE_ID_PROXIMITY nodeId:nodeId enable:state];
}

-(void)enableMicLevelForNode:(uint16_t)nodeId enabled:(bool)state{
    [self sendEnableCommand:TYPE_ID_MIC_LEVEL nodeId:nodeId enable:state];
}

@end
