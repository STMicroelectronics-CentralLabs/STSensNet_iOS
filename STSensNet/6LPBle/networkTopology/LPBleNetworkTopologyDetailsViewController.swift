//
//  LPBleNetworkTopologyDetailsViewController.swift
//  STSensNet
//
//  Created by Giovanni Visentini on 25/05/2018.
//  Copyright © 2018 STCentralLab. All rights reserved.
//

import Foundation

class LPBleNetworkTopologyDetailsViewController: UITableViewController {
    private static let CELL_ID = "LPBleNetworkTopologyDetailsViewCell"

    public var pathToRoot:[String]!
    
    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pathToRoot.count
    }
    
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier:LPBleNetworkTopologyDetailsViewController.CELL_ID)
        
        let address = pathToRoot[indexPath.row]
        cell?.textLabel?.text = address

        return cell!
    }
    
}
