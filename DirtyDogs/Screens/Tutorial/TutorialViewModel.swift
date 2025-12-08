//
//  TutorialViewModel.swift
//  DirtyDogs
//
//  Created by Andrei Rech on 08/12/25.
//

import SwiftUI

@Observable
class TutorialViewModel: TutorialViewModelProtocol {
    var currentPage: Int = 1
    var numberOfPages: Int = 3
    
    func getPage(for page: Int) -> String {
        if page >= 1 && page <= numberOfPages {
            return "Onb\(page)"
        }
        return ""
    }
}
