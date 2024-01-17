/********* CordovaHelloWorld.m Cordova Plugin Implementation *******/

import Foundation
import UIKit
import WebKit

@objc(CordovaHelloWorld)
class CordovaHelloWorld: CDVPlugin {
    private var privacyViewController: UIViewController!
    var isEnabled = true
    private var secureTextFieldIsAdded = false
    private var pluginResult = CDVPluginResult(
        status: CDVCommandStatus_ERROR
    )
    
    override func pluginInitialize ( ){
        privacyViewController = CordovaHelloWorld.createSecureViewController()
        
        //self.webView.translatesAutoresizingMaskIntoConstraints = false
        
        self.isEnabled = true
        NotificationCenter.default.addObserver(self, selector: #selector(self.handleDidBecomeActiveNotification),
                                               name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.handleWillResignActiveNotification),
                                               name: NSNotification.Name.UIApplicationWillResignActive, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.handleDidChangeStatusBarOrientationNotification),
                                               name: NSNotification.Name.UIApplicationDidChangeStatusBarOrientation, object: nil)
        
        super.pluginInitialize()
    }
    
    override func dispose() {
        NotificationCenter.default.removeObserver(self)
        super.dispose()
    }
    
    @objc public func enable(_ command: CDVInvokedUrlCommand) {
        self.isEnabled = true
        self.pluginResult = CDVPluginResult(
            status: CDVCommandStatus_OK,
            messageAs: "ScreenShot enable, you could take screenshot"
        )
        
        DispatchQueue.main.async {
            //self.webView.enableScreenshots()
            self.viewController.view.enableScreenshots()
            
            self.commandDelegate!.send(
                self.pluginResult,
                callbackId: command.callbackId
            )
        }
        
    }
    
    @objc public func disable(_ command: CDVInvokedUrlCommand) {
        self.isEnabled = false
        self.secureTextFieldIsAdded = false
        self.pluginResult = CDVPluginResult(
            status: CDVCommandStatus_OK,
            messageAs: "ScreenShot disable, can not take screenshot"
        )
        
        DispatchQueue.main.async {
            
            //self.webView.disableScreenshots()
            self.viewController.view.disableScreenshots()
            
            self.commandDelegate!.send(
                self.pluginResult,
                callbackId: command.callbackId
            )
            
        }
    }
    
    @objc private func handleDidBecomeActiveNotification ( ){
        self.privacyViewController.dismiss(animated: false, completion: {
            if ( !self.isEnabled ){
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.009) {
                    self.viewController.view.disableScreenshots()
                }
            }
        })
    }
    
    
    @objc private func handleWillResignActiveNotification ( ){
        
        DispatchQueue.main.async {
            self.viewController?.present(self.privacyViewController, animated: false, completion: nil)
        }
    }
    
    @objc private func handleDidChangeStatusBarOrientationNotification ( ){
        
        self.viewController?.view.frame = CGRect(x: 0.0, y: 0.0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        
    }
    
    @objc private static func createSecureViewController( ) -> UIViewController{
        let privacyViewController = UIViewController()
        privacyViewController.view.backgroundColor = UIColor.gray
        privacyViewController.modalPresentationStyle = UIModalPresentationStyle.fullScreen
        return privacyViewController
    }
    
}


public extension UIView {
    // Cannot be tested in simulator
    @objc func disableScreenshots() {
        addSecureText()
    }
    
    
    @objc private func addSecureText() {
        
        let field = UITextField()
        field.isSecureTextEntry = true
        field.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(field)
        field.centerYAnchor.constraint(equalTo: self.topAnchor).isActive = true
        field.centerXAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        self.layer.superlayer?.addSublayer(field.layer)
        
        // Must be `last` for iOS 17
        if #available(iOS 17.0, *) {
            field.layer.sublayers?.last?.addSublayer(self.layer)
        }
    }
    
    @objc private func addSecureTextEntryToTextField( to isSecure : Bool) {
        DispatchQueue.main.async {
            for view in self.subviews {
                if let textField = view as? UITextField {
                    textField.isSecureTextEntry = isSecure
                }
            }
        }
    }
    
    @objc func enableScreenshots() {
        addSecureTextEntryToTextField(to: false)
    }
}
