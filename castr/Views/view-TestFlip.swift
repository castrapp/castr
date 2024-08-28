//
//  view-TestFlip.swift
//  castr
//
//  Created by Harrison Hall on 8/28/24.
//

import Foundation
import SwiftUI


struct Flip: View {
    @State var counter: Double
    
    init(counter: Double) {
        self.counter = counter
    }
    
    var body: some View {
        ZStack {
            Text("top")
                .font(.system(size: 16))
                .rotation3DEffect(
                    .degrees(90),
                    axis: (x: 1, y: 0, z: 0),
                    perspective: 0.5
                )
                .offset(x: 0, y: -16)
//                .scaleEffect( 0.85 : 1.0)
            
            Text("Middle")
                .font(.system(size: 16))
                .rotation3DEffect(
                    .degrees(0),
                    axis: (x: 1, y: 0, z: 0),
                    perspective: 0.5
                )
                .offset(x: 0, y: 0)
//                .scaleEffect(!flip ? 1.0 : 0.85)
            
            Text("bottom")
                .font(.system(size: 16))
                .rotation3DEffect(
                    .degrees(-90),
                    axis: (x: 1, y: 0, z: 0),
                    perspective: 0.5
                )
                .offset(x: 0, y: 16)
            
            Text("back")
                .font(.system(size: 16))
                .rotation3DEffect(
                    .degrees(180),
                    axis: (x: 1, y: 0, z: 0),
                    perspective: 0.5
                )
                .offset(x: 0, y: 0)
        }
        .rotation3DEffect(
            .degrees(counter * 90),
            axis: (x: 1, y: 0, z: 0),
            perspective: 0.5
        )
//        .animation(.easeInOut(duration: 0.25), value: counter)
    }
    
    
}
