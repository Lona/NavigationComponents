//
//  NavigationItemView.swift
//  ProjectName
//
//  Created by Devin Abbott on 8/26/18.
//  Copyright © 2018 BitDisco, Inc. All rights reserved.
//

import AppKit

// MARK: - NavigationItemView

extension NSEdgeInsets: Equatable {
    public static func == (lhs: NSEdgeInsets, rhs: NSEdgeInsets) -> Bool {
        return lhs.top == rhs.top && lhs.left == rhs.left && lhs.right == rhs.right && lhs.bottom == rhs.bottom
    }
}

open class NavigationItemView: NSBox {

    public struct Style: Equatable {
        public var padding: NSEdgeInsets = .init(top: 2, left: 4, bottom: 2, right: 4)
        public var backgroundColor: NSColor = .clear
        public var hoverBackgroundColor: NSColor = NSColor.themed(color: NSColor.textColor.withAlphaComponent(0.1))
        public var pressedBackgroundColor: NSColor = NSColor.themed(color: NSColor.textColor.withAlphaComponent(0.05))
        public var cornerRadius: CGFloat = 3
        public var disabledAlphaValue: CGFloat = 0.5
        public var compressibleTitle: Bool = false
        public var flexibleContainerWidth: Bool = false
        public var textColor: NSColor = NSColor.controlTextColor
        public var font: NSFont = NSFont.systemFont(ofSize: NSFont.systemFontSize(for: .regular))
        public var draggingThreshold: CGFloat = 2.0
        public var isDraggable: Bool = false
        public var iconSize = NSSize(width: 16, height: 16)

        public static var `default` = Style()

        public static var compressible: Style = {
            var style = Style.default
            style.compressibleTitle = true
            return style
        }()
    }

    // MARK: Lifecycle

    public init(titleText: String? = nil, icon: NSImage? = nil, isEnabled: Bool = true) {
        self.titleText = titleText
        self.icon = icon
        self.isEnabled = isEnabled

        super.init(frame: .zero)

        setUpViews()
        setUpConstraints()

        update()

        addTrackingArea(trackingArea)
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        removeTrackingArea(trackingArea)
    }

    // MARK: Public

    public var isEnabled: Bool {
        didSet {
            if oldValue != isEnabled {
                update()
            }
        }
    }

    public var onClick: (() -> Void)?

    public var onLongClick: (() -> Void)?

    public var style: Style = .default {
        didSet {
            if oldValue != style {
                update(updateConstraints: true)
            }
        }
    }

    public var titleText: String? {
        didSet {
            if oldValue != titleText {
                attributedTitleText = NSAttributedString(string: titleText ?? "")
            }
        }
    }

    public var icon: NSImage? {
        didSet {
            if oldValue != icon {
                update()
            }
        }
    }

    public var onRequestPasteboardItem: (() -> NSPasteboardItem?)?

    // MARK: Private

    private var attributedTitleText: NSAttributedString = NSAttributedString() {
        didSet {
            update()
        }
    }

    private var hovered: Bool = false {
        didSet {
            if oldValue != hovered {
                update()
            }
        }
    }

    private var pressed: Bool = false {
        didSet {
            if oldValue != pressed {
                update()
            }
        }
    }

    private var pressedPoint = NSPoint.zero

    private lazy var trackingArea = NSTrackingArea(
        rect: self.frame,
        options: [.mouseEnteredAndExited, .activeAlways, .mouseMoved, .inVisibleRect],
        owner: self
    )

    private let titleView = NSTextField(labelWithString: "")

    private let iconView = NSImageView()

    private var contentLayoutGuide = NSLayoutGuide()

    private var longPressWorkItem: DispatchWorkItem?

    private func setUpViews() {
        boxType = .custom
        borderType = .noBorder
        contentViewMargins = .zero

        addSubview(iconView)
        addSubview(titleView)
        addLayoutGuide(contentLayoutGuide)

        titleView.maximumNumberOfLines = -1
        titleView.lineBreakMode = .byTruncatingTail
    }

    private func setUpConstraints() {
        translatesAutoresizingMaskIntoConstraints = false
        titleView.translatesAutoresizingMaskIntoConstraints = false
        iconView.translatesAutoresizingMaskIntoConstraints = false

        iconViewWidthConstraint = iconView.widthAnchor.constraint(equalToConstant: style.iconSize.width)
        iconViewHeightConstraint = iconView.heightAnchor.constraint(equalToConstant: style.iconSize.height)
        iconView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true

        titleView.widthAnchor.constraint(greaterThanOrEqualToConstant: 12).isActive = true

        titleViewTopConstraint = titleView.topAnchor.constraint(equalTo: topAnchor, constant: style.padding.top)
        titleViewBottomConstraint = titleView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -style.padding.bottom)

        // Use the contentLayoutGuide to center the icon and title within the NavigationItemView
        contentLayoutGuide.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor).isActive = true
        contentLayoutGuide.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor).isActive = true
        contentLayoutGuide.topAnchor.constraint(equalTo: topAnchor).isActive = true
        contentLayoutGuide.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        contentLayoutGuide.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true

        contentLayoutWidthConstraint = contentLayoutGuide.widthAnchor.constraint(equalTo: widthAnchor)

        iconViewLeadingConstraint = iconView.leadingAnchor.constraint(equalTo: contentLayoutGuide.leadingAnchor, constant: style.padding.left)
        iconViewTrailingConstraint = iconView.trailingAnchor.constraint(equalTo: contentLayoutGuide.trailingAnchor, constant: -style.padding.right)
        iconViewTitleViewSiblingConstraint = iconView.trailingAnchor.constraint(equalTo: titleView.leadingAnchor, constant: -style.padding.left)
        titleViewLeadingConstraint = titleView.leadingAnchor.constraint(equalTo: contentLayoutGuide.leadingAnchor, constant: style.padding.left)
        titleViewTrailingConstraint = titleView.trailingAnchor.constraint(equalTo: contentLayoutGuide.trailingAnchor, constant: -style.padding.right)

        NSLayoutConstraint.activate(
            [
                titleViewTopConstraint!,
                titleViewBottomConstraint!,
                iconViewWidthConstraint!,
                iconViewHeightConstraint!
            ] +
            conditionalConstraints(
                titleViewIsHidden: titleView.isHidden,
                iconViewIsHidden: iconView.isHidden
            )
        )
    }

    private var contentLayoutWidthConstraint: NSLayoutConstraint?

    private var iconViewWidthConstraint: NSLayoutConstraint?
    private var iconViewHeightConstraint: NSLayoutConstraint?
    private var titleViewTopConstraint: NSLayoutConstraint?
    private var titleViewBottomConstraint: NSLayoutConstraint?
    private var iconViewLeadingConstraint: NSLayoutConstraint?
    private var iconViewTrailingConstraint: NSLayoutConstraint?
    private var iconViewTitleViewSiblingConstraint: NSLayoutConstraint?
    private var titleViewLeadingConstraint: NSLayoutConstraint?
    private var titleViewTrailingConstraint: NSLayoutConstraint?

    private func conditionalConstraints(titleViewIsHidden: Bool, iconViewIsHidden: Bool) -> [NSLayoutConstraint] {
        var constraints: [NSLayoutConstraint?]

        iconViewWidthConstraint?.constant = style.iconSize.width
        iconViewHeightConstraint?.constant = style.iconSize.height
        titleViewTopConstraint?.constant = style.padding.top
        titleViewBottomConstraint?.constant = -style.padding.bottom

        iconViewLeadingConstraint?.constant = style.padding.left
        titleViewLeadingConstraint?.constant = style.padding.left
        iconViewTitleViewSiblingConstraint?.constant = -style.padding.left
        iconViewTrailingConstraint?.constant = -style.padding.right
        titleViewTrailingConstraint?.constant = -style.padding.right

        titleView.setContentCompressionResistancePriority(style.compressibleTitle ? .defaultLow : .defaultHigh, for: .horizontal)

        if contentLayoutWidthConstraint?.isActive != !style.flexibleContainerWidth {
            contentLayoutWidthConstraint?.isActive = !style.flexibleContainerWidth
        }

        if titleView.textColor != style.textColor {
            titleView.textColor = style.textColor
        }

        if titleView.font != style.font {
            titleView.font = style.font
        }

        switch (titleViewIsHidden, iconViewIsHidden) {
        case (false, false):
            constraints = [
                iconViewLeadingConstraint,
                iconViewTitleViewSiblingConstraint,
                titleViewTrailingConstraint
            ]
        case (false, true):
            constraints = [
                titleViewLeadingConstraint,
                titleViewTrailingConstraint
            ]
        case (true, false):
            constraints = [
                iconViewLeadingConstraint,
                iconViewTrailingConstraint
            ]
        case (true, true):
            constraints = []
        }

        return constraints.compactMap({ $0 })
    }

    public override func mouseEntered(with event: NSEvent) {
        hovered = true
    }

    public override func mouseExited(with event: NSEvent) {
        hovered = false
    }

    public override func mouseUp(with event: NSEvent) {
        if hovered && isEnabled {
            handleClick()
        }

        pressed = false

        longPressWorkItem?.cancel()
        longPressWorkItem = nil
    }

    public override func mouseDown(with event: NSEvent) {
        if hovered {
            let point = convert(event.locationInWindow, from: nil)

            // Double check that the point is within the bounds.
            // I recall this improves handling of quick clicks when other buttons are nearby...
            // but maybe not necessary
            if bounds.contains(point) {
                pressed = true
                pressedPoint = point

                if let _ = onLongClick {
                    let workItem = DispatchWorkItem(block: { [weak self] in
                        guard let self = self else { return }

                        self.hovered = false
                        self.pressed = false

                        self.onLongClick?()
                    })

                    longPressWorkItem = workItem

                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.4, execute: workItem)
                }
            }
        }
    }

    public override func mouseDragged(with event: NSEvent) {
        guard style.isDraggable else { return }

        let point = convert(event.locationInWindow, from: nil)

        if abs(point.x - pressedPoint.x) < style.draggingThreshold &&
            abs(point.y - pressedPoint.y) < style.draggingThreshold {
            return
        }

        guard let pasteboardItem = onRequestPasteboardItem?() else { return }

        pressed = false
        update()

        let draggingItem = NSDraggingItem(pasteboardWriter: pasteboardItem)

        let pdf = dataWithPDF(inside: bounds)
        guard let snapshot = NSImage(data: pdf) else { return }

        draggingItem.setDraggingFrame(bounds, contents: snapshot)

        beginDraggingSession(with: [draggingItem], event: event, source: self)
    }

    public override func hitTest(_ point: NSPoint) -> NSView? {
        if frame.contains(point) {
            return self
        }

        return nil
    }

    private func handleClick() {
        onClick?()
    }

    private func update(updateConstraints: Bool = false) {
        let iconViewIsHidden = iconView.isHidden
        let titleViewIsHidden = titleView.isHidden

        if let titleText = titleText {
            titleView.isHidden = false
            titleView.stringValue = titleText
        } else {
            titleView.isHidden = true
        }
        
        if let icon = icon {
            iconView.isHidden = false
            iconView.image = icon
            iconView.alphaValue = isEnabled ? 1 : style.disabledAlphaValue
        } else {
            iconView.isHidden = true
            iconView.image = nil
        }

        if updateConstraints || iconViewIsHidden != iconView.isHidden || titleViewIsHidden != titleView.isHidden {
            NSLayoutConstraint.deactivate(
                conditionalConstraints(
                    titleViewIsHidden: titleViewIsHidden,
                    iconViewIsHidden: iconViewIsHidden
                )
            )
            NSLayoutConstraint.activate(
                conditionalConstraints(
                    titleViewIsHidden: titleView.isHidden,
                    iconViewIsHidden: iconView.isHidden
                )
            )
        }

        if isEnabled && pressed {
            fillColor = style.pressedBackgroundColor
        } else if isEnabled && hovered {
            fillColor = style.hoverBackgroundColor
        } else {
            fillColor = style.backgroundColor
        }

        cornerRadius = style.cornerRadius
    }
}

// MARK: - NSDraggingSource

extension NavigationItemView: NSDraggingSource {
    public func draggingSession(_ session: NSDraggingSession, sourceOperationMaskFor context: NSDraggingContext) -> NSDragOperation {
        return .move
    }
}
