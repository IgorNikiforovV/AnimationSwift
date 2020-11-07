//
//  MonkeyGRController.swift
//  DZ13_Animation_additional_tasks
//
//  Created by Игорь Никифоров on 24.10.2020.
//  Copyright © 2020 Игорь Никифоров. All rights reserved.
//

import UIKit
import AVFoundation

enum DayTime {
    case day, night
}

class MonkeyGRController: UIViewController {

    @IBOutlet var monkeyPan: UIPanGestureRecognizer!
    @IBOutlet var bananaPan: UIPanGestureRecognizer!
    @IBOutlet weak var monkeyImageView: UIImageView!
    @IBOutlet weak var bananaImageView: UIImageView!
    @IBOutlet weak var sunImageView: UIImageView!
    @IBOutlet weak var moonImageView: UIImageView!
    @IBOutlet weak var doorImageView: UIImageView!
    @IBOutlet weak var palmImageView: UIImageView!
    @IBOutlet weak var sunRightConstraint: NSLayoutConstraint!
    @IBOutlet weak var moonRightConstraint: NSLayoutConstraint!
    @IBOutlet weak var carImageView: UIImageView!

    // MARK: - private properties

    private var chompPlayer: AVAudioPlayer?
    private var laughPlayer: AVAudioPlayer?
    private var timeState: DayTime = .day
    private var starViewList = [StarView]()
    private let displayedMoonConstraintValue: CGFloat = 40
    private let displayedSunConstraintValue: CGFloat = 20

    // MARK: - public properties

    var seze: CGSize {
        view.frame.size
    }
    var width: CGFloat {
        view.frame.width
    }
    var height: CGFloat {
        view.frame.height
    }
    var center: CGPoint {
        view.center
    }
    var defaultMonkeySize: CGSize {
        CGSize(width: 168, height: 168)
    }
    var defaultBananaSize: CGSize {
        CGSize(width: 87, height: 95)
    }

    // MARK: - life cycle ViewController

    override func viewDidLoad() {
        super.viewDidLoad()

        let imageViews = view.subviews.filter{ $0 is UIImageView }
        for imageView in imageViews {

            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))

            tapGesture.delegate = self
            imageView.addGestureRecognizer(tapGesture)
            tapGesture.require(toFail: monkeyPan)
            tapGesture.require(toFail: bananaPan)

            let tickleGesture = TickleGestureRecognizer(target: self, action: #selector(handleTickle))
            tickleGesture.delegate = self
            imageView.addGestureRecognizer(tickleGesture)

            let shakingGesture = ShakingGestureRecognizer(target: self, action: #selector(handleShaking))
            shakingGesture.delegate = self
            imageView.addGestureRecognizer(shakingGesture)

            moonImageView.alpha = 0
            carImageView.alpha = 0
        }

        initialStars()

        chompPlayer = createPlayer(from: "chomp")
        laughPlayer = createPlayer(from: "laugh")
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        moonRightConstraint.constant = view.frame.width
        view.layoutIfNeeded()
    }

    @IBAction func handlePinch(_ gesture: UIPinchGestureRecognizer) {

        guard let gestureView = gesture.view else {
            return
        }

        gestureView.transform = gestureView.transform.scaledBy(
            x: gesture.scale,
            y: gesture.scale
        )
        gesture.scale = 1
    }

    @IBAction func handleRotate(_ gesture: UIRotationGestureRecognizer) {
        guard let gestureView = gesture.view else {
            return
        }

        gestureView.transform = gestureView.transform.rotated(by: gesture.rotation)
        gesture.rotation = 0

    }

    @IBAction func handlePan(_ gesture: UIPanGestureRecognizer) {

        let translation = gesture.translation(in: view)

        guard let gestureView = gesture.view else {
            return
        }

        gestureView.center = CGPoint(x: gestureView.center.x + translation.x,
                                     y: gestureView.center.y + translation.y)

        gesture.setTranslation(.zero, in: view)


        // MARK: - deceleration

        guard gesture.state == .ended else { return }

        let velocity = gesture.velocity(in: view)
        let magnitude = sqrt((velocity.x * velocity.x) + (velocity.y * velocity.y))
        let slideMultiplier = magnitude / 200

        let slideFactor = 0.1 * slideMultiplier

        var finalPoint = CGPoint(
            x: gestureView.center.x + (velocity.x * slideFactor),
            y: gestureView.center.y + (velocity.y * slideFactor)
        )

        finalPoint.x = min(max(finalPoint.x, 0), view.bounds.width)
        finalPoint.y = min(max(finalPoint.y, 0), view.bounds.height)

        UIView.animate(withDuration: Double(slideFactor * 2),
                       delay: 0,

                       options: .curveEaseOut,
                       animations: {
                        gestureView.center = finalPoint
        })
    }

    @objc func handleTap(_ gesture: UITapGestureRecognizer) {
        chompPlayer?.play()
    }

    @objc func handleTickle(_ gesture: TickleGestureRecognizer) {
        laughPlayer?.play()
    }

    @objc func handleShaking(_ gesture: ShakingGestureRecognizer) {
        setDayTimeState(new: .night)
    }

    // MARK: - private funcs

    private func createPlayer(from filename: String) -> AVAudioPlayer? {
        guard let url = Bundle.main.url(forResource: filename, withExtension: "caf")
            else { return nil }

        var player = AVAudioPlayer()
        do {
            try player = AVAudioPlayer.init(contentsOf: url)
            player.prepareToPlay()
        } catch {
            print("Error loading \(url.absoluteString): \(error)")
        }
        return player
    }

}

private extension MonkeyGRController {

    // изменяем состояние времени суток

    func setDayTimeState(new state: DayTime)  {

        setHidingAndAppearingMonkey(state)
        setbackgroundColor(state)
        setHidingAndAppearingSunAndMoon(state)
        HidingAndAppearingBanana(state)

        switch state {
        case .day: starViewList.forEach { $0.hide() }
        case .night: starViewList.forEach { $0.shine() }
        DispatchQueue.main.asyncAfter(deadline: .now() + 8) { [weak self] in
            self?.setDayTimeState(new: .day)
            }
        }
    }

    // настраиваем исчезновение/появление обезьянки

    func setHidingAndAppearingMonkey(_ state: DayTime) {

        switch state {
        case .day:

            let carWidth = carImageView.frame.width
            carImageView.center = CGPoint(x: 0 - (carWidth / 2), y: center.y)
            carImageView.alpha = 1
            monkeyImageView.frame.size = defaultMonkeySize
            monkeyImageView.center = center

            //машина должна появиться с остановкой
            let carStopProvider: UITimingCurveProvider = UICubicTimingParameters(controlPoint1: CGPoint(x: 0.0, y: 1.0),
                                                                                 controlPoint2: CGPoint(x: 1.0, y: 0.0))
            let animation = UIViewPropertyAnimator(duration: 3, timingParameters: carStopProvider)

            animation.addAnimations { [weak self] in guard let self = self else { return }
                // проедем чуть дальше середины, что бы слева осталось место для высадки обезьянки
                self.carImageView.center = CGPoint(x: self.width + (self.width / 2), y: self.center.y)
            }
            animation.addAnimations { [weak self] in
                //задержим появление обезьянки
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    self?.monkeyImageView.alpha = 1
                }
            }

            animation.startAnimation()

        case .night:

            let point = doorImageView.center
            //что бы обезьянака не пробегала дверь попробуем остановить другие анимации
            monkeyImageView.layer.removeAllAnimations()
            view.layer.removeAllAnimations()

            let animation = UIViewPropertyAnimator(duration: 2, curve: .easeInOut) { [weak self] in
                self?.doorImageView.alpha = 1
                self?.monkeyImageView.frame = CGRect(x: point.x, y: point.y, width: 1, height: 2)
            }
            animation.addCompletion {  [weak self] _ in
                UIView.animate(withDuration: 1) {
                    self?.doorImageView.alpha = 0
                    self?.monkeyImageView.alpha = 0
                }
            }
            animation.startAnimation()
        }

    }

    // настраиваем фон для дня/ночи

    func setbackgroundColor(_ state: DayTime) {
        var color: UIColor
        switch state {
        case .day: color = UIColor(named: "Colors/ColorDay") ?? UIColor.white
        case .night: color = UIColor(named: "Colors/ColorNight") ?? UIColor.black
        }

        UIView.animate(withDuration: 2) { [weak self] in
            self?.view.backgroundColor = color
        }
    }

    // наполняем экран звездами рандомно

    func initialStars() {
        let width = view.frame.width
        let height = view.frame.height - palmImageView.frame.height - view.safeAreaInsets.bottom

        starViewList = (1...110).map { _ in
            let star = StarView()
            let randomPosition = CGPoint(x:Int(arc4random()%UInt32(width)),y:Int(arc4random()%UInt32(height)))
            view.addSubview(star)
            star.center = randomPosition
            return star
        }
    }

    // настраиваем исчезновение/появление банана

    func HidingAndAppearingBanana(_ state: DayTime) {

        switch state {
        case .day:

            bananaImageView.center = CGPoint(x: center.x + defaultMonkeySize.width / 2 - 30,
                                             y: center.y - defaultMonkeySize.height / 2 + 20)

            DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in
                UIView.animate(withDuration: 1) { [weak self] in
                    guard let self = self else { return }
                    self.bananaImageView.alpha = 1
                    self.bananaImageView.frame.size = self.defaultBananaSize
                }
            }

        case .night:

            let size = bananaImageView.frame.size
            let animation = UIViewPropertyAnimator(duration: 2,
                                                   curve: .easeOut) { [weak self] in
                                                    self?.bananaImageView.transform = CGAffineTransform(rotationAngle: .pi)
                                                    self?.bananaImageView.transform = CGAffineTransform(rotationAngle: .pi * 2)
                                                    self?.bananaImageView.frame.size = CGSize (width: 1,
                                                                                               height: 1)

            }
            animation.addCompletion { [weak self] (_) in
                UIView.animate(withDuration: 2, animations: {
                    self?.bananaImageView.image = UIImage(named: "Monkey/blast")
                    self?.bananaImageView.frame.size = size
                }, completion: { (_) in
                    self?.bananaImageView.alpha = 0
                    self?.bananaImageView.image = UIImage(named: "Monkey/banana")
                })

            }
            animation.startAnimation()
        }

    }

    // настраиваем исчезновение/появление солнца и луны

    func setHidingAndAppearingSunAndMoon(_ state: DayTime) {

        let width = self.width
        var animation: () -> Void
        var completion: ((UIViewAnimatingPosition) -> Void)?

        switch state {
        case .day:
            sunRightConstraint.constant = displayedSunConstraintValue
            moonRightConstraint.constant = -(displayedMoonConstraintValue + moonImageView.frame.width)

            animation = { [weak self] in
                self?.sunImageView.alpha = 1
                self?.view.layoutIfNeeded()
            }
            completion = { [weak self] (_) in
                self?.moonImageView.alpha = 0
                self?.moonRightConstraint.constant = width
            }

        case .night:
            sunRightConstraint.constant = -(displayedSunConstraintValue + sunImageView.frame.width)
            moonRightConstraint.constant -= (view.frame.width - displayedMoonConstraintValue)
            animation = { [weak self] in
                self?.moonImageView.alpha = 1
                self?.view.layoutIfNeeded()
            }
            completion = { [weak self] (_) in
                self?.sunImageView.alpha = 0
                self?.sunRightConstraint.constant = width
                self?.view.layoutIfNeeded()
            }
        }

        let animator = UIViewPropertyAnimator(duration: 4, curve: .easeIn, animations: animation)
        if let completion = completion {
            animator.addCompletion(completion)
        }
        animator.startAnimation()

    }

}

    // MARK: - UIGestureRecognizerDelegate

extension MonkeyGRController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
