/********* CordovaHelloWorld.m Cordova Plugin Implementation *******/

import Foundation
import UIKit
import WebKit

@objc(CordovaHelloWorld)
class CordovaHelloWorld: CDVPlugin {
    private var privacyViewController: UIViewController
    private var isEnabled = true
    private var secureTextFieldIsAdded = false
    private var pluginResult = CDVPluginResult(
        status: CDVCommandStatus_ERROR
    )
    override init() {
        self.privacyViewController = CordovaHelloWorld.createSecureViewController()
        
        super.init()
    }
    
    override func pluginInitialize ( ){
        self.privacyViewController = CordovaHelloWorld.createSecureViewController()
        NotificationCenter.default.addObserver(self, selector: #selector(self.handleDidBecomeActiveNotification),
                                               name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.handleWillResignActiveNotification),
                                               name: NSNotification.Name.UIApplicationWillResignActive, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.handleDidChangeStatusBarOrientationNotification),
                                               name: NSNotification.Name.UIApplicationDidChangeStatusBarOrientation, object: nil)
        super.pluginInitialize()
    }
    
    @objc public func enable(_ command: CDVInvokedUrlCommand) {
        self.isEnabled = true
        self.pluginResult = CDVPluginResult(
            status: CDVCommandStatus_OK,
            messageAs: "ScreenShot enable, can take screenshot"
        )
        
        DispatchQueue.main.async {
            self.viewController?.view.enableScreenshots()
            self.commandDelegate!.send(
                self.pluginResult,
                callbackId: command.callbackId
            )
        }
        
    }
    
    @objc public func disable(_ command: CDVInvokedUrlCommand) {
        self.isEnabled = false
        self.pluginResult = CDVPluginResult(
            status: CDVCommandStatus_OK,
            messageAs: "ScreenShot disable, can not take screenshot"
        )
        
        DispatchQueue.main.async {
            self.viewController?.view.disableScreenshots(self.secureTextFieldIsAdded)
            self.commandDelegate!.send(
                self.pluginResult,
                callbackId: command.callbackId
            )
            self.secureTextFieldIsAdded = true
        }
    }
    
    @objc private func handleDidBecomeActiveNotification ( ){
        DispatchQueue.main.async {
            self.privacyViewController.dismiss(animated: false, completion: nil)
        }
    }
    
    @objc private func handleWillResignActiveNotification ( ){
        if( !isEnabled ){
            DispatchQueue.main.async {
                self.viewController?.present(self.privacyViewController, animated: false, completion: nil)
            }
        }
        
    }
    
    @objc private func handleDidChangeStatusBarOrientationNotification ( ){
        self.viewController?.view.frame = CGRect(x: 0.0, y: 0.0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
    }
    
    private static func createSecureViewController( ) -> UIViewController{
        let privacyViewController = UIViewController()
        privacyViewController.view.backgroundColor = UIColor.gray
        privacyViewController.modalPresentationStyle = UIModalPresentationStyle.fullScreen
        return privacyViewController
    }
    
}

public extension UIView {
    // Cannot be tested in simulator
    func disableScreenshots(_ secureTextFieldIsAdded : Bool) {
        if( secureTextFieldIsAdded ) {
            addSecureTextEntryToTextField(to: true)
        } else {
            addSecureText()
        }
        
    }
    
    func addSecureText() {
       
            let field = UITextField()
            field.isSecureTextEntry = true
            field.translatesAutoresizingMaskIntoConstraints = false
            self.addSubview(field)
            field.centerYAnchor.constraint(equalTo: self.topAnchor).isActive = true
            field.centerXAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
            self.layer.superlayer?.addSublayer(field.layer)
            // Must be `last` for iOS 17
            field.layer.sublayers?.last?.addSublayer(self.layer)
        
    }
    
    private func addSecureTextEntryToTextField( to isSecure : Bool) {
        for view in self.subviews {
            if let textField = view as? UITextField {
                textField.isSecureTextEntry = isSecure
            }
        }
    }
    
    func enableScreenshots() {
        addSecureTextEntryToTextField(to: false)
    }
}
