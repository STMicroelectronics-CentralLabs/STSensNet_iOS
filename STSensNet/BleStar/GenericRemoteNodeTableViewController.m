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


#import "BlueSTSDK/BlueSTSDKNode.h"
#import "BlueSTSDK_Gui/MBProgressHUD.h"

#import "Feature/STSensNetGenericRemoteFeature.h"
#import "Feature/STSensNetCommandFeature.h"

#import "GenericRemoteNodeTableViewController.h"

#import "TableCell/GenericRemoteNodeCell.h"

#import "Data/EnviromentalRemoteNodeData.h"
#import "Data/GenericRemoteNodeData.h"

#define BIG_ROW_HEIGHT 256.0f
#define SMALL_ROW_HEIGHT 128.0f

#define CANCEL_NAME @"Cancel"
#define START_SCANNING_NAME @"Start Scanning"
#define STOP_SCANNING_NAME @"Stop Scanning"
#define SCANNING_START_NAME @"Scanner Starterd"
#define SCANNING_STOP_NAME @"Scanner Stopped"


@interface GenericRemoteNodeTableViewController ()<UITableViewDataSource,UITableViewDelegate,
    BlueSTSDKFeatureDelegate, EnviromentalRemoteNodeCellChanges,
    GenericRemoteNodeCellChanges,STSensNetCommandFeatureCallback>

   /**
    *  table where show the remote nodes
    */
    @property (weak, nonatomic) IBOutlet UITableView *tableView;

@end


@implementation GenericRemoteNodeTableViewController{

    /**
     *  list of remote node data
     */
    NSMutableArray<GenericRemoteNodeData*> *mRemoteNodes;
    
    
    /**
     *  feature for switch the led status
     */
    STSensNetGenericRemoteFeature *mRemoteFeature;
    
    /**
     * Feature where send the command for start/stop scanning
     */
    STSensNetCommandFeature *mCommand;
    
    /**
     * action that start the scanning for new nodes
     */
    UIAlertAction *mStartScanningAction;
    /**
     * action that stop the scanning for new nodes
     */
    UIAlertAction *mStopScanningAction;
    
    /**
     * true if the user has select a start or stop action ->
     * the app will show a feedback message
     */
    BOOL mUserChangeScanningState;
    
    /**
     * id of the current node that has the proximity notification enabled
     * or a negative number if none is sending notification
     */
    int32_t mLastEnabledProx;
    
    /**
     * id of the current node that has the micropohone level notification enabled
     * or a negative number if none is sending notification
     */
    int32_t mLastEnabledMic;
    
}

/**
 *  get the last data received by the node, it the node is new we create an empty
 * class
 *
 *  @param nodeId nodeId to search
 *
 *  @return data associated to that node
 */
-(GenericRemoteNodeData*) getNodeData:(uint16_t)nodeId{
    
    @synchronized (mRemoteNodes) {
        for(unsigned long i=0;i<mRemoteNodes.count;i++){
            GenericRemoteNodeData *data = [mRemoteNodes objectAtIndex:i];
            if(data.nodeId==nodeId){
                return data;
            }//if
        }
        //else, it's a new node
        //create a new remote node data
        GenericRemoteNodeData *data =
        [GenericRemoteNodeData initWithNodeId:nodeId];
        
        [mRemoteNodes addObject:data];
        
        return data;
    }
    
}


/**
 * Set the unit string needed for the eviromental row
 */
-(void)setUpEnviromentalCell{
    [EnviromentalRemoteNodeCell setTemperatureUnit:
     [STSensNetGenericRemoteFeature getTemperatureUnit]];
    [EnviromentalRemoteNodeCell setPressureUnit:
     [STSensNetGenericRemoteFeature getPressureUnit]];
    [EnviromentalRemoteNodeCell setHumidityUnit:
     [STSensNetGenericRemoteFeature getHumidityUnit]];
    [EnviromentalRemoteNodeCell setLuminosityUnit:
     [STSensNetGenericRemoteFeature getLuminosityUnit]];
    
}


/**
 * Set the unit string neede for the generic node row
 */
-(void)setUpGenericCell{
    [GenericRemoteNodeCell setProximityUnit:
     [STSensNetGenericRemoteFeature getProximityUnit]];
    [GenericRemoteNodeCell setProximityMaxValue:
     [STSensNetGenericRemoteFeature getProximityMaxValue]];
    [GenericRemoteNodeCell setProximityOutOfRangeValue:
     [STSensNetGenericRemoteFeature getProximityOutOfRangeValue] ];
    [GenericRemoteNodeCell setMicLevelUnit:
     [STSensNetGenericRemoteFeature getMicLevelUnit]];
    [GenericRemoteNodeCell setMicLevelMaxValue:
     [STSensNetGenericRemoteFeature getMicLevelMaxValue]];
}

/**
 *  set the set the control view as table source data
 */
- (void)viewDidLoad {
    [super viewDidLoad];
    mRemoteNodes = [NSMutableArray array];
    self.tableView.dataSource=self;
    self.tableView.delegate=self;
    self.tableView.rowHeight=UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight=192.0;
    
    [self setUpEnviromentalCell];
    [self setUpGenericCell];
    
    mStartScanningAction = [UIAlertAction actionWithTitle:START_SCANNING_NAME
                                                    style:UIAlertActionStyleDefault
                                                  handler:^(UIAlertAction *action) {
                                                      [self onStartScanningActionPressed]; }];
    
    mStopScanningAction = [UIAlertAction actionWithTitle:STOP_SCANNING_NAME
                                                   style:UIAlertActionStyleDefault
                                                 handler:^(UIAlertAction *action) {
                                                     [self onStopScanningActionPressed];}];
}

/**
 *  retrive and enable the feature needed for the demo
 */
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    mRemoteFeature =(STSensNetGenericRemoteFeature*)
        [self.node getFeatureOfType:STSensNetGenericRemoteFeature.class];
    if(mRemoteFeature!=nil){
        [mRemoteFeature addFeatureDelegate:self];
        [self.node enableNotification:mRemoteFeature];
    }//if
 
    mCommand = (STSensNetCommandFeature*)
        [self.node getFeatureOfType:STSensNetCommandFeature.class];
    if(mCommand!=nil){
        [mCommand setDelegate:self];
        [self.node enableNotification:mCommand];
        [_menuDelegate addMenuAction:mStartScanningAction];
    }
    
    mLastEnabledProx=-1;
    mLastEnabledMic=-1;
    
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    
    if(mRemoteFeature!=nil){
        [mRemoteFeature removeFeatureDelegate:self];
        [self.node disableNotification:mRemoteFeature];
    }
    
    if(mCommand!=nil){
        [mCommand setDelegate:nil];
        [self.node disableNotification:mCommand];
    }

}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return mRemoteNodes.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}


/**
 create/retrive a row that can display the enviromental data

 @param tableView table where the row will be displayed
 @param indexPath position inside the table
 @param data      data to display

 @return row that display the enviromental data
 */
-(UITableViewCell *) buildGenericRemoteCell:(UITableView *)tableView
                     cellForRowAtIndexPath:(NSIndexPath *)indexPath
                                  withData:(GenericRemoteNodeData *)data{
    
    GenericRemoteNodeCell *cell = (GenericRemoteNodeCell*)
    [tableView dequeueReusableCellWithIdentifier:@"GenericRemoteNodeCell" forIndexPath:indexPath];
    
    cell.envDelegate=self;
    cell.genericDelegate=self;
    
    [cell updateContent:data];
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    GenericRemoteNodeData *data =[mRemoteNodes objectAtIndex:indexPath.section];
    return [self buildGenericRemoteCell:tableView cellForRowAtIndexPath:indexPath withData:data];
}



#pragma mark - BlueSTSDKFeatureDelegate

/**
 *  update the node data and reload the table data
 *
 *  @param feature feature tha has an update
 *  @param sample  new data sample
 */
- (void)didUpdateFeature:(BlueSTSDKFeature *)feature sample:(BlueSTSDKFeatureSample *)sample{

    uint16_t nodeId =[STSensNetGenericRemoteFeature getNodeId:sample];
    
    //update the remote data struct
    GenericRemoteNodeData *data = [self getNodeData:nodeId];
    data.temperature = [STSensNetGenericRemoteFeature getTemperature:sample];
    data.pressure = [STSensNetGenericRemoteFeature getPressure:sample];
    data.humidity = [STSensNetGenericRemoteFeature getHumidity:sample];
    data.ledStatus = [STSensNetGenericRemoteFeature getLedStatus:sample];
    data.lastMotionEvent = [STSensNetGenericRemoteFeature getLastMovimentDetected:sample];
    data.proximity = [STSensNetGenericRemoteFeature getProximity:sample];
    data.isLowRangeProximity = [STSensNetGenericRemoteFeature isLowRangeProximity:sample];
    data.micLevel = [STSensNetGenericRemoteFeature getMicLevel:sample];
    data.luminosity = [STSensNetGenericRemoteFeature getLuminosity:sample];
    
    dispatch_sync(dispatch_get_main_queue(),^{
        CGPoint offset = self.tableView.contentOffset;
        [self.tableView reloadData];
        [self.tableView layoutIfNeeded];
        [self.tableView setContentOffset:offset];
    });

    
}


-(void)disablePrevNotification{
    if(mLastEnabledProx>=0){
        [self proximtiyNotificationDidChangeForNodeId:mLastEnabledProx newState:false];
    }
    if(mLastEnabledMic>=0){
        [self micLevelNotificationDidChangeForNodeId:mLastEnabledMic newState:false];
    }
}

/**
 *  function called when the user change the led status, this function will send 
 *  the command to the remote node 
 *
 *  @param nodeId node where the led has change
 *  @param state  new led status
 */
-(void)ledStatusDidChangeForNodeId:(uint16_t)nodeId newState:(bool)state{
        
    GenericRemoteNodeData *data = [self getNodeData:nodeId];
    data.ledStatus=state;
    
    [mRemoteFeature setSwitchStatus:nodeId newState:state];
}



/**
 * function called when the user enable the proximity notification for a node
 *
 * @param nodeId node where the user enable the notificaiton
 * @param state true if enable the notification, false for disable it
 */
-(void)proximtiyNotificationDidChangeForNodeId:(uint16_t)nodeId newState:(bool)state{
    [self getNodeData:nodeId].isProximityEnabled=state;
    if(state){
        [self disablePrevNotification];
        [mRemoteFeature enableProximityForNode:nodeId enabled:state];
        mLastEnabledProx=nodeId;
    }else{
        [mRemoteFeature enableProximityForNode:nodeId enabled:false];
        mLastEnabledProx=-1;
    }
}

/**
 * function called when the user enable the micLevel notification
 *
 * @param nodeId node where the user change the notification state
 * @param state true for enable the notification, false for disalbe it
 */
-(void)micLevelNotificationDidChangeForNodeId:(uint16_t)nodeId newState:(bool)state{
    [self getNodeData:nodeId].isMicLevelEnabled=state;
    if(state){
        [self disablePrevNotification];
        [mRemoteFeature enableMicLevelForNode:nodeId enabled:state];
        mLastEnabledMic=nodeId;
    }else{
        [mRemoteFeature enableMicLevelForNode:nodeId enabled:false];
        mLastEnabledMic=-1;
    }
}


/**
 * Function called when the user want enable the node scanning
 */
-(void)onStartScanningActionPressed{
    mUserChangeScanningState=true;
    [self disablePrevNotification];
    [mCommand startScanning];
}


/**
 * Function called when the user stop the node scanning
 */
-(void)onStopScanningActionPressed{
    mUserChangeScanningState=true;
    [mCommand stopScanning];
}

-(void)showMessage:(NSString*)msg{
    MBProgressHUD *messageView = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    messageView.mode=MBProgressHUDModeText;
    messageView.label.text=msg;
    [messageView showAnimated:YES];
    [messageView hideAnimated:true afterDelay:2.0f];
}

#pragma mark STSensNetCommandFeatureCallback


-(void)onScanIsStarted:(STSensNetCommandFeature*)commandFeature{
    [_menuDelegate removeMenuAction:mStartScanningAction];
    [_menuDelegate addMenuAction:mStopScanningAction];
    if(mUserChangeScanningState)
        dispatch_sync(dispatch_get_main_queue(),^{
            [self showMessage:SCANNING_START_NAME];
        });
    mUserChangeScanningState=false;
    
    
}

-(void)onScanIsStopped:(STSensNetCommandFeature*)commandFeature{
    [_menuDelegate removeMenuAction:mStopScanningAction];
    [_menuDelegate addMenuAction:mStartScanningAction];
    if(mUserChangeScanningState)
        dispatch_sync(dispatch_get_main_queue(),^{
            [self showMessage:SCANNING_STOP_NAME];
        });
    mUserChangeScanningState=false;
}



@end
