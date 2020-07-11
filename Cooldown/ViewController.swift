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
import Combine
import Core_iOS

final class ViewController: UIViewController {
    @IBOutlet private var cooldownLabel: UILabel!
    @IBOutlet private var plusButton: UIButton!
    private var displayLink: CADisplayLink?
    private let viewModel = Container.cooldownViewModel()
    private var cancellables: Set<AnyCancellable> = []
    
    override var preferredStatusBarStyle: UIStatusBarStyle { return .lightContent }
    
    deinit {
        displayLink?.invalidate()
        cancellables.forEach { $0.cancel() }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        cooldownLabel.font = .monospacedDigitSystemFont(ofSize: 120, weight: .light)
        displayLink = CADisplayLink(target: self, selector: #selector(refresh))
        displayLink?.preferredFramesPerSecond = 4
        displayLink?.add(to: RunLoop.main, forMode: .common)
        
        let colorAndStyle = viewModel.$primaryColor
            .map { [unowned self] in ($0, self.traitCollection.userInterfaceStyle) }
        colorAndStyle
            .map { UIColor.backgroundColor(from: $0, for: $1) }
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
        
        viewModel.presentSettings
            .sink { [unowned self] in self.performSegue(withIdentifier: "settings", sender: nil) }
            .store(in: &cancellables)
        
        viewModel.redZoneWarning
            .sink { UINotificationFeedbackGenerator().notificationOccurred(.warning) }
            .store(in: &cancellables)
    }
    
    @IBAction private func addButtonPressed(_ sender: UIButton) {
        viewModel.incrementCooldown()
    }
    
    @IBAction private func swipeDown(_ sender: UISwipeGestureRecognizer) {
        viewModel.decrementCooldown()
    }
    
    @IBAction private func longPress(_ sender: UILongPressGestureRecognizer) {
        guard case .began = sender.state else { return }
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        
        let sheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        for option in viewModel.intervalOptions {
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
    
    @objc private func refresh() {
        viewModel.refresh()
    }
}
