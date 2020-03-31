//
//  NavigationItemStack.swift
//  ProjectName
//
//  Created by Devin Abbott on 8/26/18.
//  Copyright © 2018 BitDisco, Inc. All rights reserved.
//

import AppKit

// MARK: - NavigationItemStack

open class NavigationItemStack: NSBox {

    public static let slashDividerImage = NSImage(size: NSSize(width: 6, height: 14), flipped: false, drawingHandler: { rect in
       NSColor.textColor.withAlphaComponent(0.4).setStroke()
       let path = NSBezierPath()
       path.lineWidth = 1
       let pathRect = rect.insetBy(dx: path.lineWidth, dy: path.lineWidth)

       path.move(to: pathRect.origin)
       path.line(to: NSPoint(x: pathRect.maxX, y: pathRect.maxY))
       path.stroke()
       path.lineCapStyle = .round
       return true
   })

    public struct Style: Equatable {
        public var itemStyle: NavigationItemView.Style = .default
        public var activeItemStyle: NavigationItemView.Style = .default
        public var itemsHaveEqualWidth: Bool = false
        public var padding: CGFloat = 2
        public var dividerPadding: CGFloat = 4
        public var dividerImage: NSImage? = NavigationItemStack.slashDividerImage
        public var disabledAlphaValue: CGFloat = 0.5

        public static var `default` = Style()

        public static var compressible: Style = {
            var style = Style.default
            style.itemStyle = .compressible
            return style
        }()

        public static var segmentedControl: Style = {
            var style = Style.default
            style.itemStyle.textColor = NSColor.themed(color: NSColor.disabledControlTextColor)
            style.dividerImage = nil
            return style
        }()
    }

    // MARK: Lifecycle

    public init(items: [NavigationItem] = [], isEnabled: Bool = true, activeItem: UUID? = nil) {
        self.items = items
        self.isEnabled = isEnabled
        self.activeItem = activeItem

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

    public var items: [NavigationItem] {
        didSet {
            if oldValue != items {
                update()
            }
        }
    }

    public var activeItem: UUID? {
        didSet {
            if oldValue != activeItem {
                update()
            }
        }
    }

    public var style: Style = Style() {
       didSet {
           if oldValue != style {
               update()
           }
       }
    }

    public var onClickItem: ((UUID) -> Void)?

    public var onRequestPasteboardItem: ((UUID) -> NSPasteboardItem?)?

    // MARK: Private

    private var stackView = NSStackView()

    private func setUpViews() {
        boxType = .custom
        borderType = .noBorder
        contentViewMargins = .zero

        stackView.orientation = .horizontal
        stackView.spacing = 0

        addSubview(stackView)
    }

    private func setUpConstraints() {
        translatesAutoresizingMaskIntoConstraints = false
        stackView.translatesAutoresizingMaskIntoConstraints = false

        stackView.topAnchor.constraint(equalTo: topAnchor, constant: 2).isActive = true
        stackView.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: 2).isActive = true
        stackView.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -2).isActive = true
        stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -2).isActive = true
        stackView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true

        stackView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        stackView.setHuggingPriority(.defaultLow, for: .horizontal)
    }

    private func update() {
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

        for item in items {
            let itemView = NavigationItemView(titleText: item.title, icon: item.icon)
            itemView.toolTip = item.title
            itemView.style = item.id == activeItem ? style.activeItemStyle : style.itemStyle
            itemView.onClick = { [unowned self] in self.onClickItem?(item.id) }
            itemView.onRequestPasteboardItem = { [unowned self] in self.onRequestPasteboardItem?(item.id) }

            stackView.addArrangedSubview(itemView)

            if item != items.last {
                stackView.setCustomSpacing(style.dividerPadding, after: itemView)

                if let dividerImage = style.dividerImage {
                    let divider = NSImageView()
                    divider.image = dividerImage
                    divider.widthAnchor.constraint(equalToConstant: dividerImage.size.width).isActive = true
                    divider.heightAnchor.constraint(equalToConstant: dividerImage.size.height).isActive = true
                    stackView.addArrangedSubview(divider)
                    stackView.setCustomSpacing(style.dividerPadding, after: divider)
                }
            }
        }

        let breadcrumbItems: [NavigationItemView] = stackView.arrangedSubviews.compactMap { $0 as? NavigationItemView }

        if style.itemsHaveEqualWidth {
            zip(breadcrumbItems.dropFirst(), breadcrumbItems.dropLast()).forEach { a, b in
                a.widthAnchor.constraint(equalTo: b.widthAnchor).isActive = true
            }
        }

        alphaValue = isEnabled ? 1 : style.disabledAlphaValue
    }
}

