//
//  TutorialViewModelProtocol.swift
//  DirtyDogs
//
//  Created by Andrei Rech on 08/12/25.
//

protocol TutorialViewModelProtocol {
    var currentPage: Int { get set }
    var numberOfPages: Int { get }
    
    func getPage(for page: Int) -> String
}
