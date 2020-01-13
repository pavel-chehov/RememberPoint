//
//  CreateTaskPresenter.swift
//  RememberPoint
//
//  Created by Pavel Chehov on 03/01/2019.
//  Copyright © 2019 Pavel Chehov. All rights reserved.
//

import Firebase
import Foundation
import RxCocoa
import RxSwift

protocol CreateTaskPresenterProtocol {
    var router: CreateTaskRouterProtocol! { get }
    var interactor: CreateTaskInteractorProtocol! { get }
    var view: CreateTaskViewProtocol! { get }
    init(for viewController: CreateTaskViewProtocol, with router: CreateTaskRouterProtocol)
    func close()
    func save()
    func setStart(date: Date)
    func setEnd(date: Date)
    func setEnabled(_: Bool)
    func setTitle(_: String?)
    func setNotes(text: String?)
    func configure(with interactor: CreateTaskInteractorProtocol, data: Task)
    func configure(with interactor: CreateTaskInteractorProtocol, data: GeocodingResult)
}

class CreateTaskPresenter: CreateTaskPresenterProtocol {
    private(set) var router: CreateTaskRouterProtocol!
    private(set) var interactor: CreateTaskInteractorProtocol!
    private(set) weak var view: CreateTaskViewProtocol!
    private var geoData: GeocodingResult?
    private var hasUnsavedChanges: Bool = false

    required init(for viewController: CreateTaskViewProtocol, with router: CreateTaskRouterProtocol) {
        view = viewController
        self.router = router
    }

    func configure(with interactor: CreateTaskInteractorProtocol, data: GeocodingResult) {
        self.interactor = interactor
        interactor.location = GeoPoint(latitude: (data.point?.latitude)!, longitude: (data.point?.longitude)!)
        interactor.address = data.fullStreetAddress
        populateFields(from: interactor)
    }

    func configure(with interactor: CreateTaskInteractorProtocol, data: Task) {
        self.interactor = interactor
        self.interactor.configure(with: data)
        populateFields(from: interactor)
    }

    private func populateFields(from interactor: CreateTaskInteractorProtocol) {
        view.drawAddress(address: interactor.address)
        view.drawStart(date: toString(from: interactor.startDate))
        view.setEndPickerDate(date: interactor.endDate)
        view.setStartPickerDate(date: interactor.startDate)
        view.drawTitle(interactor.title)
        view.drawEnd(date: toString(from: interactor.endDate))
        view.drawEnabled(interactor.isDone ? false : interactor.isEnabled)
        view.drawSwitchTitle(title: interactor.createdFromDoneTask ? "Reactivate reminder" : "Enable reminder")
        view.drawNotes(text: interactor.notes)
        view.drawPin(for: interactor.location)
    }

    func close() {
        guard hasUnsavedChanges else {
            router.close()
            return
        }
        let saveAction = UIAlertAction(title: "Save", style: .default) { [unowned self] _ in self.save() }
        let discardAction = UIAlertAction(title: "Discard changes", style: .destructive) { [unowned self] _ in self.router.close() }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        view.showActionSheet(title: nil, text: nil, actions: [saveAction, discardAction, cancelAction])
    }

    func save() {
        do {
            try interactor.save()
            Analytics.logEvent(Events.save.rawValue, parameters: nil)
            router.close()
        } catch let SaveError.dateError(message) {
            view.showAlert(title: "Can't save", message: message, okText: "OK")
        } catch {
            Log.instance.write("\(#file) \(#function) error.localizedDescription")
        }
    }

    func setStart(date: Date) {
        guard interactor.startDate != date else { return }
        hasUnsavedChanges = true

        interactor.startDate = date
        view.setEndPickerMinimum(date: date)
        let dateString = toString(from: date)
        view.drawStart(date: dateString)
    }

    func setEnd(date: Date) {
        guard interactor.endDate != date else { return }
        hasUnsavedChanges = true

        interactor.endDate = date
        let dateString = toString(from: date)
        view.drawEnd(date: dateString)
    }

    func setEnabled(_ enabled: Bool) {
        guard interactor.isEnabled != enabled else { return }
        hasUnsavedChanges = true

        if interactor.createdFromDoneTask {
            interactor.isDone = !enabled
        }
        interactor.isEnabled = enabled
    }

    func setTitle(_ title: String?) {
        guard interactor.title != title else { return }
        hasUnsavedChanges = true

        if let title = title, !title.isEmpty {
            interactor.title = title
            view.saveButtonEnabled(true)
        } else {
            view.saveButtonEnabled(false)
        }
    }

    func setNotes(text: String?) {
        guard interactor.notes != text else { return }
        hasUnsavedChanges = true

        interactor.notes = text
    }

    private func toString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        let dayName = formatter.string(from: date)
        formatter.dateFormat = "dd"
        let dayNumber = formatter.string(from: date)
        formatter.dateFormat = "MMMM"
        var monthName = formatter.string(from: date)
        monthName = String(monthName[...monthName.index(monthName.startIndex, offsetBy: 2)])
        formatter.dateFormat = "HH:mm"
        let time = formatter.string(from: date)
        let dateString = "\(dayName), \(dayNumber)th of \(monthName), \(time)"
        return dateString
    }
}
