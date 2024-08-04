//
//  Layout.swift
//  castr
//
//  Created by Harrison Hall on 8/3/24.
//

import Foundation

class LayoutState: ObservableObject {
    
    static let shared = LayoutState()
    
    @Published var isRightPanelOpen = true;
    @Published var isLeftPanelOpen = true;
    
    @Published var rightPanelMaxWidth = CGFloat(242);
    @Published var leftPanelMaxWidth = CGFloat(242);
    
}
