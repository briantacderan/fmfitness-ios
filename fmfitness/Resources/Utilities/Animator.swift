//
//  Animator.swift
//  fmfitness
//
//  Created by Brian Tacderan on 2/11/22.
//

import UIKit
import SwiftUI

extension AnyTransition {
    public static var homerSimpson: AnyTransition {
        AnyTransition.slide.combined(with: .opacity)
    }
    
    public static var scaleAndBlur: AnyTransition {
        .asymmetric(
            insertion: .move(edge: .trailing).combined(with: .opacity),
            removal: .scale.combined(with: .opacity)
        )
    }
    
    public static var moveFromBottom: AnyTransition {
        AnyTransition.move(edge: .bottom)
    }
}

struct NavTransitions: View {
    var body: some View {
        ZStack {
            FrameInfo()
        }
    }
}

struct NavTransitions_Previews: PreviewProvider {
    static var previews: some View {
        NavTransitions()
    }
}

struct FrameInfo: View {
    var body: some View {
        GeometryReader { geometry -> Text in
            let frame = geometry.frame(in: CoordinateSpace.local)
            return Text("\(frame.origin.x), \(frame.origin.y), \(frame.size.width), \(frame.size.height)")
        }
    }
}

class Animator: NSObject, UIViewControllerAnimatedTransitioning {
  enum TransitionDirection {
    case right
    case left
  }

  let transitionDuration: Double = 0.20
  let transitionDirection: TransitionDirection

  init(_ direction: TransitionDirection) {
    transitionDirection = direction
  }

  func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?)
    -> TimeInterval {
    return transitionDuration as TimeInterval
  }

  func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
    let container = transitionContext.containerView

    guard let fromView = transitionContext.view(forKey: .from),
      let toView = transitionContext.view(forKey: .to) else {
      transitionContext.completeTransition(false)
      return
    }

    let translation: CGFloat = transitionDirection == .right ? container.frame.width : -container
      .frame.width
    let toViewStartFrame = container.frame
      .applying(CGAffineTransform(translationX: translation, y: 0))
    let fromViewFinalFrame = container.frame
      .applying(CGAffineTransform(translationX: -translation, y: 0))

    container.addSubview(toView)
    toView.frame = toViewStartFrame

    UIView.animate(withDuration: transitionDuration, animations: {
      fromView.frame = fromViewFinalFrame
      toView.frame = container.frame

    }) { _ in
      fromView.removeFromSuperview()
      transitionContext.completeTransition(true)
    }
  }
}
