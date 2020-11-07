//
//  TickleGestureRecognizer.swift
//  DZ13_Animation_additional_tasks
//
//  Created by Игорь Никифоров on 01.11.2020.
//  Copyright © 2020 Игорь Никифоров. All rights reserved.
//

import UIKit

class TickleGestureRecognizer: UIGestureRecognizer {

    enum TickleDirection {
        case unknown
        case left
        case right
    }

    private let requiredTickles = 2
    private let distanceForTickleGesture: CGFloat = 25

    private var tickleCount = 0
    private var tickleStartLocation: CGPoint = .zero
    private var latestDirection: TickleDirection = .unknown

    override func reset() {
        tickleCount = 0
        latestDirection = .unknown
        tickleStartLocation = .zero

        if state == .possible {
            state = .failed
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        guard let touche = touches.first else {
            return
        }
        tickleStartLocation = touche.location(in: view)
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) {
        guard let touche = touches.first else {
            return
        }
        let tickleLocation = touche.location(in: view)
        let horizontalDifference = tickleLocation.x - tickleStartLocation.x

        if abs(horizontalDifference) < distanceForTickleGesture {
            return
        }

        let direction: TickleDirection

        if horizontalDifference < 0 {
            direction = .left
        } else {
            direction = .right
        }

        if latestDirection == .unknown ||
            latestDirection == .left && direction == .right ||
            latestDirection == .right && direction == .left {
            tickleStartLocation = tickleLocation
            latestDirection = direction
            tickleCount += 1

            if state == .possible && tickleCount > requiredTickles {
                state = .ended
            }
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent) {
        reset()
    }
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent) {
         reset()
    }

}
