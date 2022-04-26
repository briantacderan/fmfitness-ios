//
//  SignUpView.swift
//  fmfitness
//
//  Created by Brian Tacderan on 1/19/22.
//

import SwiftUI
import SafariServices
import Firebase

extension AnyTransition {
    public static var moveFromBottom: AnyTransition {
        AnyTransition.move(edge: .bottom)
    }
}


struct SignUpPage: View {

    @ObservedObject var firestore = FirestoreManager.shared
    @ObservedObject var cloud = CloudManager.shared
    
    @State var username = ""
    @State var email = ""
    @State var password = ""
    @State var passwordConfirmation = ""
    
    @State var signUpProcessing = false
    @State var signUpErrorMessage = ""
    
    @State var registrationDidSucceed = false
    
    var body: some View {
        ZStack(alignment: .top) {
            VStack {
                Spacer()
                Spacer()
                Spacer()
                
                SignUpHeader()
                    .foregroundColor(.white)
                
                if !signUpErrorMessage.isEmpty {
                    Text("Failed creating account: \(signUpErrorMessage)")
                        .foregroundColor(.red)
                        .bold()
                } else {
                    Spacer()
                }
                
                HStack {
                    VStack {
                        SignUpCredentialFields(email: $email,
                                               password: $password,
                                               passwordConfirmation: $passwordConfirmation)
                            .modifier(ConcaveGlassView())
                            .foregroundColor(.black)
                    }
                    .offset(x: -55)
                    
                    Spacer()
                }
                Spacer()
                
                Button(action: {
                    signUpUser(userEmail: email, userPassword: password)
                    //signUpStripe(userEmail: email)
                    withAnimation {
                        firestore.next(newPage: .welcomePage)
                    }
                }) {
                    SignUpButtonContent(isProcessing: signUpProcessing)
                }
                .disabled(!signUpProcessing && !email.isEmpty && !password.isEmpty && !passwordConfirmation.isEmpty && password == passwordConfirmation ? false : true)

                Spacer()
            }
            .padding()
            
            if registrationDidSucceed {
                SignUpSuccessView()
            }
            
            Capsule()
                .fill(.black)
                .frame(width: 75, height: 5)
                .padding(10)
        }
        .background(Color("LaunchScreenBackground"))
        .frame(width: UIScreen.main.bounds.width,
               height: UIScreen.main.bounds.height)
        .blur(radius: 50)
        .brightness(-0.35)
        .preferredColorScheme(.dark)
    }
    
    func signUpUser(userEmail: String, userPassword: String) {
        
        signUpProcessing = true
        
        Auth.auth().createUser(withEmail: userEmail,
                               password: userPassword) { res, error in
            guard error == nil else {
                signUpErrorMessage = error!.localizedDescription
                signUpProcessing = false
                return
            }
            
            switch res {
            case .none:
                print("Could not create account")
                signUpProcessing = false
            case .some(_):
                firestore.setProfile(parameters: ["email": userEmail, "isAdmin": false, "striped": false, "currentLevel": Profile.Level.nine.rawValue, "balanceDue": 0, "acctNum": "new", "timeslot": Date(), "focusTarget": Profile.Focus.tb.rawValue, "username": userEmail.components(separatedBy: "@")[0]])
                print("User created")
                
                signUpErrorMessage = ""
                registrationDidSucceed = true
                signUpProcessing = false
            }
        }
    }
    
    func signUpStripe(userEmail: String) {
        cloud.createStripeConnectAccount(email: firestore.profile.email) { acctNum, error in
            guard error == nil else {
                print("Could not set up Stripe account #: \(error!)")
                firestore.currentPage = .loginPage
                return
            }
            
            switch acctNum {
            case .none:
                print("Could not create Stripe Connect account")
                withAnimation {
                    firestore.next(newPage: .loginPage)
                }
            case .some(_):
                print("Stripe Connect account created: \(acctNum!)")
                
                firestore.fetchProfile(email: userEmail)
                firestore.setProfile(parameters: ["acctNum": acctNum!, "email": userEmail])
            }
        }
    }
}

struct SignUpPage_Previews: PreviewProvider {
    static var previews: some View {
        SignUpPage()
            .preferredColorScheme(.dark)
    }
}

struct SignUpHeader: View {
    var body: some View {
        Text("NEW ACCOUNT")
            .font(Font.custom("BebasNeue", size: 50))
            .padding(.bottom, 20)
    }
}

struct SignUpButtonContent: View {
    let isProcessing: Bool
    
    var body: some View {
        if isProcessing {
            ProgressView()
                .padding()
                .foregroundColor(.white)
                .frame(width: 220, height: 45)
                .background(.black)
                .cornerRadius(15.0)
        } else {
            Text("SIGN UP")
                .font(Font.custom("BebasNeue", size: 35))
                .foregroundColor(.white)
                .padding()
                .frame(width: 220, height: 45)
                .background(Color("csf-earth"))
                .cornerRadius(15.0)
        }
    }
}

struct SignUpCredentialFields: View {
    
    @Binding var email: String
    @Binding var password: String
    @Binding var passwordConfirmation: String
    
    var body: some View {
        Group {
            TextField("Email", text: $email)
                .padding(20)
                .foregroundColor(.black)
                .frame(width: 325, height: 45)
                .background(.thinMaterial)
                .cornerRadius(10)
                .textInputAutocapitalization(.never)

            SecureField("Password", text: $password)
                .padding(20)
                .foregroundColor(.black)
                .frame(width: 325, height: 45)
                .background(.thinMaterial)
                .cornerRadius(10)

            SecureField("Confirm Password", text: $passwordConfirmation)
                .padding(20)
                .foregroundColor(Color("csf-main"))
                .frame(width: 325, height: 45)
                .background(.thinMaterial)
                .cornerRadius(10)
                .border(Color.red, width: passwordConfirmation != password ? 1 : 0)
        }
        .offset(x: -14)
    }
}

struct SignUpSuccessView: View {
    var body: some View {
        Text("Registration completed")
            .font(.headline)
            .frame(width: 250, height: 80)
            .background(Color("csf-earth"))
            .cornerRadius(20.0)
            .foregroundColor(.white)
            .animation(.easeIn, value: true)
    }
}

/*struct SafariView: UIViewControllerRepresentable {

    let url: URL
    if url == safariView([isSecureField("Password", text: $password)])

    func makeUIViewController(context: UIViewControllerRepresentableContext<SafariView>) -> SFSafariViewController {
        return SFSafariViewController(url: url)
    }

    func updateUIViewController(_ uiViewController: SFSafariViewController, context: UIViewControllerRepresentableContext<SafariView>) {

    }

}*/

