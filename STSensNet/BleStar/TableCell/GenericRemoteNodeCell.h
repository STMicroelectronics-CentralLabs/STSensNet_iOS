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

#import "EnviromentalRemoteNodeCell.h"
#import "GenericRemoteNodeData.h"

/**
 *  protocol where the cell will notify a change in the led switch
 */
@protocol GenericRemoteNodeCellChanges <NSObject>

/**
 *  method called when the user change proximity notification status
 *
 *  @param nodeId remote node that change the proximity notification status
 *  @param state  new notification state
 */
-(void)proximtiyNotificationDidChangeForNodeId:(uint16_t)nodeId newState:(bool)state;

/**
 *  method called when the user change the mic level notification status
 *
 *  @param nodeId remote node that change the mic level notification status
 *  @param state  new notification state
 */
-(void)micLevelNotificationDidChangeForNodeId:(uint16_t)nodeId newState:(bool)state;

@end

/**
 * class that will manage the data from a remote node with the proximity, mic level
 * and last moviment event
 **/
@interface GenericRemoteNodeCell : EnviromentalRemoteNodeCell

/**
 * object where notify if the user enable some notification
 */
@property id<GenericRemoteNodeCellChanges> genericDelegate;

/**
 set the out of bound value to use when display the data
 
 @param value out of bound value
 */
+(void)setProximityOutOfRangeValue:(uint16_t)value;

/**
 set the maximum value read from the sensor
 
 @param value maximum value read from the sensor
 */
+(void)setProximityMaxValue:(uint16_t)value;


/**
 * Set the proximity unit
 * @param unit proximity data unit
 */
+(void)setProximityUnit:(NSString*)unit;


/**
 * Set the mic level max value
 * @param value mic level max value
 */
+(void)setMicLevelMaxValue:(uint16_t)value;

/**
 * set the mic level unit
 * @param unit mic level unit
 */
+(void)setMicLevelUnit:(NSString*)unit;

/* 
 * update the gui for display the remote node data
 *  @param data data to display in this cell
 */
-(BOOL)updateContent:(GenericRemoteNodeData*)data;
@end
