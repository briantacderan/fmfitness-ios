//
//  SplashScreen.swift
//  fmfitness
//
//  Created by Brian Tacderan on 4/24/22.
//

import SwiftUI

struct SplashView: View {
    @State var showSplash = true
    
    var body: some View {
        ZStack {
            SplashScreen()
                .opacity(showSplash ? 1 : 0)
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                        SplashScreen.shouldAnimate = false
                        withAnimation() {
                            self.showSplash = false
                        }
                    }
                }
        }
    }
}

struct SplashView_Previews : PreviewProvider {
    static var previews: some View {
        SplashView()
            //.preferredColorScheme(.dark)
    }
}

struct SplashScreen: View {
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    
    static var shouldAnimate = true
    let csf = Color("LaunchScreenColorTile")
    let csb = Color("LaunchScreenColor")
    let uLineWidth: CGFloat = 10
    let uZoomFactor: CGFloat = 1.4
    let lineWidth:  CGFloat = 40
    let lineHeight: CGFloat = 28
    let uSquareLength: CGFloat = 12

    @State var percent = 0.0
    @State var uScale: CGFloat = 1
    @State var squareColor = Color("csf-main")
    @State var squareScale: CGFloat = 1
    @State var lineScale: CGFloat = 1
    @State var textAlpha = 0.0
    @State var textScale: CGFloat = 1
    @State var coverCircleScale: CGFloat = 1
    @State var coverCircleAlpha = 0.0
    @State var coverAlpha = 0.1

    var body: some View {
        ZStack {
            Image("LaunchBlackTile")
                .resizable()
                .renderingMode(.template)
                .foregroundColor(csf)
                .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                .aspectRatio(1, contentMode: .fit)
                .opacity(coverAlpha)
                .scaleEffect(textScale)
      
            Circle()
                .fill(csb)
                .frame(width: 1, height: 1, alignment: .center)
                .scaleEffect(coverCircleScale)
                .opacity(coverCircleAlpha)
            
            Image("fmf-logo-white")
                .renderingMode(.template)
                .foregroundColor(csf)
                .scaleEffect(lineScale, anchor: .bottom)
                .frame(width: lineWidth, height: lineHeight,
                       alignment: .center)
            
            ExpandingCircle(percent: percent)
                .stroke(csf, lineWidth: uLineWidth)
                .rotationEffect(.degrees(90))
                .aspectRatio(1, contentMode: .fit)
                .opacity(textAlpha)
                .padding(20)
                .onAppear() {
                    self.handleAnimations()
                }
                .scaleEffect(uScale * uZoomFactor)
                .frame(width: 200, height: 200, alignment: .center)
                .offset(y: 30)
      
            Text("FM Fitness")
                .font(Font.custom("BebasNeue", size: 50))
                .foregroundColor(csf)
                .opacity(textAlpha)
                .scaleEffect(textScale)
            
            Spacer()
        }
        .background(csb)
        .edgesIgnoringSafeArea(.all)
    }
}

extension SplashScreen {
    var uAnimationDuration: Double { return 1.5 }
    var uAnimationDelay: Double { return  0.3 }
    var uExitAnimationDuration: Double { return 0.45 }
    var finalAnimationDuration: Double { return 0.6 }
    var minAnimationInterval: Double { return 0.15 }
    var fadeAnimationDuration: Double { return 0.6 }
  
    func handleAnimations() {
        runAnimationPart1()
        runAnimationPart2()
        runAnimationPart3()
        if SplashScreen.shouldAnimate {
            restartAnimation()
        }
  }
  
    func runAnimationPart1() {
        withAnimation(.easeIn(duration: uAnimationDuration)) {
            percent = 1
            uScale = 5
            lineScale = 2
        }
        
        withAnimation(Animation.easeIn(duration: uAnimationDuration).delay(0.55)) {
            coverAlpha = 0.8
        }
    
        withAnimation(Animation.easeIn(duration: uAnimationDuration).delay(1.2)) {
            textAlpha = 1.0
        }
    
        let deadline: DispatchTime = .now() + uAnimationDuration + uAnimationDelay
        DispatchQueue.main.asyncAfter(deadline: deadline) {
            withAnimation(.easeOut(duration: self.uExitAnimationDuration)) {
                self.uScale = 0
                self.lineScale = 0
            }
            withAnimation(.easeOut(duration: self.minAnimationInterval)) {
                self.squareScale = 0
            }
      
            withAnimation(Animation.spring()) {
                self.textScale = self.uZoomFactor
            }
        }
    }
  
    func runAnimationPart2() {
        let deadline: DispatchTime = .now() + uAnimationDuration + uAnimationDelay + minAnimationInterval
        DispatchQueue.main.asyncAfter(deadline: deadline) {
            self.squareColor = csf
            self.squareScale = 1
            withAnimation(.easeOut(duration: self.fadeAnimationDuration)) {
                self.coverCircleAlpha = 1
                self.coverCircleScale = 1000
            }
        }
    }
  
    func runAnimationPart3() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2*uAnimationDuration) {
            withAnimation(.easeIn(duration: self.finalAnimationDuration)) {
                self.textAlpha = 0
                self.coverAlpha = 0.2
                self.squareColor = self.csb
            }
        }
    }
  
    func restartAnimation() {
        let deadline: DispatchTime = .now() + 2*uAnimationDuration + finalAnimationDuration
        DispatchQueue.main.asyncAfter(deadline: deadline) {
            self.percent = 0
            self.textScale = 1
            self.coverCircleAlpha = 0
            self.coverCircleScale = 1
            self.handleAnimations()
        }
    }
}

struct ExpandingCircle: Shape {
    var percent: Double
  
    func path(in rect: CGRect) -> Path {
        let end = percent * 360
        var p = Path()
    
        p.addArc(center: CGPoint(x: rect.size.width/2, y: rect.size.width/2),
                 radius: rect.size.width/2,
                 startAngle: Angle(degrees: 0),
                 endAngle: Angle(degrees: end),
                 clockwise: false)
    
        return p
    }
  
    var animatableData: Double {
        get { return percent }
        set { percent = newValue }
    }
}
