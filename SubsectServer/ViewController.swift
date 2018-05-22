//
//  ViewController.swift
//  SubServiOS
//
//  Created by Mark Kudlac on 2018-05-06.
//  Copyright © 2018 Mark Kudlac. All rights reserved.
//

//import SQLite3
import UIKit
import WebKit



// Wrap the WKWebView webview to allow IB use

class ServerWebView : WKWebView {
    required init?(coder: NSCoder) {
        let configuration = WKWebViewConfiguration()
        let controller = WKUserContentController()
        configuration.userContentController = controller;
        super.init(frame: CGRect.zero, configuration: configuration)
    }
}

class ViewController: UIViewController {
    
    @IBOutlet weak var webView: ServerWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        webView.navigationDelegate = self;
        
       //  Add addScriptMessageHandler in javascript: window.webkit.messageHandlers.MyObserver.postMessage()
        
        webView.configuration.userContentController.add(self, name: "MyObserver")
        
        if let filePath = Bundle.main.path(forResource:"index", ofType:"html", inDirectory: "ServerAssets") {
           
            var hash:String = "X"
            var nameServer = CONST.defaultServer
            var hostName = "X"
            let fullHost = IPUtility.getMyIP().ip! + ":" + "\(CONST.defaultPort)"
            
            let defaults = UserDefaults.standard
    //        let selectServer = UserDefaults.standard.bool(forKey: CONST.selectServer)
            
    //        print("the value of selectServer : " + String(stringInterpolationSegment: selectServer))
            
            if nil != defaults.string(forKey: CONST.alternateServer) &&
                !UserDefaults.standard.bool(forKey: CONST.selectServer) {
                nameServer = defaults.string(forKey: CONST.alternateServer)!
            }
            
            if let hostNameTmp:String = defaults.string(forKey: CONST.hostName) {
                hostName = hostNameTmp
                if let hostPassword = defaults.string(forKey: CONST.hostPassword) {
                    
                    hash = SHA1.hexString(from: hostName + hostPassword)!
                    hash = hash.replacingOccurrences(of: " ", with: "").lowercased()
              //      print("SHA-1 : " + hash) // Another String Value
                } else {
                    print("Host password not set")
                }
            } else {
                print("Host name not set")
            }
            
            do {
         //       if !hash.isEmpty {
                    print("Loading file")
                    // load html string - baseURL needs to be set for local files to load correctly
                    
                    let params = "subhost=" + hostName + "&subnamesrv=" +
                         nameServer + "&fullhost=" + fullHost + "&passwd=" + hash
                    
                print("params : \(params)")
                    var html = try String(contentsOfFile: filePath, encoding: .utf8)
                        html = html.replacingOccurrences(of: "XXXTHISISTHEPARAMSTRINGXXX",
                                                 with: params)
                    
                        webView.loadHTMLString(html, baseURL: Bundle.main.resourceURL?.appendingPathComponent("ServerAssets"))
                   
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func callJavascript(script: String) {
        
 //       let script = "testJS()"
        webView.evaluateJavaScript(script) { (result: Any?, error: Error?) in
            if let error = error {
                print("evaluateJavaScript error: \(error.localizedDescription)")
            } else {
                print("evaluateJavaScript result: \(result ?? "")")
            }
        }
    }
 
}


extension ViewController : WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        // Callback from javascript: window.webkit.messageHandlers.MyObserver.postMessage(message)
        let text = message.body as! String;
        let alertController = UIAlertController(title: "Communication Error", message: text, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { (action) in
            print("Error")
        }
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    //    print("This is from javascript : " + text )
    }
}


extension ViewController : WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("didFinish navigation:");
  
        // This is here for testing Javascript communications could be removed later
  //      callJavascript(script: "testJS()")
 //       callJavascript(script: "test2JS(23)")
    }
    

}






