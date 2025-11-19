//
//  GridViewModel.swift
//  DirtyDogs
//
//  Created by júlia fazenda ruiz on 18/11/25.
//

import SwiftUI

@Observable
class GridViewModel: GridViewModelProtocol {
    
    var blocks: [GridBlock] = Array(repeating: GridBlock(), count: 9)
    var selectedIndex: Int? = nil
    
    let columns = Array(repeating: GridItem(.flexible(), spacing: 12), count: 3)
    
    var showSheet: Bool = false
    
    var matchManager: MatchManager?
    
    init(matchManager: MatchManager? = nil) {
        self.matchManager = matchManager
    }
    
}
