//
//  SettingsViewController.swift
//  RememberPoint
//
//  Created by Pavel Chehov on 03/01/2019.
//  Copyright © 2019 Pavel Chehov. All rights reserved.
//

import RxCocoa
import RxSwift
import UIKit

protocol SettingsViewProtocol: AnyObject {
    var presenter: SettingsPresenterProtocol! { get set }
    var configurator: SettingsConfiguratorProtocol! { get set }
    func drawCurrentRadius(radius: String)
    func locationAlarm(hide: Bool)
    func notificationAlarm(hide: Bool)
}

class SettingsViewController: UIViewController, SettingsViewProtocol {
    let regularHeight: CGFloat = 45
    let expandedHeight: CGFloat = 260
    var presenter: SettingsPresenterProtocol!
    var configurator: SettingsConfiguratorProtocol! = SettingsConfigurator()
    let disposeBag = DisposeBag()

    @IBOutlet var tableView: UITableView!
    @IBOutlet var tableHeight: NSLayoutConstraint!
    @IBOutlet var locationAlarmLabel: UILabel!
    @IBOutlet var notificationAlarmLabel: UILabel!
    @IBOutlet var recognizerOverlayView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
        configurator.configure(with: self)
        tableView.register(UINib(nibName: "RadiusTableViewCell", bundle: nil), forCellReuseIdentifier: RadiusTableViewCell.identifier)
        tableView.register(UINib(nibName: "ReminderTableViewCell", bundle: nil), forCellReuseIdentifier: ReminderTableViewCell.identifier)
        tableView.dataSource = self
        tableView.delegate = self
        view.backgroundColor = UIColor.secondaryColor

        let tapGesture = UITapGestureRecognizer()
        tapGesture.rx.event.bind { [unowned self] _ in
            if let cell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? ExpandableTableViewCell {
                if cell.shouldExpanded {
                    cell.shouldExpanded = false
                    self.expandTable(cell.shouldExpanded)
                }
            }
        }.disposed(by: disposeBag)
        recognizerOverlayView.addGestureRecognizer(tapGesture)

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(willEnterForeground),
            name: UIApplication.willEnterForegroundNotification,
            object: nil
        )
    }

    override func viewWillAppear(_ animated: Bool) {
        presenter.checkAndAskPermissions()
    }

    func drawCurrentRadius(radius: String) {
        if let radiusCell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? RadiusTableViewCell {
            radiusCell.radiusLabel.text = radius
        }
    }

    func locationAlarm(hide: Bool) {
        DispatchQueue.main.async { [unowned self] in
            self.locationAlarmLabel.isHidden = hide
        }
    }

    func notificationAlarm(hide: Bool) {
        DispatchQueue.main.async { [unowned self] in
            self.notificationAlarmLabel.isHidden = hide
        }
    }

    @objc func willEnterForeground(_ notification: Notification) {
        presenter.checkAndAskPermissions()
    }
}

extension SettingsViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? ExpandableTableViewCell {
            cell.shouldExpanded = !cell.shouldExpanded
            expandTable(cell.shouldExpanded)
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var height = regularHeight
        if let cell = tableView.cellForRow(at: indexPath) as? RadiusTableViewCell {
            UIView.animate(withDuration: 0.3) {
                let transform = cell.shouldExpanded ? CGAffineTransform(rotationAngle: 1.5) : CGAffineTransform(rotationAngle: 0)
                cell.disclosureView.transform = transform
            }
            if cell.shouldExpanded {
                height = expandedHeight
            }
        }
        return height
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: RadiusTableViewCell.identifier, for: indexPath) as! RadiusTableViewCell
            cell.setup(with: presenter.radiusValues, radius: presenter.currentRadius)
            cell.pickerView.rx.itemSelected.bind { [unowned self] event in
                self.presenter.setRadius(by: event.row)
            }.disposed(by: disposeBag)
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: ReminderTableViewCell.identifier, for: indexPath) as! ReminderTableViewCell
            cell.setup(with: !presenter.remindersEnabled)
            cell.disableSwitch.rx.value.bind { [unowned self] value in
                self.presenter.setReminders(enabled: value)
            }.disposed(by: disposeBag)
            return cell
        }
    }

    private func expandTable(_ shouldExpand: Bool) {
        UIView.animate(withDuration: 0.3) {
            self.tableHeight.constant = shouldExpand ? self.regularHeight + self.expandedHeight : 2 * self.regularHeight
            self.view.layoutSubviews()
        }
        tableView.beginUpdates()
        tableView.endUpdates()
    }
}
