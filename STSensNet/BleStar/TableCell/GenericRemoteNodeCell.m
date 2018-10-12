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

#import "GenericRemoteNodeCell.h"

#define DETECT_MOVIMENT @"Moved: %@"

#define OUT_OF_BAND @"Out Of Range"

static uint16_t sOutOfRangeValue;
static uint16_t sProximityMaxValue;
static NSString *sProximityUnit;
static uint16_t sMicLevelMaxValue;
static NSString *sMicLevelUnit;

@implementation GenericRemoteNodeCell{
    
    __weak IBOutlet UIView *mMovimentView;
    __weak IBOutlet UILabel *mMovimentLabel;
    NSTimeInterval mLastMotionEvent;
    
    __weak IBOutlet UIView *mProximityView;
    __weak IBOutlet UIProgressView *mProximityProgres;
    __weak IBOutlet UILabel *mProximityLabel;
    __weak IBOutlet UISwitch *mProximitySwich;
    
    __weak IBOutlet UIView *mMicLevelView;
    __weak IBOutlet UILabel *mMicLevelLabel;
    __weak IBOutlet UIProgressView *mMicLevelProgres;
    __weak IBOutlet UISwitch *mMicLevelSwitch;
    
    
}
- (IBAction)changeProximityNotificationStatus:(UISwitch *)sender {
    [_genericDelegate proximtiyNotificationDidChangeForNodeId: self.nodeId newState:sender.isOn];
}

- (IBAction)changeMicLevelNotificationStatus:(UISwitch *)sender {
    [_genericDelegate micLevelNotificationDidChangeForNodeId: self.nodeId newState:sender.isOn];
}

+ (void) shakeView:(UIView*)view {
    static NSString *animationKey = @"Shake";
    {
        CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"transform.translation.x"];
        animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
        animation.duration = 0.3;
        animation.values = @[ @(-20), @(20), @(-20), @(20), @(-10), @(10), @(-5), @(5), @(0) ];
        [view.layer addAnimation:animation forKey:animationKey];
    }
}

-(void)updateLastMoviment:(NSTimeInterval)lastDetectedEvent{
    mMovimentView.hidden=(lastDetectedEvent<0);
    if(lastDetectedEvent<0)
        return;
    
    NSDate *lastMoviment = [NSDate dateWithTimeIntervalSinceReferenceDate:lastDetectedEvent];
    NSString *timeStr = [NSDateFormatter localizedStringFromDate:lastMoviment
                                                       dateStyle:NSDateFormatterNoStyle
                                                       timeStyle:NSDateFormatterMediumStyle];
    
    mMovimentLabel.text = [NSString stringWithFormat:DETECT_MOVIMENT,timeStr];
    
    //its a new event != from the previuous one
    if(mLastMotionEvent>0 && mLastMotionEvent!=lastDetectedEvent){
        [GenericRemoteNodeCell shakeView:mMovimentView];
    }
    mLastMotionEvent=lastDetectedEvent;
    
}

-(void)updateProximityValue:(int32_t)proximity isLowRange:(BOOL)isLowRange{
    BOOL priximitIsMissing =(proximity<0);
    mProximityView.hidden=priximitIsMissing;

    if(priximitIsMissing)
        return;

    if(proximity!=sOutOfRangeValue){
        mProximityProgres.progress = proximity/(float)sProximityMaxValue;
        mProximityLabel.text = [NSString stringWithFormat:@"%4d (%@)",proximity,sProximityUnit];
        mProximityProgres.hidden=!isLowRange;
    }else{
        mProximityProgres.hidden=true;
        mProximityLabel.text=OUT_OF_BAND;
    }

}

-(void)updateMicLevelValue:(int16_t)micLevel{
    BOOL micIsMissing = (micLevel<0);
    mMicLevelView.hidden=micIsMissing;
    mMicLevelProgres.hidden=micIsMissing;
    if(micIsMissing)
        return;
    mMicLevelProgres.hidden=false;
    mMicLevelProgres.progress = micLevel/(float)sMicLevelMaxValue;
    mMicLevelLabel.text = [NSString stringWithFormat:@"%4d (%@)",micLevel,sMicLevelUnit];
}

-(BOOL)updateContent:(GenericRemoteNodeData*)data{
    BOOL nodeChanges =[super updateContent:data];
    if(nodeChanges)
        mLastMotionEvent=-1;
    
    [self updateLastMoviment:data.lastMotionEvent];
    [self updateProximityValue:data.proximity isLowRange:data.isLowRangeProximity];
    [mProximitySwich setOn:data.isProximityEnabled];
    
    [self updateMicLevelValue:data.micLevel];
    [mMicLevelSwitch setOn:data.isMicLevelEnabled];
    return nodeChanges;
}



+(void)setProximityOutOfRangeValue:(uint16_t)value{
    sOutOfRangeValue = value;
}

+(void)setProximityMaxValue:(uint16_t)value{
    sProximityMaxValue = value;
}

+(void)setProximityUnit:(NSString*)unit{
    sProximityUnit = unit;
}

+(void)setMicLevelMaxValue:(uint16_t)value{
    sMicLevelMaxValue = value;
}

+(void)setMicLevelUnit:(NSString*)unit{
    sMicLevelUnit = unit;
}



@end
