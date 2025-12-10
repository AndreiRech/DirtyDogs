//
//  MenuPage.swift
//  DirtyDogs
//
//  Created by Andrei Rech on 09/12/25.
//

import XCTest

class MenuPage {
    let app: XCUIApplication
    
    init(app: XCUIApplication) {
        self.app = app
    }
    
    var view: XCUIElement {
        app.otherElements[MenuIdentifiers.menuView.rawValue]
    }
    
    var titleImage: XCUIElement {
        app.images[MenuIdentifiers.titleImage.rawValue]
    }
    
    var playButton: XCUIElement {
        app.buttons[MenuIdentifiers.playButton.rawValue]
    }
    
    var soundButton: XCUIElement {
        app.buttons[MenuIdentifiers.soundButton.rawValue]
    }
    
    var hapticsButton: XCUIElement {
        app.buttons[MenuIdentifiers.hapticsButton.rawValue]
    }
    
    
    func verifyLoaded() {
        XCTAssertTrue(view.waitForExistence(timeout: 10), "Menu screen should have been displayed.")
        XCTAssertTrue(playButton.exists, "Play button should be visible.")
    }
    
    func tapPlay() {
        playButton.tap()
    }
    
    func tapSoundToggle() {
        soundButton.tap()
    }
    
    func tapHapticsToggle() {
        hapticsButton.tap()
    }
    
    func verifySoundIsDisabled() -> Bool {
        return soundButton.label.contains("Disabled")
    }
}
