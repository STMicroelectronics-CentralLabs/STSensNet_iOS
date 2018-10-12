//
//  LPBleNetworkTopologyViewController.swift
//  STSensNet
//
//  Created by Giovanni Visentini on 25/05/2018.
//  Copyright © 2018 STCentralLab. All rights reserved.
//

import Foundation

public class LPBleNetworkTopologyViewController: UITableViewController, LPBleNetworkTopologyView{
    
    private static let CELL_ID = "LPBleNetworkTopologyViewCell"
    private static let SHOW_DETAILS_SEGUE_IPAD = "LPBle_showNetworkTopologyDetails_iPad"
    private static let SHOW_DETAILS_SEGUE_IPHONE = "LPBle_showNetworkTopologyDetails_iPhone"
    public var centraNode:Feature6LoWPANProtocol!

    private var mTopologyData:[LPBleNetworkNodeData]?
    
    private var mPresenter:LPBleNetworkTopologyPresenter?
    
    public override func viewDidAppear(_ animated: Bool) {
        mPresenter = LPBleNetworkTopologyPresenterImpl(view: self,centralNode: centraNode)
        mPresenter?.requestNodeTopology()
    }
    
    func showNodes(_ nodes: [LPBleNetworkNodeData]) {
        mTopologyData = nodes;
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    func showInvalidResponseError() {
        DispatchQueue.main.async {
            self.showAllert(title: "Invalid response", message: "Command error")
        }
    }
    
    public override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        if let node = mTopologyData?[indexPath.row]{
            switch UIDevice.current.userInterfaceIdiom {
                case .phone: performSegue(withIdentifier:LPBleNetworkTopologyViewController.SHOW_DETAILS_SEGUE_IPHONE, sender: node)
                    break
                case .pad: performSegue(withIdentifier:LPBleNetworkTopologyViewController.SHOW_DETAILS_SEGUE_IPAD, sender: node)
                    break
                case .tv, .carPlay,.unspecified:
                    break
            }//switch
        }//if node
    }
    
    public override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? LPBleNetworkTopologyDetailsViewController,
            let node = sender as? LPBleNetworkNodeData{
            destination.pathToRoot=node.routeToRoot
            //center the popover in the view
            destination.popoverPresentationController?.sourceView = self.view
            destination.popoverPresentationController?.sourceRect =
                CGRect(x: view.center.x, y: view.center.y, width: 0, height: 0)
        }
    }
    
    public override func tableView(_ tableView: UITableView,
                                   numberOfRowsInSection section: Int) -> Int {
        return mTopologyData?.count ?? 0
    }
    
    public override func tableView(_ tableView: UITableView,
                                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier:LPBleNetworkTopologyViewController.CELL_ID)
        
        if let node = mTopologyData?[indexPath.row]{
            cell?.showNodeData(node)
        }
    
        return cell!
    }
    
}


fileprivate extension UITableViewCell{
    
    private static let ROOT = {
        return  NSLocalizedString("Root",
                                  tableName: nil,
                                  bundle: Bundle(for: STM32WBRSSIUpdateViewController.self),
                                  value: "Root",
                                  comment: "Root");
    }();
    
    private static let N_HOPE_FORMAT = {
        return  NSLocalizedString("# of hopes: %d",
                                  tableName: nil,
                                  bundle: Bundle(for: STM32WBRSSIUpdateViewController.self),
                                  value: "# of hopes: %d",
                                  comment: "# of hopes: %d");
    }();
    
    private func showRootData(_ data:LPBleNetworkNodeData){
        self.textLabel?.text = data.address
        self.detailTextLabel?.text = UITableViewCell.ROOT
        self.accessoryType = .none
    }
    
    func showChildData(_ data:LPBleNetworkNodeData){
        self.textLabel?.text = data.address
        self.detailTextLabel?.text = String( format: UITableViewCell.N_HOPE_FORMAT, data.routeToRoot.count)
        self.accessoryType = .detailButton
    }
    
    func showNodeData(_ data:LPBleNetworkNodeData){
        if(data.routeToRoot.isEmpty){
            showRootData(data)
        }else{
            showChildData(data)
        }
    }
}
