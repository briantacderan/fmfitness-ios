//
//  AlertController.swift
//  fmfitness
//
//  Created by Brian Tacderan on 4/23/22.
//

import UIKit
import LocalAuthentication
import SwiftUI

class AlertController: UIViewController {
    @Environment(\.controller) var controller
    
    @ObservedObject var firestore = FirestoreManager.shared
    
    let dateFormatter = DateFormatter()
    
    var alertView: UIAlertController?

    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var bioIDButton: UIButton!
    @IBOutlet weak var stateView: UIView!
    @IBOutlet weak var bioIDLabel: UILabel!
    
    @IBAction func bioIDLoginAction() {
        controller.authenticateUser() { [weak self] message in
            if let message = message {
                self?.alertView = UIAlertController(title: "Access denied",
                                                   message: message,
                                                   preferredStyle: .alert)
                
                guard let alert = self?.alertView else {
                    return
                }
                
                alert.addAction(UIAlertAction(title: "Access denied",
                                              style: .default,
                                              handler: { message in
                    self?.alertView = nil
                    print(message)
                    self?.firestore.authRedirect = Page.loginPage
                    withAnimation(.easeInOut(duration: 0.2)) {
                        AuthenticationView.hideMetric = 0
                        AuthenticationView.lastHide = true
                    }
                }))
                
                self?.present(alert, animated: true)
            } else {
                self?.alertView = UIAlertController(title: "Welcome back!",
                                                    message: nil,
                                                    preferredStyle: .alert)
                
                guard let alert = self?.alertView else {
                    return
                }
                
                alert.addAction(UIAlertAction(title: "Welcome back!",
                                              style: .default,
                                              handler: { (nil) in
                    self?.alertView = nil
                    self?.controller.next(newPage: Dashboard.homePage)
                    withAnimation(.easeIn(duration: 0.2)) {
                        AuthenticationView.hideMetric = 0
                        AuthenticationView.lastHide = true
                    }
                }))
                
                // self?.performSegue(withIdentifier: "dismissLogin", sender: self)
                self?.present(alert, animated: true)
            }
        }
    }
    
    @IBAction func requireKey() {
        guard
            let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
        else { return }
        
        guard
            let rootViewController = windowScene.windows.first?.rootViewController
        else { return }
        
        alertView = UIAlertController(title: "Pass required", message: "Enter secret keyword", preferredStyle: .alert)
        
        guard let alert = alertView else { return }
        
        alert.addTextField { (textField) in
            textField.text = ""
        }

        alert.addAction(UIAlertAction(title: "Submit",
                                      style: .default,
                                      handler: { (nil) in
            self.alertView = nil
            let textField = alert.textFields![0]
            if textField.text == "faguina" {
                print("Thank you! Please create an account")
                withAnimation(.easeInOut(duration: 0.25)) {
                    self.firestore.showRegister.toggle()
                }
            } else {
                print("Incorrect passkey")
            }
            withAnimation(.easeIn(duration: 0.1)) {
                self.firestore.induceShade.toggle()
            }
        }))
        
        alert.addAction(UIAlertAction(title: "New?",
                                      style: .default,
                                      handler: { (nil) in
            self.alertView = nil
            print("Request information")
            withAnimation(.easeIn(duration: 0.1)) {
                self.firestore.induceShade.toggle()
            }
            self.firestore.authRedirect = Page.welcomePage
        }))
        
        rootViewController.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func permitCancel() {
        controller.fetchTraining(for: firestore.profile.email)
        
        guard
            let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
        else { return }
        
        guard
            let rootViewController = windowScene.windows.first?.rootViewController
        else { return }
        
        self.dateFormatter.dateFormat = "dd/MM/yy"
        self.dateFormatter.dateStyle = .medium
        self.dateFormatter.timeStyle = .short
        
        let appt: String = self.dateFormatter.string(from: firestore.appointment.nextAppointment)
        
        alertView = UIAlertController(title: "Cancel appointment on \n\(appt)?", message: "Reason for cancellation (optional)", preferredStyle: .alert)
        
        guard let alert = alertView else { return }
        
        alert.addTextField { (textField) in
            textField.text = ""
        }

        alert.addAction(UIAlertAction(title: "Confirm cancellation",
                                      style: .default,
                                      handler: { (nil) in
            self.alertView = nil
            let textField = alert.textFields![0]
            self.controller.setTraining(parameters: ["email": self.firestore.profile.email, "timeslot": Date(), "invoice": "$0", "cancel": true, "reason": textField.text, "mode": "edit"])
            withAnimation(.easeIn(duration: 0.1)) {
                self.firestore.induceShade.toggle()
            }
        }))
        
        alert.addAction(UIAlertAction(title: "Nevermind",
                                      style: .default,
                                      handler: { (nil) in
            self.alertView = nil
            withAnimation(.easeIn(duration: 0.1)) {
                self.firestore.induceShade.toggle()
            }
        }))
        
        rootViewController.present(alert, animated: true, completion: nil)
    }
    
    /// An authentication context stored at class scope so it's available for use during UI updates.
    var context = LAContext()

    /// The available states of being logged in or not.
    enum AuthenticationState {
        case loggedin, loggedout
    }

    /// The current authentication state.
    var state = AuthenticationState.loggedout {
        didSet {
            loginButton.isHighlighted = state == .loggedin
            stateView.backgroundColor = state == .loggedin ? .green : .red

            // FaceID runs right away on evaluation, so you might want to warn the user.
            //  In this app, show a special Face ID prompt if the user is logged out, but
            //  only if the device supports that kind of authentication.
            bioIDLabel.isHidden = (state == .loggedin) || (context.biometryType != .faceID)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        context.canEvaluatePolicy(.deviceOwnerAuthentication, error: nil)
        state = .loggedout
        bioIDButton.isHidden = !controller.canEvaluatePolicy()
        
        switch controller.biometricType() {
        case .faceID:
            bioIDButton.setImage(UIImage(named: "FaceIcon"),  for: .normal)
        case .touchID:
            bioIDButton.setImage(UIImage(named: "Touch-icon-lg"),  for: .normal)
        default:
            bioIDButton.setImage(UIImage(named: "FaceIcon"),  for: .normal)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let canAuthBio = controller.canEvaluatePolicy()
        if canAuthBio {
            bioIDLoginAction()
        }
    }

    /// Logs out or attempts to log in when the user taps the button.
    @IBAction func tapButton(_ sender: UIButton) {

        if state == .loggedin {
            state = .loggedout
        } else {
            context = LAContext()
            context.localizedCancelTitle = "Enter Passcode"

            var error: NSError?
            
            if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) {
                let reason = "Log in to your account"
                context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason ) { [weak self] success, error in

                    if success {
                        // Move to the main thread because a state update triggers UI changes.
                        DispatchQueue.main.async {
                            self?.state = .loggedin
                        }
                    } else {
                        print(error?.localizedDescription ?? "Failed to authenticate")
                        DispatchQueue.main.async {
                            self?.firestore.authRedirect = Page.loginPage
                        }
                    }
                }
            } else {
                print(error?.localizedDescription ?? "Can't evaluate policy")

                // Fall back to a asking for username and password.
                DispatchQueue.main.async { [weak self] in
                    self?.firestore.authRedirect = Page.loginPage
                }
            }
        }
    }
}
