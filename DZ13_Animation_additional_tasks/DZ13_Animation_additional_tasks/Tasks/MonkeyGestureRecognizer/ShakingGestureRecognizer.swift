//
//  EscapingGestureRecognizer.swift
//  DZ13_Animation_additional_tasks
//
//  Created by Игорь Никифоров on 04.11.2020.
//  Copyright © 2020 Игорь Никифоров. All rights reserved.
//

import UIKit

class ShakingGestureRecognizer: UIGestureRecognizer {

    private var shakeStartLocarion: CGPoint = .zero
    private var coveredDistanceToOneDirection: CGFloat = .zero
    private var shakeCounter: CGFloat = 0
    private let distanceForShakGesture: CGFloat = 30
    private let shakeLimit: CGFloat = 6

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        guard let touche = touches.first else { return }

        shakeStartLocarion = touche.location(in: view)
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) {
        guard let touche = touches.first else { return }

        let point = touche.location(in: view?.superview)
        let direction = shakeStartLocarion.y - point.y
        let isDirectionChanged = abs(coveredDistanceToOneDirection) < abs(direction + coveredDistanceToOneDirection)

        if isDirectionChanged {
            if coveredDistanceToOneDirection >= distanceForShakGesture {
                shakeCounter += 1
            }
            shakeStartLocarion = point
            coveredDistanceToOneDirection = direction
        } else {
            coveredDistanceToOneDirection += direction
        }

        let pendingShakeCounter: CGFloat = coveredDistanceToOneDirection >= distanceForShakGesture ? 1 : 0

        if state == .possible && shakeCounter + pendingShakeCounter >= shakeLimit {
            state = .ended
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent) {
        reset()
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent) {
        reset()
    }

    override func reset() {
        shakeStartLocarion = .zero
        coveredDistanceToOneDirection = .zero
        shakeCounter = 0

        if state == .possible {
            state = .failed
        }
    }
    
}
