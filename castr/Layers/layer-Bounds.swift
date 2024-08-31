//
//  layer-Bounds.swift
//  castr
//
//  Created by Harrison Hall on 8/30/24.
//

import Foundation
import AppKit
import SwiftUI



enum CornerType {
    case topLeft
    case topRight
    case bottomLeft
    case bottomRight
    
    var name: String {
        switch self {
        case .topLeft: return "topLeft"
        case .topRight: return "topRight"
        case .bottomLeft: return "bottomLeft"
        case .bottomRight: return "bottomRight"
        }
    }
}




class CornerBounds: CALayer {
    
    let cornerType: CornerType
    
    init(cornerType: CornerType) {
        self.cornerType = cornerType
        super.init()
        self.name = cornerType.name
        self.frame.size = CGSize(width: 10, height: 10)
        self.borderWidth = 1
        self.backgroundColor = CGColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func resize(withOldSuperlayerSize oldSize: CGSize) {
        guard let superlayer = superlayer else { return }
//        print("resizing bounds")
        switch cornerType {
        case .topLeft:
            self.frame.origin = CGPoint(
                x: superlayer.frame.minX - (self.frame.width / 2),
                y: superlayer.frame.maxY - (self.frame.height / 2)
            )
        case .topRight:
            self.frame.origin = CGPoint(
                x: superlayer.frame.maxX - (self.frame.width / 2),
                y: superlayer.frame.maxY - (self.frame.height / 2)
            )
        case .bottomLeft:
            self.frame.origin = CGPoint(
                x: superlayer.frame.minX - (self.frame.width / 2),
                y: superlayer.frame.minY - (self.frame.height / 2)
            )
        case .bottomRight:
            self.frame.origin = CGPoint(
                x: superlayer.frame.maxX - (self.frame.width / 2),
                y: superlayer.frame.minY - (self.frame.height / 2)
            )
        }
        
    }
    
    override func action(forKey event: String) -> CAAction? {
        return NSNull()
        
    }
}

