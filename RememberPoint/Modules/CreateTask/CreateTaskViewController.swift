//
//  ViewController.swift
//  RememberPoint
//
//  Created by Pavel Chehov on 03/01/2019.
//  Copyright © 2019 Pavel Chehov. All rights reserved.
//

import GoogleMaps
import RxCocoa
import RxSwift
import UIKit

protocol CreateTaskViewProtocol: AnyObject, AlertProtocol {
    var presenter: CreateTaskPresenterProtocol! { get set }
    var configurator: CreateTaskConfiguratorProtocol! { get set }
    func drawStart(date: String?)
    func drawEnd(date: String?)
    func saveButtonEnabled(_ value: Bool)
    func drawAddress(address: String?)
    func setStartPickerDate(date: Date)
    func setEndPickerDate(date: Date)
    func drawTitle(_: String?)
    func drawEnabled(_: Bool)
    func disableEnabled()
    func setEndPickerMinimum(date: Date)
    func drawSwitchTitle(title: String)
    func drawNotes(text: String?)
    func drawPin(for: GeoPoint?)
}

class CreateTaskViewController: UITableViewController, CreateTaskViewProtocol {
    var presenter: CreateTaskPresenterProtocol!
    var configurator: CreateTaskConfiguratorProtocol!
    private let expandedHeight: CGFloat = 270
    private let regularHeight: CGFloat = 44
    private let lastCellHeight: CGFloat = 300
    private var selectedIndexPath: IndexPath!

    @IBOutlet var addressLabel: UILabel!
    @IBOutlet var startDateLabel: UILabel!
    @IBOutlet var startPicker: UIDatePicker!
    @IBOutlet var endDateLabel: UILabel!
    @IBOutlet var endPicker: UIDatePicker!
    @IBOutlet var titleTextField: UITextField!
    @IBOutlet var saveButton: UIBarButtonItem!
    @IBOutlet var dateOptionsLabel: UILabel!
    @IBOutlet var alarmOptionsLabel: UILabel!
    @IBOutlet var enableSwitch: UISwitch!
    @IBOutlet var reminderAlarmLabel: UILabel!
    @IBOutlet var notesTextView: UITextView!
    @IBOutlet var notesLabel: UILabel!
    @IBOutlet var mapView: GMSMapView!
    let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupMap()
        configurator.configure(with: self)
        let textAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        navigationController?.navigationBar.titleTextAttributes = textAttributes
        dateOptionsLabel.text = "Date options"
        alarmOptionsLabel.text = "Alarm options"
        notesLabel.text = "Notes"
        endDateLabel.textColor = UIColor.primaryColor
        startDateLabel.textColor = UIColor.primaryColor
        setupBinding()
    }

    override func viewDidAppear(_ animated: Bool) {
        titleTextField.becomeFirstResponder()
    }

    override func viewWillDisappear(_ animated: Bool) {
        closeKeyboard()
    }

    func setupBinding() {
        startPicker.rx.date.bind { [unowned self] value in
            self.presenter.setStart(date: value)
        }.disposed(by: disposeBag)
        endPicker.rx.date.bind { [unowned self] value in
            self.presenter.setEnd(date: value)
        }.disposed(by: disposeBag)
        enableSwitch.rx.value.bind { [unowned self] value in
            self.presenter.setEnabled(value)
        }.disposed(by: disposeBag)
        titleTextField.rx.text.bind { [unowned self] value in
            self.presenter.setTitle(value)
        }.disposed(by: disposeBag)
        notesTextView.rx.value.bind { [unowned self] value in
            self.presenter.setNotes(text: value)
        }.disposed(by: disposeBag)
    }

    @IBAction func closeClicked(_ sender: Any) {
        presenter.close()
    }

    @IBAction func saveClicked(_ sender: Any) {
        presenter.save()
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        closeKeyboard()
        guard let cell = tableView.cellForRow(at: indexPath) as? ExpandableTableViewCell else { return }
        let otherCell = tableView.visibleCells.compactMap { $0 as? ExpandableTableViewCell }.first { $0 != cell }
        otherCell?.shouldExpanded = false

        cell.shouldExpanded = !cell.shouldExpanded
        tableView.beginUpdates()
        tableView.endUpdates()
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }

    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.row {
        case 2:
            return 300
        case let lastCell where lastCell == tableView.numberOfRows(inSection: 0) - 1:
            return lastCellHeight
        default:
            if let cell = tableView.cellForRow(at: indexPath) as? ExpandableTableViewCell {
                if cell.shouldExpanded {
                    return expandedHeight
                }
            }
        }
        return regularHeight
    }

    func setupMap() {
        mapView.delegate = self
        mapView.isMyLocationEnabled = false
        mapView.settings.myLocationButton = false
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        setupNeededMapStyle()
    }
    
    func setupNeededMapStyle() {
        if #available(iOS 13, *) {
            let userInterfaceStyle = self.traitCollection.userInterfaceStyle
            setupMapStyle(userInterfaceStyle == .dark ? .dark : .light)
        }
    }
    
    func setupMapStyle(_ style: MapStyle) {
        do {
            if style == .dark {
                if let url = Bundle.main.url(forResource: "GMSMapDarkStyle", withExtension: "json") {
                    mapView.mapStyle = try GMSMapStyle(contentsOfFileURL: url)
                }
            } else {
                mapView.mapStyle = nil
            }
        } catch {
            debugPrint("One or more of the map styles failed to load. \(error)")
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        setupNeededMapStyle()
    }

    func drawPin(for point: GeoPoint?) {
        guard let location = point else { return }
        let marker = GMSMarker()
        let image = UIImage(named: "pin")
        marker.icon = image
        marker.position = CLLocationCoordinate2D(from: location)
        marker.map = mapView
        mapView.camera = GMSCameraPosition.camera(withTarget: CLLocationCoordinate2D(from: location), zoom: 17)
    }

    func drawSwitchTitle(title: String) {
        reminderAlarmLabel.text = title
    }

    func drawEnabled(_ enabled: Bool) {
        enableSwitch.isOn = enabled
    }

    func disableEnabled() {
        enableSwitch.isOn = false
        enableSwitch.isEnabled = false
    }

    func drawTitle(_ title: String?) {
        titleTextField.text = title
    }

    func drawNotes(text: String?) {
        notesTextView.text = text
    }

    func drawStart(date: String?) {
        startDateLabel.text = date
    }

    func drawEnd(date: String?) {
        endDateLabel.text = date
    }

    func saveButtonEnabled(_ value: Bool) {
        saveButton.isEnabled = value
    }

    func drawAddress(address: String?) {
        addressLabel.text = address
    }

    func setStartPickerDate(date: Date) {
        startPicker.date = date
    }

    func setEndPickerDate(date: Date) {
        endPicker.date = date
    }

    func setEndPickerMinimum(date: Date) {
        endPicker.minimumDate = date
    }
}

extension CreateTaskViewController: GMSMapViewDelegate {
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        closeKeyboard()
    }

    func mapView(_ mapView: GMSMapView, willMove gesture: Bool) {
        closeKeyboard()
    }

    func closeKeyboard() {
        view.endEditing(true)
    }
}
