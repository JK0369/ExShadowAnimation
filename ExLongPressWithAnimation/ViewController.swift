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
    }

    private func handleChanged(_ gesture: UILongPressGestureRecognizer) {
        let newLocation = gesture.location(in: view)
        let xOffset = newLocation.x - originalPosition.x
        let yOffset = newLocation.y - originalPosition.y
        let translation = CGAffineTransform(translationX: xOffset, y: yOffset)
        snapshotedView?.transform = translation
    }

    private func handleEnded(_ gesture: UILongPressGestureRecognizer) {
        someView.frame = snapshotedView?.frame ?? .zero
        snapshotedView?.alpha = 0
        snapshotedView?.removeFromSuperview()
        someView.alpha = 1
    }
}

extension ViewController: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        !isDragging
    }
}
