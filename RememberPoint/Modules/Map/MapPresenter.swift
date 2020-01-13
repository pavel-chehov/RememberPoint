//
//  MapPresenter.swift
//  RememberPoint
//
//  Created by Pavel Chehov on 03/01/2019.
//  Copyright © 2019 Pavel Chehov. All rights reserved.
//

import CoreLocation
import Firebase
import Foundation
import RxCocoa
import RxSwift

protocol MapPresenterProtocol {
    var router: MapRouterProtocol! { get }
    var interactor: MapInteractorProtocol! { get }
    var view: MapViewProtocol! { get }
    init(for viewController: MapViewProtocol, with router: MapRouterProtocol)
    func configure(with: MapInteractorProtocol)
    func longPress(by coordinate: CLLocationCoordinate2D)
    func refreshTasks()
    func refreshCurrentLocation()
    func startUpdateLocation()
    func stopUpdateLocation()
    func closeSuggestion()
}

class MapPresenter: MapPresenterProtocol {
    private(set) var router: MapRouterProtocol!
    private(set) var interactor: MapInteractorProtocol!
    private(set) weak var view: MapViewProtocol!
    private var addressRelay: PublishRelay<GeocodingResult>!
    private let disposeBag = DisposeBag()

    required init(for viewController: MapViewProtocol, with router: MapRouterProtocol) {
        view = viewController
        self.router = router
    }

    func configure(with interactor: MapInteractorProtocol) {
        self.interactor = interactor
        if !interactor.longTapSuggestShown {
            view.drawLongTapSuggestion()
        } else {
            view.hideLongTapSuggestion()
        }
    }

    func longPress(by coordinate: CLLocationCoordinate2D) {
        addressRelay = interactor.searchAddresses(by: GeoPoint(latitude: coordinate.latitude, longitude: coordinate.longitude))
        Analytics.logEvent(Events.addressFound.rawValue, parameters: [Constants.type: AddressFoundType.fromTap.rawValue])
        addressRelay?.bind { [unowned self] result in
            self.view.showConfirmAlert(
                title: "New reminder",
                message: "Create new reminder for \(result.fullStreetAddress ?? "")?",
                confirmStyle: .default,
                cancelStyle: .cancel,
                confirmText: "Yes",
                confirmCallback: { [unowned self] _ in
                    self.router.navigateToCreateNewTask(with: result)
                    Analytics.logEvent(Events.newTask.rawValue, parameters: [Constants.type: NewTaskType.fromMap.rawValue])
                }, cancelText: "Cancel", cancelCallback: nil
            )
        }.disposed(by: disposeBag)
    }

    func refreshTasks() {
        view.clearMap()
        let activeTasks = interactor.getActiveTasks()
        activeTasks?.forEach { [unowned self] task in self.view.setPin(for: task) }
    }

    func refreshCurrentLocation() {
        let location = interactor.currentLocation
        if let location = location {
            view.updateLocationView(with: CLLocationCoordinate2D(from: location))
        } else {
            view.updateLocationView(with: nil)
        }
    }

    func startUpdateLocation() {
        interactor.startUpdateLocation()
    }

    func stopUpdateLocation() {
        interactor.stopUpdateLocation()
    }

    func closeSuggestion() {
        interactor.longTapSuggestShown = true
        view.hideLongTapSuggestion()
    }
}
