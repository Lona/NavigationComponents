//
//  NSColor+Theme.swift
//
//  Created by Devin Abbott on 3/24/20.
//

import AppKit

extension NSColor {
    internal static func themed(color: @escaping @autoclosure () -> NSColor) -> NSColor {
        if #available(OSX 10.15, *) {
            // 10.15 lets us update a color dynamically based on current theme
            return self.init(name: nil, dynamicProvider: { appearance in
                return color()
            })
        } else {
            return color()
        }
    }
}
