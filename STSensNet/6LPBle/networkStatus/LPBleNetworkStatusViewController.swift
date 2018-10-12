/*
 * Copyright (c) 2018  STMicroelectronics – All rights reserved
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

import Foundation
import BlueSTSDK
import UIKit

public class LPBleNetworkStatusViewController : UIViewController,BlueSTSDKDemoViewProtocol,
LPBleNetworkStatusView,LPBleNetworkLedView{
    
    private static let NODE_DETAILS_SEGUE = "LPBle_networkToNodeStatus"
    private static let NETWORK_TOPOLOGY_SEGUE = "LPBle_showNetworkTopology"
    
    private static let SHOW_TOPOLOGY = {
        return  NSLocalizedString("Show Topology",
                                  tableName: nil,
                                  bundle: Bundle(for: LPBleNetworkStatusViewController.self),
                                  value: "Show Topology",
                                  comment: "Show Topology");
    }();
    
    private static let ALL_LED_ON = {
        return  NSLocalizedString("Turn on all leds",
                                  tableName: nil,
                                  bundle: Bundle(for: LPBleNetworkStatusViewController.self),
                                  value: "Turn on all leds",
                                  comment: "Turn on all leds");
    }();
    
    private static let ALL_LED_OFF = {
        return  NSLocalizedString("Turn off all leds",
                                  tableName: nil,
                                  bundle: Bundle(for: LPBleNetworkStatusViewController.self),
                                  value: "Turn off all leds",
                                  comment: "Turn off all leds");
    }();
    
    @IBOutlet weak var mNodesTable: UITableView!
    
    public var node:BlueSTSDKNode!
    public var menuDelegate:BlueSTSDKViewControllerMenuDelegate?
    
    fileprivate var mNetworkNode:[LPBleSensorNode]?
    
    fileprivate var mPresenter:LPBleNetworkStatusPresenter?
    fileprivate var mLedPresenter:LPBleNetworkLedPresenter?
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        mNodesTable.dataSource=self
        mNodesTable.delegate=self
        
        let showTopology = UIAlertAction(
            title: LPBleNetworkStatusViewController.SHOW_TOPOLOGY,
            style: .default){ _ in
                self.performSegue(withIdentifier: LPBleNetworkStatusViewController.NETWORK_TOPOLOGY_SEGUE,
                                  sender: nil)
            }
        
        menuDelegate?.addMenuAction(showTopology);
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let feature = node?.getFeatureOfType(Feature6LoWPANProtocol.self) as? Feature6LoWPANProtocol
        if let centralNode = feature{
            mPresenter = LPBleNetworkStatusPresenterImpl(view: self,centralNode: centralNode)
            mLedPresenter = LPBleNetworkLedPresenterImpl(view: self,centralNode: centralNode)
            mPresenter?.startNodeRefresh()
        }
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        mPresenter?.stopNodeRefresh()
        menuDelegate?.removeMenuAction(mSwitchOnAction)
        menuDelegate?.removeMenuAction(mSwitchOffAction)
    }
    
    func showNodes(_ nodes: [LPBleSensorNode]) {
        mNetworkNode = nodes
        DispatchQueue.main.async {
            self.mNodesTable.reloadData()
        }
    }
    
    func showNodeDetails(_ node: LPBleSensorNode) {
        DispatchQueue.main.async {
            self.performSegue(withIdentifier:LPBleNetworkStatusViewController.NODE_DETAILS_SEGUE,
                         sender: node.address)
        }
    }
    
    func showInvalidResponseError() {
        DispatchQueue.main.async {
            self.showAllert(title: "Invalid response", message: "Command error")
        }
    }
    
    public override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == LPBleNetworkStatusViewController.NODE_DETAILS_SEGUE){
            if let destination = segue.destination as? LPBleNodeStatusViewController,
               let centralNode = node?.getFeatureOfType(Feature6LoWPANProtocol.self) as? Feature6LoWPANProtocol,
               let nodeAddress = sender as? LPBleNetworkAddress{
                destination.centraNode=centralNode
                destination.nodeAddress = nodeAddress
            }// if let
        }//if segue
        if(segue.identifier == LPBleNetworkStatusViewController.NETWORK_TOPOLOGY_SEGUE){
            if let destination = segue.destination as? LPBleNetworkTopologyViewController,
                let centralNode = node?.getFeatureOfType(Feature6LoWPANProtocol.self) as? Feature6LoWPANProtocol{
                destination.centraNode = centralNode
            }
        }
    }
    
    private lazy var mSwitchOnAction = {
        return UIAlertAction(title: LPBleNetworkStatusViewController.ALL_LED_ON,
                             style: .default){
            _ in self.mLedPresenter?.switchAllOn()
        }
    }()
    
    private lazy var mSwitchOffAction = {
        return UIAlertAction(title: LPBleNetworkStatusViewController.ALL_LED_OFF,
                             style: .default){
            _ in self.mLedPresenter?.switchAllOff()
        }
    }()
    
    func showSwitchAllOn() {
        DispatchQueue.main.async {
            self.menuDelegate?.removeMenuAction(self.mSwitchOffAction)
            self.menuDelegate?.addMenuAction(self.mSwitchOnAction)
        }
        
    }
    
    func showSwitchAllOff() {
        DispatchQueue.main.async {
            self.menuDelegate?.removeMenuAction(self.mSwitchOnAction)
            self.menuDelegate?.addMenuAction(self.mSwitchOffAction)
        }
    }
    
    func showSwitchUpdateFail() {
        DispatchQueue.main.async {
            self.showAllert(title: "Invalid response", message: "Command error")
        }
    }
    
}

extension LPBleNetworkStatusViewController:UITableViewDataSource{
    
    private static let CELL_ID = "LPBleNetworkStatusViewControllerCell"

    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mNetworkNode?.count ?? 0
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier:LPBleNetworkStatusViewController.CELL_ID)
        
        let node = mNetworkNode?[indexPath.row]
        
        cell?.textLabel?.text = node?.address.description
        
        return cell!
        
    }
    
}

extension LPBleNetworkStatusViewController:UITableViewDelegate{

    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let node = mNetworkNode?[indexPath.row]{
            mPresenter?.onNodeSelected(node)
        }
    }
    
}

