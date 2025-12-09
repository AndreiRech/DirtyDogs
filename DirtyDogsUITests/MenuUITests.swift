//
//  MenuUITests.swift
//  DirtyDogs
//
//  Created by Andrei Rech on 09/12/25.
//


import XCTest

@MainActor
final class MenuUITests: XCTestCase {
    var app: XCUIApplication!
    var menuPage: MenuPage!
        
    override func setUp() {
        super.setUp()
        
        continueAfterFailure = false
        
        app = XCUIApplication()
        app.launch()
        
        menuPage = MenuPage(app: app)
    }
    
    override func tearDown() {
        menuPage = nil
        app = nil
        
        super.tearDown()
    }
    
    func testPlayButtonInteraction() {
        menuPage.verifyLoaded()
        menuPage.tapPlay()
    }
    
    func testSettingsToggles() {
        menuPage.verifyLoaded()
        menuPage.tapSoundToggle()
        menuPage.tapHapticsToggle()
        
        XCTAssertTrue(menuPage.soundButton.isEnabled)
        XCTAssertTrue(menuPage.hapticsButton.isEnabled)
    }
    
    func testMenuElementsAreInteractable() {
        menuPage.verifyLoaded()
        
        XCTAssertTrue(menuPage.playButton.isHittable)
        XCTAssertTrue(menuPage.soundButton.isHittable)
    }
}
