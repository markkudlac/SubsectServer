//
//  HelpViewController.swift
//  SubsectServer
//
//  Created by Mark Kudlac on 2018-05-31.
//  Copyright © 2018 Mark Kudlac. All rights reserved.
//

import UIKit
import WebKit
import SwiftyJSON


// Wrap the WKWebView webview to allow IB use

class HelpWebView : WKWebView {
    required init?(coder: NSCoder) {
        let configuration = WKWebViewConfiguration()
        let controller = WKUserContentController()
        configuration.userContentController = controller;
        super.init(frame: CGRect.zero, configuration: configuration)
    }
}


class HelpViewController: UIViewController {

        var helpTarget = CONST.defaultHelp
        var appData = JSON.null
    
    @IBOutlet weak var helpWebView: HelpWebView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        helpWebView.navigationDelegate = self;
        
        print("In Help controller, helpTarget : \(helpTarget)")
        
        if helpTarget == CONST.bazaarHelp && appData != JSON.null {
            print("appData filesize : \(appData[CONST.fieldFileSize].int!)")
            
            if let filePath = Bundle.main.path(forResource:CONST.helpApp, ofType:CONST.html, inDirectory: CONST.serverAssets) {
                
                do {
                    
                    let params = "\(CONST.fieldTitle)=\(appData[CONST.fieldTitle].string!)&\(CONST.fieldDescription)=\(appData[CONST.fieldDescription].string!)&\(CONST.fieldIcon)=\(appData[CONST.fieldIcon].string!.components(separatedBy: .whitespacesAndNewlines).joined())&\(CONST.fieldFileSize)=\(appData[CONST.fieldFileSize].int!)"
                    
                    var html = try String(contentsOfFile: filePath, encoding: .utf8)
                    html = html.replacingOccurrences(of: CONST.webviewParams,
                                                     with: params)
    
                    helpWebView.loadHTMLString(html, baseURL: Bundle.main.resourceURL?.appendingPathComponent(CONST.serverAssets))
                    
                    if !Initialize.start() {
                        print("Initize failed")
                    }
                    
                } catch {
                    print("Error loading webView html")
                }
            } else {
                print("Could not open file")
            }
            
        } else {
        
            if let filePath = Bundle.main.path(forResource:CONST.helpServer, ofType:CONST.html, inDirectory: CONST.serverAssets) {
                
                do {
                    let params = "\(CONST.helpId)=\(helpTarget)"
                    
                    var html = try String(contentsOfFile: filePath, encoding: .utf8)
                    html = html.replacingOccurrences(of: CONST.webviewParams,
                                                     with: params)
                    
                    helpWebView.loadHTMLString(html, baseURL: Bundle.main.resourceURL?.appendingPathComponent(CONST.serverAssets))
                    
                    if !Initialize.start() {
                        print("Initize failed")
                    }
                    
                } catch {
                    print("Error loading webView html")
                }
            } else {
                print("Could not open file")
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension HelpViewController : WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
   //     print("didFinish navigation:");
    }
}
