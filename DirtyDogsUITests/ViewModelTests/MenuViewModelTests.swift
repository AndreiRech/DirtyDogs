import Testing
import Foundation
@testable import DirtyDogs

@MainActor
struct MenuViewModelTests {
    var matchManager: MatchManager!
    var mockHaptics: MockHapticsService!
    var viewModel: MenuViewModelProtocol
    
    init() {
        matchManager = MatchManager()
        mockHaptics = MockHapticsService()
        viewModel = MenuViewModel(matchManager: matchManager, hapticsService: mockHaptics)
    }
    
    @Test("Play Button State - Disabled when not authenticated")
    func playButtonDisabledState() {
        // Given
        
        // When
        matchManager.authenticatingState = .authenticating
        
        // Then
        #expect(viewModel.isPlayButtonDisabled == true)
        #expect(viewModel.authenticatingState == .authenticating)
    }
    
    @Test("Play Button State - Enabled when authenticated")
    func playButtonEnabledState() {
        // Given
        
        // When
        matchManager.authenticatingState = .authenticated
        matchManager.gameState = .none
        
        // Then
        #expect(viewModel.isPlayButtonDisabled == false)
    }
    
    @Test("Play Button Action - Triggers matchmaking and haptics")
    func playButtonAction() {
        // Given
        
        // When
        viewModel.playButtonTapped()
        
        // Then
        #expect(mockHaptics.complexSuccessCalled == true)
    }
}
