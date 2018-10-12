//
//  LPBleNetworkTopologyPresenterImpl.swift
//  STSensNet
//
//  Created by Giovanni Visentini on 25/05/2018.
//  Copyright © 2018 STCentralLab. All rights reserved.
//

import Foundation

public class LPBleNetworkTopologyPresenterImpl: LPBleNetworkTopologyPresenter{
    
    private weak var mView:LPBleNetworkTopologyView?
    private let mCentralNode:Feature6LoWPANProtocol
    
    init(view:LPBleNetworkTopologyView, centralNode:Feature6LoWPANProtocol){
        self.mView=view;
        self.mCentralNode=centralNode
    }
    
    
    func requestNodeTopology() {
        let _ = mCentralNode.getNetworkTopology{ [weak mView] topology in
            if let top = topology{
                mView?.showNodes(LPBleNetworkTopologyPresenterImpl.extractNodeData(top))
            }else{
                mView?.showInvalidResponseError()
            }
        }
    }
    
    private static func extractNodeData(_ topology:NetworkTopology)->[LPBleNetworkNodeData]{
        let networkNodes = topology.nodes
        let nodesData = networkNodes.map{ node -> LPBleNetworkNodeData in
            let nodeToRoot = node.getRouteToRoot().map{ $0.description}
            return LPBleNetworkNodeData(address: node.address.description, routeToRoot: nodeToRoot)
        }
        
        return nodesData.sorted{a,b  in a.routeToRoot.count<b.routeToRoot.count}
    }

}
