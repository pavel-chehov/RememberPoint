//
//  ViewController.swift
//  RememberPoint
//
//  Created by Pavel Chehov on 03/01/2019.
//  Copyright © 2019 Pavel Chehov. All rights reserved.
//

import UIKit

protocol SetupViewProtocol: AnyObject {
    var presenter: SetupPresenterProtocol! { get set }
    var configurator: SetupConfiguratorProtocol! { get set }
    func setCurrentPage(to page: Int)
    func setButtonTitle(title: String)
}

class SetupViewController: UIViewController, SetupViewProtocol {
    var presenter: SetupPresenterProtocol!
    var configurator: SetupConfiguratorProtocol! = SetupConfigurator()

    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var actionButton: UIButton!
    @IBOutlet var pagerView: UIPageControl!

    override func viewDidLoad() {
        super.viewDidLoad()
        actionButton.backgroundColor = UIColor.primaryColor
        pagerView.tintColor = UIColor.primaryColor
        configurator.configure(with: self)
        presenter.setRequiredButtonTitle()
        collectionView.register(UINib(nibName: "SetupCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: SetupCollectionViewCell.identifier)
        collectionView.delegate = self
        collectionView.dataSource = self
        pagerView.numberOfPages = presenter.setupData.count
        pagerView.currentPage = 0
    }

    @IBAction func actionButtonClicked(_ sender: Any) {
        presenter.actionButtonClicked()
    }

    func setCurrentPage(to page: Int) {
        pagerView.currentPage = page
        collectionView.scrollToItem(at: IndexPath(row: page, section: 0), at: .right, animated: true)
    }

    func setButtonTitle(title: String) {
        actionButton.setTitle(title, for: .normal)
    }
}

extension SetupViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UICollectionViewDelegate {
    // MARK: DataSource

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return presenter.setupData.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SetupCollectionViewCell.identifier, for: indexPath) as! SetupCollectionViewCell
        cell.setup(data: presenter.setupData[indexPath.row])
        return cell
    }

    // MARK: FlowLayout

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.frame.size
    }
}
