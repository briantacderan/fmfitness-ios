//
//  SignInView.swift
//  fmfitness
//
//  Created by Brian Tacderan on 3/20/22.
//

import SwiftUI
import GoogleSignIn
import Firebase

struct SignInView: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.controller) var controller
    
    @ObservedObject var authViewModel = AuthenticationViewModel.shared
    @ObservedObject var firestore = FirestoreManager.shared
    
    @State var email: String = ""
    @State var password: String = ""
    @State var signInProcessing: Bool = false
    @State var signInErrorMessage: String = ""
    @State var authenticationDidSucceed: Bool = false
    
    var body: some View {
        SideBarStack(sidebarWidth: 125, showSidebar: $firestore.showSidebar) {
            MenuView()
        } content: {
            NavigationView {
                ZStack {
                    ZStack {
                        ZStack {
                            VStack {
                                VStack {
                                    HStack {
                                        WelcomeText()
                                        Spacer()
                                    }
                                    
                                    SignInCredentialFields(email: $email, password: $password)
                                        .modifier(ConcaveGlassView())
                                    
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
                                        
                                        Text("   or ")
                                            .font(Font.custom("BebasNeue", size: 20))
                                        
                                        GoogleSignInButtonWrapper(handler: authViewModel.signIn)
                                            .accessibility(hint: Text("Sign in with Google button"))
                                            .frame(width: 48, height: 48)
                                            .border(Color("csf-main"), width: 6)
                                            .cornerRadius(8)
                                        
                                        Spacer()
                                    }
                                    
                                    HStack {
                                        Spacer()
                                        Text("Not a member? ")
                                            .font(Font.custom("Rajdhani-Light", size: 20))
                                            .foregroundColor(.black)
                                        
                                        Button {
                                            withAnimation(.easeIn(duration: 0.2)) {
                                                firestore.induceShade.toggle()
                                                AlertController().requireKey()
                                            }
                                        } label: {
                                            Text("Sign Up")
                                                .font(Font.custom("BebasNeue", size: 30))
                                                .foregroundColor(Color("csf-menu"))
                                                .accentColor(Color("csf-menu"))
                                                .tint(Color("csf-menu"))
                                        }
                                        
                                        Spacer()
                                    }
                                    .font(Font.custom("BebasNeue", size: 30))
                                    .foregroundColor(Color("csf-main"))
                                    .padding(.bottom, 20)
                                    .padding(.top, 20)
                                    .sheet(isPresented: $firestore.showRegister) {
                                        SignUpPage()
                                            .frame(width: UIScreen.width,
                                                   height: UIScreen.height*2/3)
                                            .cornerRadius(10)
                                            .offset(y: UIScreen.height*2/11)
                                            .ignoresSafeArea()
                                            .background(BackgroundClearView())
                                    }
                                }
                                .padding(.leading)
                                .frame(width: CGFloat(375), height: CGFloat(375))
                                .background(.thinMaterial)
                                .foregroundColor(.gray)
                                .foregroundStyle(.ultraThinMaterial)
                                .cornerRadius(35)
                                .offset(x: 50)
                                .padding()
                                .opacity(firestore.showRegister ? 0.2 : 1)
                                .offset(x: firestore.showRegister ? UIScreen.width : 0)
                                .transition(AnyTransition.homerSimpson)
                                
                                if authenticationDidSucceed {
                                    LoginSuccessView()
                                }
                            }
                            .animation(.default, value: firestore.showProfile)
                        }
                        .frame(width: 375, height: 500)
                        .offset(y: -15)
                    }
                }
                .frame(width: UIScreen.width,
                       height: UIScreen.height)
                .background(Color("LaunchScreenColor"))
                .ignoresSafeArea()
                .overlay(
                    withAnimation(.easeInOut(duration: 0.2)) {
                        ShadeView()
                    }
                )
                .offset(y: -50)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        MenuButton()
                            .onTapGesture {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    firestore.showSidebar.toggle()
                                }
                            }
                    }
                    ToolbarItem(placement: .navigationBarLeading) {
                        Text("Sign in")
                            .foregroundColor(Color("csf-main"))
                            .font(Font.custom("Rajdhani-Regular", size: 16))
                            .padding(.bottom, 10)
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        LogoButton()
                            .foregroundColor(Color("csf-menu"))
                            .accentColor(Color("csf-menu"))
                            .tint(Color("csf-menu"))
                    }
                }
            }
        }
        .edgesIgnoringSafeArea(.all)
    }
    
    func signInUser(userEmail: String, userPassword: String) {
        signInProcessing = true
        
        Auth.auth().signIn(withEmail: userEmail,
                           password: userPassword) { res, error in
            guard error == nil else {
                signInProcessing = false
                signInErrorMessage = error!.localizedDescription
                return
            }
            
            switch res {
            case .none:
                print("Could not sign in user.")
                signInProcessing = false
            case .some(_):
                print("User signed in")
                signInProcessing = false
                signInErrorMessage = ""
                authenticationDidSucceed = true
                firestore.firstLogin = true
                controller.login(uid: res!.user.uid, email: userEmail)
            }
        }
    }
}

struct SignInView_Previews: PreviewProvider {
    static var previews: some View {
        SignInView()
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
                .frame(width: 325, height: 55)
                .background(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(.linearGradient(colors:[.black,.white.opacity(0.75)], startPoint: .top, endPoint: .bottom), lineWidth: 2)
                        .blur(radius: 1)
                        .zIndex(-3)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(.radialGradient(Gradient(colors: [.clear,.black.opacity(0.1)]), center: .bottomLeading, startRadius: 300, endRadius: 0), lineWidth: 15)
                        .offset(x: 5, y: 5)
                )
                .offset(x: 30)
                .cornerRadius(10)
        } else {
            // Fallback on earlier versions
            content
                .padding()
                .frame(width: 325, height: 55)
                .cornerRadius(10)
                .shadow(color: .white, radius: 3, x: -3, y: -3)
                .shadow(color: .black, radius: 3, x: 3, y: 3)
        }
    }
}

struct WelcomeText: View {
    var body: some View {
        HStack(spacing: 0) {
            Text("FM")
                .font(Font.custom("BebasNeue", size: 40))
            
            Text("FITNESS")
                .font(Font.custom("Rajdhani-Light", size: 40))
        }
        .foregroundColor(Color("csf-main"))
        .padding(.top)
        .padding(.leading)
    }
}
    
fileprivate struct SignInCredentialFields: View {
    
    @Binding var email: String
    @Binding var password: String
    
    var body: some View {
        Group {
            TextField("Email", text: $email)
                .padding(20)
                .frame(width: 325, height: 55)
                .padding(.trailing, 80)
                .cornerRadius(10)
                .multilineTextAlignment(.trailing)
                .textInputAutocapitalization(.never)
            SecureField("Password", text: $password)
                .padding(20)
                .frame(width: 325, height: 55)
                .padding(.trailing, 80)
                .cornerRadius(10)
                .multilineTextAlignment(.trailing)
        }
        .font(Font.custom("Rajdhani-Regular", size: 15))
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

/*
struct SignUpButtonWrapper: UIViewRepresentable {
    let handler: () -> Void

    init(handler: @escaping () -> Void) {
        self.handler = handler
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator()
    }

    func makeUIView(context: Context) -> SignUpButton {
        let signInButton = GIDSignInButton()
        signInButton.addTarget(context.coordinator,
                               action: #selector(Coordinator.callHandler),
                               for: .touchUpInside)
        signInButton.style = .iconOnly
        signInButton.colorScheme = .light
        return signInButton
    }

    func updateUIView(_ uiView: UIViewType, context: Context) {
        context.coordinator.handler = handler
    }
}

extension SignUpButtonWrapper {
  class Coordinator {
    var handler: (() -> Void)?

    @objc func callHandler() {
      handler?()
    }
  }
}
*/

@available(iOS 15.0, *)
struct AdaptiveSheet<T: View>: ViewModifier {
    let sheetContent: T
    @Binding var isPresented: Bool
    let detents : [UISheetPresentationController.Detent]
    let smallestUndimmedDetentIdentifier: UISheetPresentationController.Detent.Identifier?
    let prefersScrollingExpandsWhenScrolledToEdge: Bool
    let prefersEdgeAttachedInCompactHeight: Bool
    
    init(isPresented: Binding<Bool>, detents : [UISheetPresentationController.Detent] = [.medium(), .large()], smallestUndimmedDetentIdentifier: UISheetPresentationController.Detent.Identifier? = .medium, prefersScrollingExpandsWhenScrolledToEdge: Bool = false, prefersEdgeAttachedInCompactHeight: Bool = true, @ViewBuilder content: @escaping () -> T) {
        self.sheetContent = content()
        self.detents = detents
        self.smallestUndimmedDetentIdentifier = smallestUndimmedDetentIdentifier
        self.prefersEdgeAttachedInCompactHeight = prefersEdgeAttachedInCompactHeight
        self.prefersScrollingExpandsWhenScrolledToEdge = prefersScrollingExpandsWhenScrolledToEdge
        self._isPresented = isPresented
    }
    func body(content: Content) -> some View {
        ZStack{
            content
            CustomSheet_UI(isPresented: $isPresented, detents: detents, smallestUndimmedDetentIdentifier: smallestUndimmedDetentIdentifier, prefersScrollingExpandsWhenScrolledToEdge: prefersScrollingExpandsWhenScrolledToEdge, prefersEdgeAttachedInCompactHeight: prefersEdgeAttachedInCompactHeight, content: {sheetContent}).frame(width: 0, height: 0)
        }
    }
}
@available(iOS 15.0, *)
extension View {
    func adaptiveSheet<T: View>(isPresented: Binding<Bool>, detents : [UISheetPresentationController.Detent] = [.medium(), .large()], smallestUndimmedDetentIdentifier: UISheetPresentationController.Detent.Identifier? = .medium, prefersScrollingExpandsWhenScrolledToEdge: Bool = false, prefersEdgeAttachedInCompactHeight: Bool = true, @ViewBuilder content: @escaping () -> T)-> some View {
        modifier(AdaptiveSheet(isPresented: isPresented, detents : detents, smallestUndimmedDetentIdentifier: smallestUndimmedDetentIdentifier, prefersScrollingExpandsWhenScrolledToEdge: prefersScrollingExpandsWhenScrolledToEdge, prefersEdgeAttachedInCompactHeight: prefersEdgeAttachedInCompactHeight, content: content))
    }
}

@available(iOS 15.0, *)
struct CustomSheet_UI<Content: View>: UIViewControllerRepresentable {
    
    let content: Content
    @Binding var isPresented: Bool
    let detents : [UISheetPresentationController.Detent]
    let smallestUndimmedDetentIdentifier: UISheetPresentationController.Detent.Identifier?
    let prefersScrollingExpandsWhenScrolledToEdge: Bool
    let prefersEdgeAttachedInCompactHeight: Bool
    
    init(isPresented: Binding<Bool>, detents : [UISheetPresentationController.Detent] = [.medium(), .large()], smallestUndimmedDetentIdentifier: UISheetPresentationController.Detent.Identifier? = .medium, prefersScrollingExpandsWhenScrolledToEdge: Bool = false, prefersEdgeAttachedInCompactHeight: Bool = true, @ViewBuilder content: @escaping () -> Content) {
        self.content = content()
        self.detents = detents
        self.smallestUndimmedDetentIdentifier = smallestUndimmedDetentIdentifier
        self.prefersEdgeAttachedInCompactHeight = prefersEdgeAttachedInCompactHeight
        self.prefersScrollingExpandsWhenScrolledToEdge = prefersScrollingExpandsWhenScrolledToEdge
        self._isPresented = isPresented
    }
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    func makeUIViewController(context: Context) -> CustomSheetViewController<Content> {
        let vc = CustomSheetViewController(coordinator: context.coordinator, detents : detents, smallestUndimmedDetentIdentifier: smallestUndimmedDetentIdentifier, prefersScrollingExpandsWhenScrolledToEdge:  prefersScrollingExpandsWhenScrolledToEdge, prefersEdgeAttachedInCompactHeight: prefersEdgeAttachedInCompactHeight, content: {content})
        return vc
    }
    
    func updateUIViewController(_ uiViewController: CustomSheetViewController<Content>, context: Context) {
        if isPresented {
            uiViewController.presentModalView()
        } else {
            withAnimation(.easeInOut(duration: 0.25)) {
                uiViewController.dismissModalView()
            }
        }
    }
    class Coordinator: NSObject, UIAdaptivePresentationControllerDelegate {
        var parent: CustomSheet_UI
        init(_ parent: CustomSheet_UI) {
            self.parent = parent
        }
        //Adjust the variable when the user dismisses with a swipe
        func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
            if parent.isPresented {
                withAnimation(.easeInOut(duration: 0.25)) {
                    parent.isPresented = false
                }
            }
            
        }
        
    }
}

@available(iOS 15.0, *)
class CustomSheetViewController<Content: View>: UIViewController {
    let content: Content
    let coordinator: CustomSheet_UI<Content>.Coordinator
    let detents : [UISheetPresentationController.Detent]
    let smallestUndimmedDetentIdentifier: UISheetPresentationController.Detent.Identifier?
    let prefersScrollingExpandsWhenScrolledToEdge: Bool
    let prefersEdgeAttachedInCompactHeight: Bool
    private var isLandscape: Bool = UIDevice.current.orientation.isLandscape
    init(coordinator: CustomSheet_UI<Content>.Coordinator, detents : [UISheetPresentationController.Detent] = [.medium(), .large()], smallestUndimmedDetentIdentifier: UISheetPresentationController.Detent.Identifier? = .medium, prefersScrollingExpandsWhenScrolledToEdge: Bool = false, prefersEdgeAttachedInCompactHeight: Bool = true, @ViewBuilder content: @escaping () -> Content) {
        self.content = content()
        self.coordinator = coordinator
        self.detents = detents
        self.smallestUndimmedDetentIdentifier = smallestUndimmedDetentIdentifier
        self.prefersEdgeAttachedInCompactHeight = prefersEdgeAttachedInCompactHeight
        self.prefersScrollingExpandsWhenScrolledToEdge = prefersScrollingExpandsWhenScrolledToEdge
        super.init(nibName: nil, bundle: .main)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func dismissModalView(){
        dismiss(animated: true, completion: nil)
    }
    func presentModalView(){
        
        let hostingController = UIHostingController(rootView: content)
        
        hostingController.modalPresentationStyle = .popover
        hostingController.presentationController?.delegate = coordinator as UIAdaptivePresentationControllerDelegate
        hostingController.modalTransitionStyle = .coverVertical
        if let hostPopover = hostingController.popoverPresentationController {
            hostPopover.sourceView = super.view
            let sheet = hostPopover.adaptiveSheetPresentationController
            //As of 13 Beta 4 if .medium() is the only detent in landscape error occurs
            sheet.detents = (isLandscape ? [.large()] : detents)
            sheet.largestUndimmedDetentIdentifier =
            smallestUndimmedDetentIdentifier
            sheet.prefersScrollingExpandsWhenScrolledToEdge =
            prefersScrollingExpandsWhenScrolledToEdge
            sheet.prefersEdgeAttachedInCompactHeight =
            prefersEdgeAttachedInCompactHeight
            sheet.widthFollowsPreferredContentSizeWhenEdgeAttached = true
            
        }
        if presentedViewController == nil {
            present(hostingController, animated: true, completion: nil)
        }
    }
    /// To compensate for orientation as of 13 Beta 4 only [.large()] works for landscape
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        if UIDevice.current.orientation.isLandscape {
            isLandscape = true
            self.presentedViewController?.popoverPresentationController?.adaptiveSheetPresentationController.detents = [.large()]
        } else {
            isLandscape = false
            self.presentedViewController?.popoverPresentationController?.adaptiveSheetPresentationController.detents = detents
        }
    }
}
