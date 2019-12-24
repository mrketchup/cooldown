//
// Copyright © 2018 Matt Jones. All rights reserved.
//
// This file is part of Cooldown.
//
// Cooldown is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// Cooldown is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with Cooldown.  If not, see <http://www.gnu.org/licenses/>.
//

import UIKit
import Core_iOS

final class ViewController: UIViewController {
    
    @IBOutlet private var cooldownLabel: UILabel!
    @IBOutlet private var plusButton: UIButton!
    private var displayLink: CADisplayLink?
    let presenter = Container.cooldownPresenter()
    
    override var preferredStatusBarStyle: UIStatusBarStyle { return .lightContent }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.view = self
        cooldownLabel.font = .monospacedDigitSystemFont(ofSize: 120, weight: .light)
        displayLink = CADisplayLink(target: self, selector: #selector(refresh))
        displayLink?.preferredFramesPerSecond = 4
        displayLink?.add(to: RunLoop.main, forMode: .common)
    }
    
    @IBAction private func addButtonPressed(_ sender: UIButton) {
        presenter.incrementCooldown()
    }
    
    @IBAction private func swipeDown(_ sender: UISwipeGestureRecognizer) {
        presenter.decrementCooldown()
    }
    
    @IBAction private func longPress(_ sender: UILongPressGestureRecognizer) {
        if case .began = sender.state {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            presenter.loadIntervalOptions()
        }
    }
    
    @objc private func refresh() {
        presenter.refresh()
    }
    
}

extension ViewController: CooldownView {
    
    func render(timeRemaining: String, backgroundColor: UIColor) {
        cooldownLabel.text = timeRemaining
        view.backgroundColor = backgroundColor
    }
    
    func presentIntervalOptions(_ options: [IntervalOption]) {
        let sheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        for option in options {
            let handler: (UIAlertAction) -> Void = { _ in
                option.action()
            }
            sheet.addAction(UIAlertAction(title: option.title, style: .default, handler: handler))
        }
        
        sheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        sheet.popoverPresentationController?.sourceView = plusButton
        sheet.popoverPresentationController?.sourceRect = plusButton.bounds.insetBy(dx: 0, dy: 20)
        present(sheet, animated: true)
    }
    
    func presentSettings() {
        performSegue(withIdentifier: "settings", sender: nil)
    }
    
    func issueRedZoneWarning() {
        UINotificationFeedbackGenerator().notificationOccurred(.warning)
    }
    
}
