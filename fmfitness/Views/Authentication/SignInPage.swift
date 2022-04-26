//
//  SignInView.swift
//  fmfitness
//
//  Created by Brian Tacderan on 1/19/22.
//

import SwiftUI
import UIKit
import Firebase
import GoogleSignIn

struct SignInPage: View {
    
    @ObservedObject var firestore = FirestoreManager.shared
    @ObservedObject var authViewModel = AuthenticationViewModel.shared
    
    @State var showRegister = false
    
    @State var email: String = ""
    @State var password: String = ""
    
    @State var signInProcessing: Bool = false
    @State var signInErrorMessage: String = ""
    
    @State var authenticationDidSucceed: Bool = false
    
    var body: some View {
        if #available(iOS 15.0, *) {
            ZStack {
                ZStack {
                    ZStack {
                        VStack {
                            VStack {
                                HStack {
                                    WelcomeText()
                                        .padding(.leading)
                                    Spacer()
                                }
                                .transition(.move(edge: .trailing))
                                
                                SignInCredentialFields(email: $email, password: $password)
                                    .modifier(ConcaveGlassView())
                                    .transition(.move(edge: .trailing))
                                
                                if !signInErrorMessage.isEmpty {
                                    Text("Failed to sign in: \(signInErrorMessage)")
                                        .foregroundColor(.red)
                                        .bold()
                                        .padding()
                                } else {
                                    Spacer()
                                }
                                
                                Spacer()
                                Spacer()
                                
                                HStack(alignment: .center) {
                                    Button(action:{
                                        signInUser(userEmail: email, userPassword: password)
                                    }) {
                                        LoginButtonContent(isProcessing: signInProcessing)
                                    }
                                    .disabled(!signInProcessing && !email.isEmpty && !password.isEmpty ? false : true)
                                    .padding(.leading, 25)
                                    .transition(.move(edge: .trailing))
                                    
                                    GoogleSignInButtonWrapper(handler: authViewModel.signIn)
                                        .accessibility(hint: Text("Sign in with Google button"))
                                        .padding()
                                        .frame(width: 170, height: 75)
                                        .cornerRadius(10)
                                    
                                    Spacer()
                                }
                                
                                Spacer()
                                
                                HStack {
                                    Spacer()
                                    Text("Not a member? ")
                                        .font(Font.custom("BebasNeue", size: 25))
                                        .foregroundColor(.black)
                                    Button {
                                        showRegister.toggle()
                                    } label: {
                                        Text("Sign Up")
                                            .font(Font.custom("BebasNeue", size: 30))
                                            .foregroundColor(Color("csf-earth"))
                                    }
                                    Spacer()
                                }
                                .padding(.bottom, 20)
                                .sheet(isPresented: $showRegister) {
                                    SignUpPage()
                                }
                            }
                            .padding(.leading)
                            .frame(width: CGFloat(375), height: CGFloat(425))
                            .transition(.move(edge: .trailing))
                            .background(.thinMaterial)
                            .foregroundColor(.gray)
                            .foregroundStyle(.ultraThinMaterial)
                            .preferredColorScheme(.dark)
                            .cornerRadius(35)
                            .offset(x: 50)
                            .padding()
                            
                            if authenticationDidSucceed {
                                LoginSuccessView()
                            }
                        }
                    }
                    .frame(width: 375, height: 500)
                    .offset(y: -15)
                }
                /*.background(Image("cleans-silho")
                                .resizable()
                                .frame(width: 600, height: 850)
                                .tint(.gray)
                                .offset(x: -141, y: 30)
                                .blur(radius: 10)
                )*/
            }
            .background(Color("LaunchScreenBackground")
                            .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
        } else {
            ZStack {
                VStack {
                    WelcomeText()
                    
                    SignInCredentialFields(email: $email,
                                           password: $password)
                    
                    if !signInErrorMessage.isEmpty {
                        Text("Failed to sign in: \(signInErrorMessage)")
                            .foregroundColor(.red)
                            .bold()
                            .padding()
                    } else {
                        Spacer()
                    }
                    
                    VStack {
                        Spacer()
                        VStack {
                            Button(action: {
                                signInUser(userEmail: email,
                                           userPassword: password)
                            }) {
                                LoginButtonContent(isProcessing: signInProcessing)
                            }
                            .disabled(!signInProcessing && !email.isEmpty && !password.isEmpty ? false : true)
                            .padding(10)
                            
                            Text("or")
                            
                            GoogleSignInButtonWrapper(handler: authViewModel.signIn)
                                .accessibility(hint: Text("Sign in with Google button."))
                        }
                        Spacer()
                        Spacer()
                    }
                    Spacer()
                    HStack {
                        Text("Not a member? ")
                            .font(Font.custom("BebasNeue", size: 25))
                            .foregroundColor(.white)
                        Button("SIGN UP") {
                            withAnimation(.easeInOut(duration: 0.5)) {
                                showRegister.toggle()
                            }
                        }
                        .padding(.trailing)
                        Spacer()
                    }
                    .padding()
                    .transition(.move(edge: .trailing))
                    Spacer()
                }
                .padding()
                if authenticationDidSucceed {
                    LoginSuccessView()
                }
            }
        }
    }
    
    func signInUser(userEmail: String, userPassword: String) {
        signInProcessing = true
        
        Auth.auth().signIn(withEmail: userEmail,
                           password: userPassword) { authResult, error in
            guard error == nil else {
                signInProcessing = false
                signInErrorMessage = error!.localizedDescription
                return
            }
            
            switch authResult {
            case .none:
                print("Could not sign in user.")
                signInProcessing = false
            case .some(_):
                print("User signed in")
                signInProcessing = false
                signInErrorMessage = ""
                authenticationDidSucceed = true
                firestore.login(email: userEmail)
            }
        }
    }
}

/// Having an extension of `Text` allows us to access such text with `self`.
private extension Text {
    func innerShadow<V: View>(_ background: V,
                              radius: CGFloat = 5,
                              opacity: Double = 0.7) -> some View {
        self
            .foregroundColor(.clear)
            .overlay(background.mask(self))
            .overlay(
                ZStack {
                    self.foregroundColor(Color(white: 1 - opacity))
                    self.foregroundColor(.white).blur(radius: radius)
                }
                .mask(self)
                .blendMode(.multiply)
            )
    }
}

struct SignInPage_Previews: PreviewProvider {
    static var previews: some View {
        SignInPage()
            .previewInterfaceOrientation(.portrait)
            .preferredColorScheme(.dark)
    }
}

struct FlatGlassView: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 15.0, *) {
            content
                .padding()
                .frame(height: 45)
                .background(.ultraThinMaterial)
                .cornerRadius(10)
        } else {
            // Fallback on earlier versions
            content
                .padding()
                .frame(height: 65)
                .cornerRadius(10)
        }
    }
}


struct ConvexGlassView: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 15.0, *) {
            content
                .padding()
                .frame(width: 180, height: 45)
                .background(.ultraThinMaterial)
                .overlay(
                    LinearGradient(colors: [.clear,.black.opacity(0.2)], startPoint: .top, endPoint: .bottom))
                .cornerRadius(10)
                .shadow(color: .white.opacity(0.65), radius: 1, x: -1, y: -2)
                .shadow(color: .black.opacity(0.65), radius: 2, x: 2, y: 2)
        } else {
            // Fallback on earlier versions
            content
                .padding()
                .frame(height: 45)
                .cornerRadius(10)
                .shadow(color: .white, radius: 3, x: -3, y: -3)
                .shadow(color: .black, radius: 3, x: 3, y: 3)
        }
    }
}

struct ConcaveGlassView: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 15.0, *) {
            content
                .padding()
                .frame(width: 355, height: 45)
                .background(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(.linearGradient(colors:[.black,.white.opacity(0.75)], startPoint: .top, endPoint: .bottom), lineWidth: 2)
                        .blur(radius: 1)
                        .zIndex(-3)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(.radialGradient(Gradient(colors: [.clear,.black.opacity(0.1)]), center: .bottomLeading, startRadius: 300, endRadius: 0), lineWidth: 15)
                        .offset(y: 5)
                )
                .offset(x: 30)
                .cornerRadius(14)
        } else {
            // Fallback on earlier versions
            content
                .padding()
                .frame(width: 325, height: 45)
                .cornerRadius(14)
                .shadow(color: .white, radius: 3, x: -3, y: -3)
                .shadow(color: .black, radius: 3, x: 3, y: 3)
        }
    }
}

struct WelcomeText: View {
    var body: some View {
        HStack {
            Text("FM")
                .font(Font.custom("BebasNeue", size: 50))
            
            Text("FITNESS")
                .font(Font.custom("Rajdhani", size: 25))
        }
        .foregroundColor(.white)
        .padding(.bottom)
        .offset(y: 25)
    }
}
    
fileprivate struct SignInCredentialFields: View {
    
    @Binding var email: String
    @Binding var password: String
    
    var body: some View {
        Group {
            TextField("Email", text: $email)
                .padding(20)
                .padding(.top, 50)
                .frame(width: 270, height: 55)
                .padding(.trailing, 70)
                .background(.thinMaterial)
                .cornerRadius(14)
                .multilineTextAlignment(.trailing)
                .textInputAutocapitalization(.never)
            SecureField("Password", text: $password)
                .padding(20)
                .frame(width: 270, height: 55)
                .padding(.trailing, 70)
                .background(.thinMaterial)
                .cornerRadius(14)
                .multilineTextAlignment(.trailing)
        }
    }
}

fileprivate struct LoginButtonContent: View {
    let isProcessing: Bool
    
    var body: some View {
        if isProcessing {
            ProgressView()
                .padding()
                .frame(width: 180, height: 45)
                .background(Color("csf-earth"))
                .cornerRadius(10)
                .modifier(ConvexGlassView())
        } else {
            Text("LOGIN")
                .font(Font.custom("BebasNeue", size: 40))
                .foregroundColor(Color("csf-main"))
                .padding()
                .frame(width: 180, height: 85)
                .background(Color("csb-main"))
                .cornerRadius(10)
                .modifier(ConvexGlassView())
        }
    }
}

fileprivate struct EmailTextField: View {
    @Binding var email: String
    var body: some View {
        TextField("Email", text: $email)
            .padding()
            .background(Color("csb-main"))
            .cornerRadius(5.0)
            .padding(.bottom, 20)
    }
}

fileprivate struct PasswordSecureField: View {
    @Binding var password: String
    var body: some View {
        SecureField("Password", text: $password)
            .padding()
            .background(Color("csb-main"))
            .cornerRadius(5.0)
            .padding(.bottom, 20)
    }
}

fileprivate struct LoginSuccessView: View {
    var body: some View {
        Text("Successfully logged in")
            .font(.headline)
            .frame(width: 250, height: 80)
            .background(Color.green)
            .cornerRadius(20.0)
            .foregroundColor(.white)
            .animation(.easeIn, value: true)
    }
}
