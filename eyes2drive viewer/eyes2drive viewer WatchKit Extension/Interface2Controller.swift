//
//  Interface2Controller.swift
//  eyes2drive viewer
//
//  Created by Rémy Schumm on 11.09.15.
//  Copyright (c) 2015 Focusdays2015. All rights reserved.
//

//
//  InterfaceController.swift
//  eyes2drive viewer WatchKit Extension
//
//  Created by Lorenz Hänggi on 18/07/15.
//  Copyright (c) 2015 Focusdays2015. All rights reserved.
//

import WatchKit
import Foundation
import WatchConnectivity


class Interface2Controller: WKInterfaceController, WCSessionDelegate {
    
    @IBOutlet weak var table: WKInterfaceTable!
    
    @IBOutlet weak var lblScoreInPercent: WKInterfaceLabel?
    @IBOutlet weak var lblTripDuration: WKInterfaceLabel?
    @IBOutlet weak var lblTripState: WKInterfaceLabel?

    var numberOfRows: Int = 3
    
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        if (WCSession.isSupported()) {
            let session = WCSession.defaultSession()
            session.delegate = self
            session.activateSession()
            NSLog("WC table session is activated")
        }

    }
    
    override func willActivate() {
        super.willActivate()
        
        table.setNumberOfRows(0, withRowType: "Cell")
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    func showTable(tableData: Array<[String : AnyObject]>) {
        table.setNumberOfRows(tableData.count, withRowType: "Cell")
        for (var i=0; i<tableData.count; i++) {
            let currentReply = tableData[i]
            let row = table.rowControllerAtIndex(i) as! RowController
            let color = currentReply["color"] as! String
            let durationInMs = currentReply["durationInMs"] as! Double
            row.showItem("\(color)", detail: GlanceController.niceTimeString(Int(durationInMs / 1000)))
        }
    }
    func showSummary(summary:[String : AnyObject]) {
        if let score = summary["score"] as? NSNumber {
            self.lblScoreInPercent?.setText("\(score.integerValue)%")
        }
        if let duration = summary["duration"] as? NSNumber {
            let durationString = GlanceController.niceTimeString(duration.integerValue)
            self.lblTripDuration?.setText("⌚️ \(durationString)")
            self.lblTripState?.setText("running")
        } else {
            self.lblTripState?.setText("stopped")
        }
    }

    func showTable() {
        let applicationData = ["graphValues":"yes"]
        WCSession.defaultSession().sendMessage(applicationData,
            replyHandler: {
                [unowned self]
                (reply: [String : AnyObject]) -> Void in
                let tableData = reply["reply"] as! Array<[String : AnyObject]>
                let summary = reply["summary"] as! [String : AnyObject]
                self.showTable(tableData)
                self.showSummary(summary)
            },
            errorHandler: {(error) -> Void in
                NSLog("error while getting graph values \(error)")
            }
        )
    }

    
    // =========================================================================
    // MARK: - Actions
    
    @IBAction func rehreshBtnTapped() {
        self.showTable()
    }
    
}