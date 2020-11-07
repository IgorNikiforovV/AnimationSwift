//
//  Gestures.swift
//  DZ13_Animation_additional_tasks
//
//  Created by Игорь Никифоров on 17.10.2020.
//  Copyright © 2020 Игорь Никифоров. All rights reserved.
//
import UIKit.UIView

enum Gestures: String, CaseIterable {
    case longTapView

    func gestureView() -> UIView {
        switch self {
        case .longTapView: return LongTapView()
        }
    }
}
