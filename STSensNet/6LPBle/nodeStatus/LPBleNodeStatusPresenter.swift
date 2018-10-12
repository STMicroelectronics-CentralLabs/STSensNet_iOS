//
//  LPBleNodeStatusPresenter.swift
//  STSensNet
//
//  Created by Giovanni Visentini on 24/05/2018.
//  Copyright © 2018 STCentralLab. All rights reserved.
//

import Foundation

class LPBleNodeStatusPresenterImpl : LPBleNodeStatusPresenter{
    
    private static let STATUS_REFRESH_INTERVAL:DispatchTimeInterval = .seconds(5)
    private static let STATUS_REFRESH_LEEWAY:DispatchTimeInterval = .seconds(5/4)
    
    private weak var mView:LPBleNodeStatusView?
    private let mCentralNode:Feature6LoWPANProtocol
    private let mNodeAddress:LPBleNetworkAddress
    private var refreshTimer:DispatchSourceTimer?
    private var mLedStatusRequested=false

    
    init(view:LPBleNodeStatusView, centralNode:Feature6LoWPANProtocol, nodeAddress:LPBleNetworkAddress){
        self.mView=view
        self.mCentralNode=centralNode
        self.mNodeAddress = nodeAddress
    }
    
    func startRetrievingSensorData(){
        mView?.showNodeAddress(mNodeAddress)
        let queue = DispatchQueue(label: "LPBleNodeStatusPresenterImpl",
                                  qos: .background,
                                  attributes: .concurrent)
        
        refreshTimer?.cancel()        // cancel previous timer if any
        
        refreshTimer = DispatchSource.makeTimerSource(queue: queue)
        
        refreshTimer?.scheduleRepeating(deadline: .now(),
                                        interval: LPBleNodeStatusPresenterImpl.STATUS_REFRESH_INTERVAL,
                                        leeway: LPBleNodeStatusPresenterImpl.STATUS_REFRESH_LEEWAY)
        
        refreshTimer?.setEventHandler { [weak self] in
            if let centralNode = self?.mCentralNode,
                let view = self?.mView,
                let address = self?.mNodeAddress{
                let request = centralNode.getNodeSensorData(node: address){[weak view] (nodeData) in
                    if let data = nodeData{
                        view?.showData(data)
                        if(!(self?.mLedStatusRequested ?? false)){
                            _ = centralNode.updateLedDimming(address: address, dimingValue: 0){
                                adr , newValue in
                                self?.mLedStatusRequested=true;
                                if(newValue != nil){
                                    view?.showLedStatus(dimmingValue: newValue!)
                                }
                            }
                        }
                    }else{
                        view?.showInvalidResponseError()
                    }
                }//getNetworkList
                print(request)
            }//if centralNode,view
        }//setEvent
        
        refreshTimer?.resume()
    }
    
    func stopRetrievingSensorData(){
        refreshTimer?.cancel()
        refreshTimer=nil
    }
    
    func setLedDimmingStatus (dimmingValue: UInt8) {
        _ = mCentralNode.updateLedDimming(address:mNodeAddress, dimingValue: dimmingValue){
            [weak view = self.mView] add,newStatus in
            if(newStatus == nil){
                view?.showInvalidResponseError()
            }else{
                view?.showLedStatus(dimmingValue: dimmingValue);
            }
        }
    }
}

extension LPBleNodeStatusView{
    func showData(_ data:LPBleSensorNode){
        showTemperature(data.temperature)
        showHumidity(data.humidity)
        showPressure(data.pressure)
        showAccelerometer(x: Float(data.accX), y: Float(data.accY), z: Float(data.accZ))
        showGyroscope(x: Float(data.gyroX), y: Float(data.gyroY), z: Float(data.gyroZ))
        showMagnetometer(x: Float(data.magX), y: Float(data.magY), z: Float(data.magZ))
    }
}
