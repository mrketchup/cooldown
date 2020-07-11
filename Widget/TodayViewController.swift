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
import Combine
import Core_iOS

final class TodayViewController: UIViewController {
    @IBOutlet private var cooldownLabel: UILabel!
    @IBOutlet private var plusButton: UIButton!
    private var displayLink: CADisplayLink?
    private let viewModel = TodayViewController.container.cooldownViewModel()
    private var cancellables: Set<AnyCancellable> = []
    
    deinit {
        displayLink?.invalidate()
        cancellables.forEach { $0.cancel() }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        cooldownLabel.font = .monospacedDigitSystemFont(ofSize: 80, weight: .light)
        displayLink = CADisplayLink(target: self, selector: #selector(refresh))
        displayLink?.preferredFramesPerSecond = 4
        displayLink?.add(to: RunLoop.main, forMode: .common)
        
        let colorAndStyle = viewModel.$primaryColor
            .map { [unowned self] in ($0, self.traitCollection.userInterfaceStyle) }
        colorAndStyle
            .map { UIColor.backgroundColor(from: $0, for: $1, withPreferredDarkBackground: .clear) }
            .assign(to: \.backgroundColor, on: view)
            .store(in: &cancellables)
        
        let textColor = colorAndStyle
            .map { UIColor.textColor(from: $0, for: $1) }
        textColor
            .assign(to: \.textColor, on: cooldownLabel)
            .store(in: &cancellables)
        textColor
            .assign(to: \.tintColor, on: plusButton)
            .store(in: &cancellables)
        
        viewModel.$timeRemaining
            .map(Optional.init)
            .assign(to: \.text, on: cooldownLabel)
            .store(in: &cancellables)
        
        viewModel.redZoneWarning
            .sink { UINotificationFeedbackGenerator().notificationOccurred(.warning) }
            .store(in: &cancellables)
    }
    
    @IBAction private func addButtonPressed(_ sender: UIButton) {
        viewModel.incrementCooldown()
    }
    
    @objc private func refresh() {
        viewModel.refresh()
    }
}

extension TodayViewController: NCWidgetProviding {
    static let container = Container()
    
    func widgetPerformUpdate(completionHandler: @escaping (NCUpdateResult) -> Void) {
        completionHandler(.newData)
    }
}
