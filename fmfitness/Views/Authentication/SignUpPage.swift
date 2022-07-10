//
//  SignUpView.swift
//  fmfitness
//
//  Created by Brian Tacderan on 1/19/22.
//

import SwiftUI
import SafariServices
import Firebase

struct SignUpPage: View {
    
    @Environment(\.isPresented) var isPresented
    @Environment(\.dismiss) var dismiss
    @Environment(\.controller) var controller
    
    @ObservedObject var firestore = FirestoreManager.shared
    
    @State var username = ""
    @State var email = ""
    @State var password = ""
    @State var passwordConfirmation = ""
    
    @State private var signUpProcessing = false
    @State private var signUpErrorMessage = ""
    @State private var registrationDidSucceed = false
    
    var alertView: UIAlertController?
    
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
                    }
                    
                    Spacer()
                }
                Spacer()
                
                Button(action: {
                    signUpUser(userEmail: email, userPassword: password)
                    //signUpStripe(userEmail: email)
                    withAnimation {
                        firestore.authRedirect = Page.loginPage
                    }
                }) {
                    SignUpButtonContent(isProcessing: signUpProcessing)
                        .foregroundColor((signUpProcessing || passwordConfirmation.isEmpty || (password != passwordConfirmation)) ? Color("B1-red") : Color("csb-sheet-light"))
                }
                .disabled(signUpProcessing || passwordConfirmation.isEmpty || (password != passwordConfirmation))

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
        .background(Color("csb-gray").opacity(0.5))
        .frame(width: UIScreen.width,
               height: UIScreen.height*2/3)
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
                controller.setProfile(parameters: ["uid": res!.user.uid, "email": userEmail, "admin": false, "member": true, "level": Profile.Level.nine.rawValue, "balance": 0, "timeslot": Date(), "info": "new", "focus": Profile.Focus.tb.rawValue, "username": userEmail.components(separatedBy: "@")[0]])
                print("User created")
                
                signUpErrorMessage = ""
                registrationDidSucceed = true
                signUpProcessing = false
                if isPresented {
                    withAnimation(.easeInOut(duration: 0.25)) {
                        dismiss()
                    }
                }
            }
        }
    }
    
    /*
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
    }*/
}

struct SignUpPage_Previews: PreviewProvider {
    static var previews: some View {
        SignUpPage()
            .preferredColorScheme(.dark)
    }
}

struct SignUpHeader: View {
    var body: some View {
        HStack {
            Text("New")
            
            HStack(spacing: 0) {
                Text("FM")
                    .foregroundColor(.black)
                    .font(Font.custom("BebasNeue", size: 35))
                Text("ACCOUNT")
            }
        }
        .font(Font.custom("Rajdhani-Light", size: 35))
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
                //.foregroundColor(Color("csf-spin"))
                .padding()
                .frame(width: 220, height: 45)
                .background(Color("csb-main"))
                .cornerRadius(14.0)
                .padding(.top, 20)
                .padding(.bottom, 50)
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
                .foregroundColor(Color("csf-main"))
                .frame(width: 325, height: 55)
                .background(.thinMaterial)
                .cornerRadius(10)
                .textInputAutocapitalization(.never)
                .modifier(ConcaveGlassView())

            SecureField("Password", text: $password)
                .padding(20)
                .foregroundColor(Color("csf-main"))
                .frame(width: 325, height: 55)
                .background(.thinMaterial)
                .cornerRadius(10)
                .modifier(ConcaveGlassView())

            SecureField("Confirm Password", text: $passwordConfirmation)
                .padding(20)
                .foregroundColor(Color("csf-main"))
                .frame(width: 325, height: 55)
                .background(.thinMaterial)
                .cornerRadius(10)
                .border(Color("B1-red"), width: passwordConfirmation != password ? 1 : 0)
                .modifier(ConcaveGlassView())
        }
        .font(Font.custom("Rajdhani-Light", size: 16))
    }
}

struct SignUpSuccessView: View {
    var body: some View {
        Text("Registration completed")
            .font(.headline)
            .frame(width: 250, height: 80)
            .background(Color("csf-main"))
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

