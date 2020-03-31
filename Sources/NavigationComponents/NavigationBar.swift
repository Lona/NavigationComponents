//
//  NavigationControl.swift
//  ProjectName
//
//  Created by Devin Abbott on 8/26/18.
//  Copyright © 2018 BitDisco, Inc. All rights reserved.
//

import AppKit

// MARK: - NavigationBar

open class NavigationBar: NSBox {

    public struct Style: Equatable {
        public var stackStyle: NavigationItemStack.Style = .compressible
        public var navigationControlStyle: NavigationControl.Style = .default
        public var spacing: CGFloat = 4

        public static var `default` = Style()
    }

    // MARK: Lifecycle

    public init(items: [NavigationItem] = [], isEnabled: Bool = true) {
        self.items = items
        self.isEnabled = isEnabled

        super.init(frame: .zero)

        setUpViews()
        setUpConstraints()

        update()
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Public

    public var isEnabled: Bool {
        didSet {
            if oldValue != isEnabled {
                update()
            }
        }
    }

    public var items: [NavigationItem] = [] {
        didSet {
            if oldValue != items {
                update()
            }
        }
    }

    public var onClickItem: ((UUID) -> Void)?

    public var onClickForward: (() -> Void)?

    public var onClickBack: (() -> Void)?

    public var isForwardEnabled: Bool = false {
        didSet {
            if oldValue != isForwardEnabled {
                update()
            }
        }
    }

    public var isBackEnabled: Bool = false {
        didSet {
            if oldValue != isBackEnabled {
                update()
            }
        }
    }

    public var menuForForwardItem: (() -> NSMenu?)?

    public var menuForBackItem: (() -> NSMenu?)?

    public var style: Style = Style() {
       didSet {
           if oldValue != style {
               update()
           }
       }
    }

    public var accessoryView: NSView? {
        didSet {
            if oldValue != accessoryView {
                oldValue?.removeFromSuperview()

                if let rightView = accessoryView {
                    addSubview(rightView)

                    rightView.translatesAutoresizingMaskIntoConstraints = false
                    rightView.topAnchor.constraint(equalTo: topAnchor, constant: 2).isActive = true
                    rightView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -2).isActive = true
                    rightView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -2).isActive = true

                    itemStack.trailingAnchor.constraint(lessThanOrEqualTo: rightView.leadingAnchor, constant: -style.spacing).isActive = true
                }
            }
        }
    }

    // MARK: Private

    private var itemStack = NavigationItemStack()

    private var navigationControl = NavigationControl()

    private func setUpViews() {
        boxType = .custom
        borderType = .noBorder
        contentViewMargins = .zero

        itemStack.onClickItem = { [unowned self] uuid in self.onClickItem?(uuid) }

        navigationControl.onClickBack = { [unowned self] in self.onClickBack?() }
        navigationControl.onClickForward = { [unowned self] in self.onClickForward?() }
        navigationControl.menuForForwardItem = { [unowned self] in self.menuForForwardItem?() }
        navigationControl.menuForBackItem = { [unowned self] in self.menuForBackItem?() }

        addSubview(navigationControl)
        addSubview(itemStack)
    }

    private func setUpConstraints() {
        translatesAutoresizingMaskIntoConstraints = false

        navigationControl.topAnchor.constraint(equalTo: topAnchor).isActive = true
        navigationControl.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        navigationControl.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true

        navigationControl.trailingAnchor.constraint(lessThanOrEqualTo: itemStack.leadingAnchor, constant: -style.spacing).isActive = true

        itemStack.topAnchor.constraint(equalTo: topAnchor).isActive = true
        itemStack.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        itemStack.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor).isActive = true

        let centerConstraint = itemStack.centerXAnchor.constraint(equalTo: centerXAnchor)
        centerConstraint.priority = .defaultLow
        centerConstraint.isActive = true
    }

    private func update() {
        itemStack.items = items
        itemStack.isEnabled = isEnabled
        itemStack.style = style.stackStyle

        navigationControl.style = style.navigationControlStyle

        navigationControl.isForwardEnabled = isForwardEnabled
        navigationControl.isBackEnabled = isBackEnabled
    }

}

