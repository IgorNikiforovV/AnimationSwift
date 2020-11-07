//
//  ViewController.swift
//  DZ13_Animation_additional_tasks
//
//  Created by Игорь Никифоров on 17.10.2020.
//  Copyright © 2020 Игорь Никифоров. All rights reserved.
//

import UIKit

class YandexGRController: UIViewController {


    override func viewDidLoad() {
        super.viewDidLoad()

        setupBoxView()
        setupButtonView()
        setupGestureRecognizers()

    }

    // MARK: - Private properties

    // bix view properties

    private static let boxCornerRadius: CGFloat = 10.0
    private static let initialBoxDimSize: CGFloat = 150.0
    private static let boxPossibleColors: [UIColor] = [.red, .green, .blue]

    private let box = UIView()

    private var widthConstraint: NSLayoutConstraint!
    private var heightConstraint: NSLayoutConstraint!
    private var centerYConstraint: NSLayoutConstraint!
    private var centerXConstraint: NSLayoutConstraint!

    private var scale: CGFloat = 1.0 { didSet{ updateBoxTransform() } }
    private var rotation: CGFloat = 0.0 { didSet{ updateBoxTransform() } }

    private var colorIndex = 0

    // button view properties

    private let button = UIButton()

    // gesture recognizers

    private static let forceGestureRecognizerThreshold: CGFloat = 3.0

    private let panGestureRecognizer = UIPanGestureRecognizer()
    private let pinchGestureRecognizer = UIPinchGestureRecognizer()
    private let rotateGestureRecognizer = UIRotationGestureRecognizer()
    private let singleTapGestureRecognizer = UITapGestureRecognizer()
    private let doubleTapGestureRecognizer = UITapGestureRecognizer()
    private let forceGestureRecognizer = ForceGestureRecognizer(forceThreshold: forceGestureRecognizerThreshold)



    private let buttonDoubleTapGestureRecognizer = UITapGestureRecognizer()

    private var panGestureAnchorPoint: CGPoint?
    private var pinchGestureAnchorScale: CGFloat?
    private var rotateGestureAnchorRotation: CGFloat?

}

fileprivate extension YandexGRController {

// MARK: - Private Methods

    private func setupBoxView() {
        
        view.addSubview(box)
        box.backgroundColor = type(of: self).boxPossibleColors[colorIndex]
        box.translatesAutoresizingMaskIntoConstraints = false

        widthConstraint = box.widthAnchor.constraint(equalToConstant: type(of: self).initialBoxDimSize)
        heightConstraint = box.heightAnchor.constraint(equalToConstant: type(of: self).initialBoxDimSize)

        centerXConstraint = box.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        centerYConstraint = box.centerYAnchor.constraint(equalTo: view.centerYAnchor)

        NSLayoutConstraint.activate([widthConstraint, heightConstraint, centerXConstraint, centerYConstraint])

        box.layer.cornerRadius = type(of: self).boxCornerRadius
        box.clipsToBounds = true

    }

    private func setupButtonView() {
        box.addSubview(button)
        button.backgroundColor = .orange
        button.translatesAutoresizingMaskIntoConstraints = false

        let buttonRaduis = type(of: self).boxCornerRadius - 1.0

        button.setTitle("TAP", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 6.0)
        button.addTarget(self, action: #selector(handleButtonTap(_:)), for: .touchUpInside)

        NSLayoutConstraint.activate([
            button.topAnchor.constraint(equalTo: box.topAnchor, constant: 1.0),
            button.rightAnchor.constraint(equalTo: box.rightAnchor, constant: -1.0),
            button.heightAnchor.constraint(equalToConstant: 2.0 * buttonRaduis),
            button.widthAnchor.constraint(equalToConstant: 2.0 * buttonRaduis)
        ])

        button.layer.cornerRadius = buttonRaduis
        button.clipsToBounds = true

        buttonDoubleTapGestureRecognizer.numberOfTapsRequired = 2
        buttonDoubleTapGestureRecognizer.addTarget(self, action: #selector(handleButtonDoubleTapGesture(_:)))
        button.addGestureRecognizer(buttonDoubleTapGestureRecognizer)
        buttonDoubleTapGestureRecognizer.cancelsTouchesInView = true
    }

    private func setupGestureRecognizers() {
        panGestureRecognizer.addTarget(self, action: #selector(handlePanGesture(_:)))
        panGestureRecognizer.minimumNumberOfTouches = 1 //1

        pinchGestureRecognizer.addTarget(self, action: #selector(handlePinchGesture(_:)))
        rotateGestureRecognizer.addTarget(self, action: #selector(handleRotationGesture(_:)))

        singleTapGestureRecognizer.addTarget(self, action: #selector(handleSingleTapGesture(_:)))
        doubleTapGestureRecognizer.addTarget(self, action: #selector(handleDoubleTapGesture(_:)))

        forceGestureRecognizer.addTarget(self, action: #selector(handleForceGesture(_:)))

        singleTapGestureRecognizer.numberOfTapsRequired = 1
        doubleTapGestureRecognizer.numberOfTapsRequired = 2

        box.addGestureRecognizer(panGestureRecognizer)
        box.addGestureRecognizer(pinchGestureRecognizer)
        box.addGestureRecognizer(rotateGestureRecognizer)
        box.addGestureRecognizer(singleTapGestureRecognizer)
        box.addGestureRecognizer(doubleTapGestureRecognizer)
        box.addGestureRecognizer(forceGestureRecognizer)


        [panGestureRecognizer,
         pinchGestureRecognizer,
         rotateGestureRecognizer,
         singleTapGestureRecognizer,
         doubleTapGestureRecognizer,
        forceGestureRecognizer].forEach {
            $0.delegate = self
        }
    }

    private func updateBoxTransform() {
        box.transform = CGAffineTransform.identity.scaledBy(x: scale, y: scale).rotated(by: rotation)
    }

    @objc func handlePanGesture(_ gestureRecognizer: UIPanGestureRecognizer) {
        guard panGestureRecognizer === gestureRecognizer else { assert(false); return }

        switch gestureRecognizer.state {
        case .began:
            assert(panGestureAnchorPoint == nil)
            panGestureAnchorPoint = gestureRecognizer.location(in: view) //2
        case .changed:
            guard let panGestureAnchorPoint = panGestureAnchorPoint else { assert(false); return }

            let gesturePoint = gestureRecognizer.location(in: view)

            //3
            centerXConstraint.constant += gesturePoint.x - panGestureAnchorPoint.x
            centerYConstraint.constant += gesturePoint.y - panGestureAnchorPoint.y
            self.panGestureAnchorPoint = gesturePoint

        case .cancelled, .ended:
            panGestureAnchorPoint = nil
        case .failed, .possible:
            assert(panGestureAnchorPoint == nil)
            break
        }
    }

    @objc func handlePinchGesture(_ gestureRecognizer: UIPinchGestureRecognizer) {

        guard pinchGestureRecognizer === gestureRecognizer else {  assert(false); return }

        switch gestureRecognizer.state {
        case .began:
            assert(pinchGestureAnchorScale == nil)
            pinchGestureAnchorScale = gestureRecognizer.scale
        case .changed:
            guard let pinchGestureAnchorScale = pinchGestureAnchorScale else { assert(false); return }

            let gestureScale = gestureRecognizer.scale
            scale += gestureScale - pinchGestureAnchorScale
            self.pinchGestureAnchorScale = gestureScale

        case .cancelled, .ended:
            self.pinchGestureAnchorScale = nil

        case .failed, .possible:
            assert(pinchGestureAnchorScale == nil)
            break
        }
    }

    @objc func handleRotationGesture(_ gestureRecognizer: UIRotationGestureRecognizer) {

        guard rotateGestureRecognizer === gestureRecognizer else { assert(false); return }

        switch gestureRecognizer.state {
        case .began:
            assert(rotateGestureAnchorRotation == nil)
            rotateGestureAnchorRotation = gestureRecognizer.rotation
        case .changed:
            guard let rotateGestureAnchorRotation = rotateGestureAnchorRotation else { assert(false); return }

            let gestureRotation = gestureRecognizer.rotation
            rotation += gestureRotation - rotateGestureAnchorRotation
            self.rotateGestureAnchorRotation = gestureRotation

        case .cancelled, .ended:
            self.rotateGestureAnchorRotation = nil

        case .failed, .possible:
            assert(rotateGestureAnchorRotation == nil)
            break
        }
    }

    @objc func handleDoubleTapGesture(_ gestureRecognizer: UIGestureRecognizer) {
        widthConstraint.constant = type(of: self).initialBoxDimSize
        heightConstraint.constant = type(of: self).initialBoxDimSize
        centerXConstraint.constant = 0.0
        centerYConstraint.constant = 0.0

        UIView.animate(withDuration: 0.3,
                       delay: 0.0,
                       options: [.curveEaseInOut],
                       animations: {
                        self.scale = 1.0
                        self.rotation = 0.0
                        self.view.layoutIfNeeded()
        },
                       completion: nil)

    }

    @objc func handleSingleTapGesture(_ gestureRecognizer: UIGestureRecognizer) {
        colorIndex = (colorIndex  + 1) % type(of: self).boxPossibleColors.count
        UIView.animate(withDuration: 0.3) {
            self.box.backgroundColor = type(of: self).boxPossibleColors[self.colorIndex]
        }

    }

    @objc func handleForceGesture(_ gestureRecognizer: ForceGestureRecognizer) {
        guard gestureRecognizer === forceGestureRecognizer else { assert(false); return }

        switch gestureRecognizer.state {
        case .began, .failed, .possible:
            break
        case .changed:
            let threshold = type(of: self).forceGestureRecognizerThreshold
            let force = max(threshold, gestureRecognizer.force) - threshold
            let forceFraction = min(force / 4.0, 1.0)

            view.backgroundColor = UIColor(displayP3Red: 1.0, green: 1.0 - forceFraction, blue: 1.0 - forceFraction, alpha: 1.0)
        case .ended, .cancelled:
            self.view.backgroundColor = .white
        }

    }

    @objc private func handleButtonTap(_ button: UIButton) {
        let targetCornerRadius = box.layer.cornerRadius > 0.0 ? 0.0 : type(of: self).boxCornerRadius

        UIView.animate(withDuration: 0.3) {
            self.box.layer.cornerRadius = targetCornerRadius
            self.button.layer.cornerRadius = targetCornerRadius - 1
        }
    }

    @objc private func handleButtonDoubleTapGesture(_ gestureRecognizer: UITapGestureRecognizer) {
        print("BDT")
    }

}

    // MARK: - UIGestureRecognizerDelegate

extension YandexGRController: UIGestureRecognizerDelegate {

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        let simultaneousRecognizers = [panGestureRecognizer, pinchGestureRecognizer, rotateGestureRecognizer, forceGestureRecognizer]
        return simultaneousRecognizers.contains(gestureRecognizer) && simultaneousRecognizers.contains(otherGestureRecognizer)
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                           shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return gestureRecognizer === singleTapGestureRecognizer && otherGestureRecognizer === doubleTapGestureRecognizer
    }

}

