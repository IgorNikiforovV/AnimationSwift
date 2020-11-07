//
//  LongTapView.swift
//  DZ13_Animation_additional_tasks
//
//  Created by Игорь Никифоров on 17.10.2020.
//  Copyright © 2020 Игорь Никифоров. All rights reserved.
//

import UIKit


class LongTapView: UIView {
    var onLongtap: ((UITouch) -> Void)?
    private var originLocations: [UITouch: CGPoint] = [:]
    private var delayedTouchesHandlers: [UITouch: DispatchWorkItem] = [:]

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)

        //(1)
        touches.forEach { touch in
            originLocations[touch] = touch.location(in: self)

            let workItem = DispatchWorkItem { [weak self] in
                self?.onLongtap?(touch)
            }
            delayedTouchesHandlers[touch] = workItem
            DispatchQueue.main.asyncAfter(deadline: .now() + 3, execute: workItem)
        }
    }
    //(2)
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)

        touches
            .filter { touch in
                guard let originLocation = originLocations[touch] else { return false }
                let currentLocation = touch.location(in: self)
                return hypotf(Float(originLocation.x - currentLocation.x), Float(originLocation.y - currentLocation.y)) > 0.5
        }
        .forEach{
            ignoreTouch($0)
        }
    }

    //(3)
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        touches.forEach{ ignoreTouch($0) }
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        touches.forEach{ ignoreTouch($0) }
    }

    func ignoreTouch(_ touch: UITouch) {
        originLocations[touch] = nil
        delayedTouchesHandlers[touch]?.cancel()
        delayedTouchesHandlers[touch] = nil
    }

}
