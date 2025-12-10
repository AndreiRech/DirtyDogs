//
//  TutorialViewModelTests.swift
//  DirtyDogs
//
//  Created by Andrei Rech on 09/12/25.
//

import Testing
@testable import DirtyDogs

struct TutorialViewModelTests {
    @Test("Get Page returns correct asset names")
    func pageAssetNames() {
        let viewModel = TutorialViewModel()
        
        #expect(viewModel.getPage(for: 1) == "Onb1")
        #expect(viewModel.getPage(for: 2) == "Onb2")
        #expect(viewModel.getPage(for: 3) == "Onb3")
    }
    
    @Test("Get Page returns empty for out of bounds")
    func pageOutOfBounds() {
        let viewModel = TutorialViewModel()
        
        #expect(viewModel.getPage(for: 0) == "")
        #expect(viewModel.getPage(for: 4) == "")
    }
    
    @Test("ViewModel initializes with correct defaults")
    func defaults() {
        let viewModel = TutorialViewModel()
        #expect(viewModel.currentPage == 1)
        #expect(viewModel.numberOfPages == 3)
    }
}
