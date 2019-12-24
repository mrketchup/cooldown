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
import NotificationCenter
import Core_iOS

final class TodayViewController: UIViewController {
    
    @IBOutlet private var cooldownLabel: UILabel!
    @IBOutlet private var plusButton: UIButton!
    private var displayLink: CADisplayLink?
    private let presenter = Container.cooldownPresenter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.view = self
        cooldownLabel.font = .monospacedDigitSystemFont(ofSize: 80, weight: .light)
        displayLink = CADisplayLink(target: self, selector: #selector(refresh))
        displayLink?.preferredFramesPerSecond = 4
        displayLink?.add(to: RunLoop.main, forMode: .common)
    }
    
    @IBAction private func addButtonPressed(_ sender: UIButton) {
        presenter.incrementCooldown()
    }
    
    @objc private func refresh() {
        presenter.refresh()
    }
    
}

extension TodayViewController: CooldownView {
    
    func render(timeRemaining: String, backgroundColor: UIColor) {
        cooldownLabel.text = timeRemaining
        view.backgroundColor = backgroundColor
    }
    
    func presentIntervalOptions(_ options: [IntervalOption]) {
        // Currently NOOP
    }
    
    func presentSettings() {
        // Currently NOOP
    }
    
    func issueRedZoneWarning() {
        UINotificationFeedbackGenerator().notificationOccurred(.warning)
    }
    
}

extension TodayViewController: NCWidgetProviding {
    
    func widgetPerformUpdate(completionHandler: @escaping (NCUpdateResult) -> Void) {
        Container.initialize()
        completionHandler(.newData)
    }
    
}
