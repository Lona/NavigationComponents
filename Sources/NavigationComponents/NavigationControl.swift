//
//  NavigationControl.swift
//  ProjectName
//
//  Created by Devin Abbott on 8/26/18.
//  Copyright © 2018 BitDisco, Inc. All rights reserved.
//

import AppKit

// MARK: - NavigationControl

open class NavigationControl: NSBox {

    public struct Style: Equatable {
        public var itemStyle: NavigationItemView.Style = .default
        public var padding: CGFloat = 2
        public var menuOffset: NSPoint = .init(x: 0, y: -3)

        public static var `default` = Style()
    }

    // MARK: Lifecycle

    public init() {
        super.init(frame: .zero)

        setUpViews()
        setUpConstraints()

        update()
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Public

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

    public var onClickForward: (() -> Void)?

    public var onClickBack: (() -> Void)?

    public var menuForForwardItem: (() -> NSMenu?)?

    public var menuForBackItem: (() -> NSMenu?)?

    public var style: Style = Style() {
       didSet {
           if oldValue != style {
               update()
           }
       }
    }

    // MARK: Private

    private var stackView = NSStackView()

    private var forwardItem = NavigationItemView(icon: NSImage(named: NSImage.goForwardTemplateName))

    private var backItem = NavigationItemView(icon: NSImage(named: NSImage.goBackTemplateName))

    private func displayPopUpMenu(_ menu: NSMenu, view: NSView) {
        let location = NSPoint(x: self.style.menuOffset.x, y: self.style.menuOffset.y - self.style.padding)

        menu.popUp(positioning: nil, at: location, in: view)
    }

    private func setUpViews() {
        boxType = .custom
        borderType = .noBorder
        contentViewMargins = .zero

        forwardItem.toolTip = "Go Forward"
        backItem.toolTip = "Go Back"

        forwardItem.onClick = { [unowned self] in self.onClickForward?() }

        backItem.onClick = { [unowned self] in self.onClickBack?() }

        forwardItem.onLongClick = { [unowned self] in
            guard let menu = self.menuForForwardItem?() else { return }

            self.displayPopUpMenu(menu, view: self.forwardItem)
        }

        backItem.onLongClick = { [unowned self] in
            guard let menu = self.menuForBackItem?() else { return }

            self.displayPopUpMenu(menu, view: self.backItem)
        }

        stackView.orientation = .horizontal
        stackView.spacing = 0

        addSubview(stackView)

        stackView.addArrangedSubview(backItem)
        stackView.addArrangedSubview(forwardItem)
    }

    private func setUpConstraints() {
        translatesAutoresizingMaskIntoConstraints = false
        stackView.translatesAutoresizingMaskIntoConstraints = false

        stackView.topAnchor.constraint(equalTo: topAnchor, constant: 2).isActive = true
        stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 2).isActive = true
        stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -2).isActive = true
        stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -2).isActive = true
    }

    private func update() {
        var forwardItemStyle = style.itemStyle

        // Make adjustments for this specific icon
        forwardItemStyle.padding.left = forwardItemStyle.padding.left - 1
        forwardItemStyle.padding.right = forwardItemStyle.padding.right + 1

        forwardItem.style = forwardItemStyle
        backItem.style = style.itemStyle

        forwardItem.isEnabled = isForwardEnabled
        backItem.isEnabled = isBackEnabled
    }
}

