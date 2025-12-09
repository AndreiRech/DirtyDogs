import XCTest

final class MenuUITests: XCTestCase {

    var app: XCUIApplication!
    var menuPage: MenuPage!
    
    // MARK: - Setup e TearDown
    
    override func setUp() {
        super.setUp()
        
        // 'continueAfterFailure = false' garante que o teste pare no primeiro erro,
        // economizando tempo e facilitando o debug.
        continueAfterFailure = false
        
        app = XCUIApplication()
        
        // Podemos passar argumentos de lançamento para configurar o app em estado de teste
        // Ex: app.launchArguments = ["--uitesting"]
        app.launch()
        
        // Inicializa o Page Object
        menuPage = MenuPage(app: app)
    }
    
    override func tearDown() {
        // Limpeza de objetos. Se o teste tirou screenshots ou salvou dados,
        // aqui seria o lugar para limpar.
        menuPage = nil
        app = nil
        
        super.tearDown()
    }
    
    // MARK: - Testes
    
    func testMenuInitialState() {
        // Verifica se todos os elementos críticos estão na tela ao abrir
        menuPage
            .verifyLoaded()
    }
    
    func testPlayButtonInteraction() {
        // Teste de fluxo de navegação
        menuPage
            .verifyLoaded()
            .tapPlay()
        
        // Aqui você poderia instanciar um 'GamePage(app: app)' para verificar
        // se a tela de jogo abriu.
        // Ex:
        // let gamePage = GamePage(app: app)
        // XCTAssertTrue(gamePage.view.waitForExistence(timeout: 5))
    }
    
    func testSettingsToggles() {
        // Teste de interação com botões de configuração na mesma tela
        menuPage
            .verifyLoaded()
            .tapSoundToggle()
            .tapHapticsToggle()
        
        // Verificações adicionais
        // Verifique se o botão ainda existe e é clicável
        XCTAssertTrue(menuPage.soundButton.isEnabled)
        XCTAssertTrue(menuPage.hapticsButton.isEnabled)
    }
    
    // Exemplo de teste de Layout (responsividade básica)
    func testMenuElementsAreInteractable() {
        menuPage.verifyLoaded()
        
        XCTAssertTrue(menuPage.playButton.isHittable, "O botão de Play deve ser tocável (não estar coberto)")
        XCTAssertTrue(menuPage.soundButton.isHittable, "O botão de Som deve ser tocável")
    }
}