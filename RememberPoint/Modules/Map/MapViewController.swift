//
//  MapViewController.swift
//  RememberPoint
//
//  Created by Pavel Chehov on 03/01/2019.
//  Copyright © 2019 Pavel Chehov. All rights reserved.
//

import Crashlytics
import GoogleMaps
import RxCocoa
import RxSwift
import UIKit

enum MapStyle {
    case light, dark
}

protocol MapViewProtocol: AlertProtocol, AnyObject {
    var presenter: MapPresenterProtocol! { get set }
    var configurator: MapConfiguratorProtocol! { get set }
    func drawLongTapSuggestion()
    func hideLongTapSuggestion()
    func setPin(for task: Task)
    func updateLocationView(with point: CLLocationCoordinate2D?)
    func clearMap()
}

class MapViewController: UIViewController, MapViewProtocol {
    var presenter: MapPresenterProtocol!
    var configurator: MapConfiguratorProtocol! = MapConfigurator()
    @IBOutlet var mapView: GMSMapView!
    @IBOutlet var selectAddressButton: UIButton!
    @IBOutlet var overlayView: UIView!
    @IBOutlet var suggestionView: UIView!
    private var markers = [GMSMarker]()
    private let disposeBag = DisposeBag()
    private let searchResultsViewController = SearchResultsViewController()

    override func viewDidLoad() {
        super.viewDidLoad()
        configurator.configure(with: self)

        let searchController = UISearchController(searchResultsController: searchResultsViewController)
        searchController.searchBar.placeholder = "Enter address"
        searchController.obscuresBackgroundDuringPresentation = false
        searchResultsViewController.searchBar = searchController.searchBar
        navigationItem.searchController = searchController
        definesPresentationContext = true

        selectAddressButton.backgroundColor = UIColor.primaryColor
        selectAddressButton.rx.tap.bind { [unowned self] _ in
            self.presenter.closeSuggestion()
        }.disposed(by: disposeBag)

        setupMap()
        presenter.refreshCurrentLocation()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(willEnterForeground),
            name: UIApplication.willEnterForegroundNotification,
            object: nil
        )
        
        if #available(iOS 13, *) {
            searchController.searchBar.searchTextField.backgroundColor = .secondarySystemBackground
            
            // FIX: iOS 13 bug with strange gap in searchResultsVC
            // https://stackoverflow.com/questions/57521967/ios-13-strange-search-controller-gap
            extendedLayoutIncludesOpaqueBars = true
            edgesForExtendedLayout = .all
            
            // New appearance API for searchcontroller
            //https://stackoverflow.com/questions/57746292/navigation-bar-becomes-white-when-a-uisearchcontroller-is-added-to-it
            //let appearance = UINavigationBarAppearance()
            //appearance.backgroundColor = .primaryColor
            //appearance.titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.white]
            //navigationItem.standardAppearance = appearance
            // navigationItem.scrollEdgeAppearance = appearance
            
            if #available(iOS 13.1, *) {
                navigationItem.title = ""
            }
        } else {
            // hacks, tricks and wonders
            if let searchBackground = searchController.searchBar.subviews.first?.subviews.first(where: { $0 is UITextField })?.subviews.first {
                searchBackground.layer.backgroundColor = UIColor.white.cgColor
                searchBackground.layer.cornerRadius = 10
            }
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        presenter.refreshTasks()
        presenter.startUpdateLocation()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        presenter.stopUpdateLocation()
    }

    func clearMap() {
        mapView.clear()
    }

    func setupMap() {
        mapView.delegate = self
        mapView.isMyLocationEnabled = true
        mapView.settings.myLocationButton = true
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapView.moveCamera(GMSCameraUpdate.zoom(by: 14))
        mapView.paddingAdjustmentBehavior = .always
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

    func updateLocationView(with point: CLLocationCoordinate2D?) {
        let location = mapView.myLocation
        guard let coordinates = location?.coordinate ?? point else { return }
        let camera = GMSCameraPosition.camera(withTarget: coordinates, zoom: mapView.camera.zoom)
        mapView.animate(to: camera)
    }

    func setPin(for task: Task) {
        guard let location = task.location else { return }
        let marker = GMSMarker()
        let image = UIImage(named: "pin")
        marker.icon = image
        marker.position = CLLocationCoordinate2D(from: location)
        marker.map = mapView
        marker.snippet = task.title
        markers.append(marker)
    }

    func drawLongTapSuggestion() {
        overlayView.isHidden = false
        suggestionView.isHidden = false
    }

    func hideLongTapSuggestion() {
        overlayView.isHidden = true
        suggestionView.isHidden = true
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        setupNeededMapStyle()
    }

    @objc func willEnterForeground(_ notification: Notification) {
        presenter.refreshCurrentLocation()
        presenter.refreshTasks()
    }
}

extension MapViewController: GMSMapViewDelegate {
    func mapView(_ mapView: GMSMapView, didLongPressAt coordinate: CLLocationCoordinate2D) {
        presenter.longPress(by: coordinate)
    }
}

extension MapViewController: UIAdaptivePresentationControllerDelegate {
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        presenter.refreshTasks()
    }
}
