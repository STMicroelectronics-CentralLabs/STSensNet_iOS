//
//  LPBleNetworkLedPresenter.swift
//  STSensNet
//
//  Created by Giovanni Visentini on 04/06/2018.
//  Copyright © 2018 STCentralLab. All rights reserved.
//

import Foundation

public class LPBleNetworkLedPresenterImpl: LPBleNetworkLedPresenter{
    
    private static let ON_DIMMING = UInt8(50)
    private static let OFF_DIMMING = UInt8(0)
    
    private weak var mView:LPBleNetworkLedView?
    private let mCentralNode:Feature6LoWPANProtocol
    
    init(view:LPBleNetworkLedView, centralNode:Feature6LoWPANProtocol){
        self.mView=view;
        self.mCentralNode=centralNode
        mView?.showSwitchAllOn()
    }
    
    func switchAllOn() {
        _ = mCentralNode.updateLedDimming(address: LPBleNetworkAddress.BROADCAST_ADDRESS,
                                      dimingValue: LPBleNetworkLedPresenterImpl.ON_DIMMING){
                                        [weak view = self.mView] addr, newValue in
                                        if newValue == nil{
                                            view?.showSwitchUpdateFail()
                                        }else{
                                            view?.showSwitchAllOff()
                                        }
        }
    }
    
    func switchAllOff() {
        _ = mCentralNode.updateLedDimming(address: LPBleNetworkAddress.BROADCAST_ADDRESS,
                                      dimingValue: LPBleNetworkLedPresenterImpl.OFF_DIMMING){
                                        [weak view = self.mView] addr, newValue in
                                        if newValue == nil{
                                            view?.showSwitchUpdateFail()
                                        }else{
                                            view?.showSwitchAllOn()
                                        }
        }
    }
        
}
