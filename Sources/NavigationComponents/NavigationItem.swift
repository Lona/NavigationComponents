//
//  NavigationItem.swift
//
//  Created by Devin Abbott on 3/24/20.
//

import AppKit

// MARK: - NavigationItem

public struct NavigationItem: Equatable {
    public var id: UUID
    public var title: String
    public var icon: NSImage?

    public init(id: UUID, title: String, icon: NSImage?) {
        self.id = id
        self.title = title
        self.icon = icon
    }
}
