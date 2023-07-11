//
//  ViewController.swift
//  ExLongPressWithAnimation
//
//  Created by 김종권 on 2023/07/09.
//

import UIKit

class ViewController: UIViewController {
    private let someView = UIView()
    private let otherView = UIView()
    private let anotherView = UIView()
    private var snapshotedView: UIView?
    private var isDragging = false
    private var originalPosition = CGPoint.zero
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        someView.backgroundColor = .green
        otherView.backgroundColor = .lightGray
        anotherView.backgroundColor = .blue
        
        view.addSubview(someView)
        view.addSubview(otherView)
        view.addSubview(anotherView)

        someView.frame = .init(x: 120, y: 120, width: 100, height: 100)
        otherView.frame = .init(x: 120, y: 230, width: 100, height: 100)
        anotherView.frame = .init(x: 120, y: 340, width: 100, height: 100)
        
        let longPressGesture = UILongPressGestureRecognizer()
        longPressGesture.minimumPressDuration = 0.3
        longPressGesture.isEnabled = true
        longPressGesture.delegate = self
        longPressGesture.addTarget(self, action: #selector(handleLongPress))
        someView.addGestureRecognizer(longPressGesture)
    }
    
    @objc private func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        switch gesture.state {
        case .began:
            handleBegan(gesture)
        case .changed:
            handleChanged(gesture)
        default:
            // ended, canceled, failed
            handleEnded(gesture)
        }
    }

    private func handleBegan(_ gesture: UILongPressGestureRecognizer) {
        originalPosition = gesture.location(in: view)
        snapshotedView = someView.snapshotView(afterScreenUpdates: true)
        snapshotedView?.frame = someView.frame
        view.addSubview(snapshotedView!)
        someView.alpha = 0
        
        // Animation - 다른 뷰는 줄어들게하고, 이동시킬 뷰는 크게하기
        UIView.animate(
            withDuration: 0.4,
            delay: 0,
            usingSpringWithDamping: 0.8,
            initialSpringVelocity: 0,
            options: [.allowUserInteraction, .beginFromCurrentState],
            animations: { self.prepareDragAnimation() },
            completion: nil
        )
    }

    private func prepareDragAnimation() {
        let upScale = 1.2
        let scaleTranasform = CGAffineTransform(scaleX: upScale, y: upScale)
        
        let downYPosition = 10.0
        let translationTransform = CGAffineTransform(translationX: 0, y: downYPosition)
        snapshotedView?.transform = scaleTranasform.concatenating(translationTransform)
        
        snapshotedView?.alpha = 0.9

        let downScale = 0.8
        [otherView, anotherView]
            .forEach { subview in
                subview.transform = CGAffineTransform(scaleX: downScale, y: downScale)
            }
    }

    private func handleChanged(_ gesture: UILongPressGestureRecognizer) {
        let newLocation = gesture.location(in: view)
        let xOffset = newLocation.x - originalPosition.x
        let yOffset = newLocation.y - originalPosition.y
        let translationTransform = CGAffineTransform(translationX: xOffset, y: yOffset)
        
        // Animation - 업스케일 된 이동 시킬 뷰를 계속 업스케일된 상태로 유지하기
        let upScale = 1.2
        let scaleTranasform = CGAffineTransform(scaleX: upScale, y: upScale)
        snapshotedView?.transform = translationTransform.concatenating(scaleTranasform)
    }

    private func handleEnded(_ gesture: UILongPressGestureRecognizer) {
        someView.frame.origin = snapshotedView?.frame.origin ?? .zero
        snapshotedView?.alpha = 0
        snapshotedView?.removeFromSuperview()
        someView.alpha = 1
        
        // Animation - 스캐일 복구
        [someView, otherView, anotherView, snapshotedView]
            .compactMap { $0 }
            .forEach { subview in
                subview.transform = .identity
            }
    }
}

extension ViewController: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        !isDragging
    }
}
