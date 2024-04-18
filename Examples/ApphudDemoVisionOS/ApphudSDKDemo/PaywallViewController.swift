//
//  PaywallViewController.swift
//  ApphudSDKDemo
//
//  Created by Valery on 15.06.2021.
//  Copyright © 2021 Apphud. All rights reserved.
//

import UIKit
import ApphudSDK
import StoreKit
import SwiftUI

enum PaywallID: String {
    case main // should be equal to identifier in your Apphud > Paywalls
    case onboarding
}

class PaywallViewController: UIViewController {

    var dismissCompletion: (() -> Void)?
    var purchaseCallback: ((Bool) -> Void)? // callback style

    private var products = [ApphudProduct]()
    private var paywall: ApphudPaywall?

    @IBOutlet private var optionsStackView: UIStackView!
    private var selectedProduct: ApphudProduct?

    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavBar()
        Task { @MainActor in
            await loadPaywalls()
//            await loadProducts()
        }
    }

    // MARK: - ViewModel Methods

    private func loadProducts() async {
        do {
            if #available(iOS 15.0, *) {
                let products = try await Apphud.fetchProducts()
                print("products successfully fetched: \(products.map { $0.id })")
            }
        } catch {
            print("products fetch error = \(error)")
        }
    }

    private func loadPaywalls() async {
        let placements = await Apphud.placements()
        let placement = placements.first(where: { $0.identifier == PaywallID.onboarding.rawValue }) ?? placements.first
        if let paywall = placement?.paywall {
            self.handlePaywallReady(paywall: paywall)
        }
    }

    private func handlePaywallReady(paywall: ApphudPaywall) {
        self.paywall = paywall
        // retrieve the products [ApphudProduct] from current paywall
        self.products = paywall.products

        // send Apphud log, that your paywall shown
        Apphud.paywallShown(paywall)

        // setup your UI
        self.updateUI()
    }

    // MARK: - UI

    func updateUI() {
        if optionsStackView.arrangedSubviews.count == 0 {
            products.forEach { product in
                let optionView = PaywallOptionView.viewWith(product: product)
                optionsStackView.addArrangedSubview(optionView)
                optionView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(optionSelected)))
            }
        }

        optionsStackView.arrangedSubviews.forEach { v in
            if let optionView = v as? PaywallOptionView {
                optionView.isSelected = selectedProduct == optionView.product
            }
        }
    }

    @objc func optionSelected(gesture: UITapGestureRecognizer) {
        if let view = gesture.view as? PaywallOptionView {
            selectedProduct = view.product
            updateUI()
        }
    }

    private func setupNavBar() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(closeAction))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Restore", style: .done, target: self, action: #selector(restoreAction))
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        // send Apphud log, that your paywall closed
        self.paywall.map { Apphud.paywallClosed($0) }
        dismissCompletion?()
    }

    // MARK: - Actions

    func purchaseProduct(_ product: ApphudProduct) async {
        self.showLoader()

        let result = await Apphud.purchase(product)

        self.purchaseCallback?(result.error == nil)
        self.hideLoader()

        if result.error == nil {
            self.closeAction()
        }
    }

    @objc private func restoreAction() {
        Task { @MainActor in
            showLoader()
            await Apphud.restorePurchases()
            hideLoader()
            if AppVariables.isPremium {
                closeAction()
            }
        }
    }

    @objc private func closeAction() {
        dismiss(animated: true, completion: nil)
    }

    @IBAction private func buttonAction() {
        guard let product = selectedProduct else {return}

        Task { @MainActor in
            await self.purchaseProduct(product)
        }
    }
}
