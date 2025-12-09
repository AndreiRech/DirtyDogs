import XCTest

class MenuPage {
    let app: XCUIApplication
    
    // MARK: - Inicialização
    init(app: XCUIApplication) {
        self.app = app
    }
    
    // MARK: - Elementos (Mapeamento)
    // Usamos computed properties para buscar o elemento sempre que for chamado,
    // garantindo que o estado atual da tela seja respeitado.
    
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
    
    // MARK: - Ações (Interações)
    
    @discardableResult
    func verifyLoaded() -> Self {
        XCTAssertTrue(view.waitForExistence(timeout: 5), "A tela de menu deveria ter carregado")
        XCTAssertTrue(playButton.exists, "O botão de jogar deve estar visível")
        return self
    }
    
    @discardableResult
    func tapPlay() -> Self {
        playButton.tap()
        return self
    }
    
    @discardableResult
    func tapSoundToggle() -> Self {
        soundButton.tap()
        return self
    }
    
    @discardableResult
    func tapHapticsToggle() -> Self {
        hapticsButton.tap()
        return self
    }
    
    // Função auxiliar para verificar estados visuais (ex: se o botão mudou de imagem/label)
    func verifySoundIsDisabled() -> Bool {
        // Supondo que o label mude ou que o identificador mude quando desativado
        // UI Tests geralmente verificam Label ou Value
        return soundButton.label.contains("Disabled") || soundButton.label.contains("Off")
    }
}