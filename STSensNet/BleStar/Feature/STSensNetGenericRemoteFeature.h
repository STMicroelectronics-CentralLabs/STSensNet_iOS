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

#import <BlueSTSDK/BlueSTSDK.h>


/**
 * Feature that permit to send the remote data using a serial protocol
 */
@interface STSensNetGenericRemoteFeature : BlueSTSDKFeature


/**
 return the id of the node that generare the sample

 @param sample data sample

 @return node that generate this sample
 */
+(uint16_t) getNodeId:(BlueSTSDKFeatureSample*)sample;


/**
 extract the temperature data from the sample

 @param sample sample data sample

 @return temperature or NAN if not present
 */
+(float) getTemperature:(BlueSTSDKFeatureSample*)sample;


/**
 get the temperature unit

 @return temperature unit
 */
+(NSString*) getTemperatureUnit;


/**
 extract the humidity data from the sample
 
 @param sample sample data sample
 
 @return humidity or NAN if not present
 */
+(float)getHumidity:(BlueSTSDKFeatureSample *)sample;


/**
 get unit of the humidity value
 
 @return unit of the humidity value
 */
+(NSString*) getHumidityUnit;

/**
 extract the pressure data from the sample
 
 @param sample sample data sample
 
 @return pressure or NAN if not present
 */
+(float)getPressure:(BlueSTSDKFeatureSample *)sample;


/**
 get unit of the pressure value
 
 @return unit of the pressure value
 */
+(NSString*) getPressureUnit;


/**
 extract the led status from the sample
 
 @param sample sample data sample
 
 @return -1 unknown/not present, 0 = off 1 = on
 */
+(int8_t)getLedStatus:(BlueSTSDKFeatureSample *)sample;


/**
 extract the pressure data from the sample
 
 @param sample sample data sample
 
 @return pressure or NAN if not present
 */
+(int32_t)getProximity:(BlueSTSDKFeatureSample *)sample;

/**
 get unit of the proximity value

 @return unit of the proximity value
 */
+(NSString*)getProximityUnit;

/**
 * get the value with the meaning OutOfRange
 * @return value read when the distance is over the maximum
 */
+(uint16_t)getProximityOutOfRangeValue;

/**
 get the maximum value that the proximiy sensor can read
 @return maximum value that the sensnor can read
 */
+(uint16_t)getProximityMaxValue;
/**
 * @return true if the sample cames from a low range proximity sensor
 */
+(BOOL)isLowRangeProximity:(BlueSTSDKFeatureSample *)sample;
/**
 * get unit for the luminosity value
 * @return unit of the luminosity value
 */
+(NSString*)getLuminosityUnit;

/**
 *get the luminosity value

 * @param sample data sample
 * @return luminosity value of a negative number if not present
 */
+(int)getLuminosity:(BlueSTSDKFeatureSample *)sample;

/**
 * get the maximum value for the mic level sensor
 * @return maximum value for the mic level sensor
 */
+(uint16_t)getMicLevelMaxValue;


/**
 * get the mic level data unit
 * @return mic level data unit
 */
+(NSString*)getMicLevelUnit;


/**
 * get the mic level value
 * @param sample data sample
 * @return mic level detected or a negative value if not present
 */
+(int16_t) getMicLevel:(BlueSTSDKFeatureSample*)sample;

/**
 * extract the time of the last detected moviment from the sample
 * @param sample data sample
 * @return negative number if unknow otherwise when it was detected (seconds after the 1Jan2001
 */
+(NSTimeInterval)getLastMovimentDetected:(BlueSTSDKFeatureSample *)sample;


/**
 * change the status of the remote switch
 *
 * @param nodeId node where send the message
 * @param state  new switch state
 */
-(void)setSwitchStatus:(uint16_t)nodeId newState:(bool)state;

/**
 * enable the notification for receive the proximity values
 *
 * @param nodeId id of the remote node where enable the notification
 * @param state true for enable the notification, false for disalbe it
 */
-(void)enableProximityForNode:(uint16_t)nodeId enabled:(bool)state;

/**
 * enable the notification for receive the mic level values
 *
 * @param nodeId if of the remote node where enable the notificaiton
 * @param state true for enable the notification, false for disable it
 */
-(void)enableMicLevelForNode:(uint16_t)nodeId enabled:(bool)state;


@end
