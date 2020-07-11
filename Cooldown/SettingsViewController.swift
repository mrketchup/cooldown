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

final class SettingsViewController: UIViewController {
    @IBOutlet private var shadowView: UIView!
    @IBOutlet private var cooldownDatePicker: UIDatePicker!
    private let viewModel = Container.settingsViewModel()
    private var cancellables: Set<AnyCancellable> = []
    
    deinit {
        cancellables.forEach { $0.cancel() }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        shadowView.layer.shadowOffset = CGSize(width: 0, height: -2)
        shadowView.layer.shadowColor = UIColor.black.cgColor
        shadowView.layer.shadowOpacity = 0.15
        shadowView.layer.shadowRadius = 2
        
        viewModel.$cooldownInterval
            .assign(to: \.countDownDuration, on: cooldownDatePicker)
            .store(in: &cancellables)
        
        // Workaround for a UIDatePicker bug not firing the first value change event
        DispatchQueue.main.async {
            self.cooldownDatePicker.countDownDuration = self.viewModel.cooldownInterval
        }
    }
    
    @IBAction private func cooldownDatePickerValueChanged(_ sender: UIDatePicker) {
        viewModel.update(interval: sender.countDownDuration)
    }
    
    @IBAction private func dismiss() {
        presentingViewController?.dismiss(animated: true, completion: nil)
    }
}
