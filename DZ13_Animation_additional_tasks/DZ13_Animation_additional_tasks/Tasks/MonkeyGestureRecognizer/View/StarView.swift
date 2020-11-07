//
//  StarView.swift
//  DZ13_Animation_additional_tasks
//
//  Created by Игорь Никифоров on 05.11.2020.
//  Copyright © 2020 Игорь Никифоров. All rights reserved.
//

import UIKit

class StarView: UIView {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet var contentView: UIView!

    private var isVisible: Bool = false
    private var timer = Timer()


    override init(frame: CGRect) {
        super.init(frame: frame)
        initial()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initial()
    }

    private func initial() {
        Bundle.main.loadNibNamed("StarView", owner: self, options: nil)
        addSubview(contentView)
        contentView.isHidden = true
    }
    //сиять
    func shine() {

        // формируем разброс в рамках двух секунд, что бы звезды начинали сиять в разное время
        let extraInterval = (Double.random(in: (1...2000))/1000)

        DispatchQueue.main.asyncAfter(deadline: .now() + extraInterval) { [weak self] in
            self?.contentView.isHidden = false
            self?.timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] (_) in
                guard let self = self else { return }
                UIView.animate(withDuration: 1) {
                    self.contentView.alpha = self.isVisible ? 0 : 1
                }
                self.isVisible.toggle()
            }
        }

    }
    //скрыться
    func hide() {
        timer.invalidate()
        UIView.animate(withDuration: 2) { [weak self] in
            self?.contentView.alpha = 0
        }
    }

}
