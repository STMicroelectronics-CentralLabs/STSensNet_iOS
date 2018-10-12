//
//  LPBleNetworkStatusPresenter.swift
//  STSensNet
//
//  Created by Giovanni Visentini on 23/05/2018.
//  Copyright © 2018 STCentralLab. All rights reserved.
//

import Foundation

public class LPBleNetworkStatusPresenterImpl: LPBleNetworkStatusPresenter{
    
    private static let NETWORK_REFRESH_INTERVAL:DispatchTimeInterval = .seconds(8)
    private static let NETWORK_REFRESH_LEEWAY:DispatchTimeInterval = .seconds(8/4)
    
    private weak var mView:LPBleNetworkStatusView?
    private let mCentralNode:Feature6LoWPANProtocol
    private var refreshTimer:DispatchSourceTimer?
    
    init(view:LPBleNetworkStatusView, centralNode:Feature6LoWPANProtocol){
        self.mView=view;
        self.mCentralNode=centralNode
    }
    
    func startNodeRefresh() {
        let queue = DispatchQueue(label: "LPBleNetworkStatusPresenterImpl",
                                  qos: .background,
                           attributes: .concurrent)
        
        refreshTimer?.cancel()        // cancel previous timer if any
        
        refreshTimer = DispatchSource.makeTimerSource(queue: queue)
        
        refreshTimer?.scheduleRepeating(deadline: .now(),
                                        interval: LPBleNetworkStatusPresenterImpl.NETWORK_REFRESH_INTERVAL,
                                        leeway: LPBleNetworkStatusPresenterImpl.NETWORK_REFRESH_LEEWAY)
        
        refreshTimer?.setEventHandler { [weak self] in
            if let centralNode = self?.mCentralNode,
               let view = self?.mView{
                let _ = centralNode.getNetworkNodeList{ [weak view] (networkNodes) in
                    if let nodes = networkNodes{
                        view?.showNodes(nodes)
                    }else{
                        view?.showInvalidResponseError()
                    }//if nodes
                }//getNetworkList
            }//if centralNode,view
        }//setEvent
        
        refreshTimer?.resume()
    }
    
    func stopNodeRefresh() {
        refreshTimer?.cancel()
        refreshTimer=nil
    }
    
    func getNodes() {
        stopNodeRefresh()
        startNodeRefresh()
    }
    
    func onNodeSelected(_ node: LPBleSensorNode) {
        mView?.showNodeDetails(node)
    }
    
    
}
