// ================================================
// SNAKE SPIEL - Swift mit SpriteKit
// ================================================
// ZWECK: Klassisches Snake-Spiel als Blueprint
//        für verschiedene Programmiersprachen
//
// STEUERUNG:
//   - Pfeiltasten (macOS): Schlange lenken
//   - Swipe-Gesten (iOS): Schlange lenken
//   - SPACE: Neustart nach Game Over
//   - ESC: Beenden
//
// SPIELMECHANIK:
//   - Schlange frisst Futter und wächst
//   - Punkte: 10 pro Futter
//   - Game Over: Wandkollision oder Selbstkollision
//
// PLATTFORM:
//   - macOS 11.0+
//   - iOS 14.0+
// ================================================

import SpriteKit
import SwiftUI

// ================================================
// 1. KONSTANTEN DEFINIEREN
// ================================================

struct GameConstants {
    // Spielfeld-Dimensionen
    static let screenWidth: CGFloat = 640
    static let screenHeight: CGFloat = 480
    static let gridSize: CGFloat = 20          // Größe jedes Gitter-Quadrats (Pixel)
    static let borderOffset: CGFloat = 10      // Abstand vom Bildschirmrand
    static let maxSnakeLength: Int = 500       // Maximale Schlangenlänge
    
    // Spielgeschwindigkeit
    static let gameFPS: TimeInterval = 1.0 / 8.0  // 8 FPS (klassisches Tempo)
    
    // Spielfeldbegrenzungen
    static let playfieldLeft: CGFloat = borderOffset + 10
    static let playfieldRight: CGFloat = screenWidth - 20
    static let playfieldTop: CGFloat = borderOffset + 10
    static let playfieldBottom: CGFloat = screenHeight - 20
    
    // Farben
    static let colorWhite: SKColor = .white
    static let colorBlack: SKColor = .black
    static let colorGreen: SKColor = .green
}

// ================================================
// 2. RICHTUNGS-ENUM
// ================================================

enum Direction {
    case up, down, left, right
    
    var vector: CGPoint {
        switch self {
        case .up:    return CGPoint(x: 0, y: GameConstants.gridSize)
        case .down:  return CGPoint(x: 0, y: -GameConstants.gridSize)
        case .left:  return CGPoint(x: -GameConstants.gridSize, y: 0)
        case .right: return CGPoint(x: GameConstants.gridSize, y: 0)
        }
    }
    
    // Prüfe ob Richtung entgegengesetzt ist
    func isOpposite(to other: Direction) -> Bool {
        switch (self, other) {
        case (.up, .down), (.down, .up),
             (.left, .right), (.right, .left):
            return true
        default:
            return false
        }
    }
}

// ================================================
// 3. HAUPT-SZENE KLASSE
// ================================================

class SnakeGameScene: SKScene {
    
    // ================================================
    // 3a. VARIABLEN INITIALISIEREN
    // ================================================
    
    // Schlangen-Array: Position jedes Segmentes
    private var snake: [CGPoint] = []
    
    // Bewegungsrichtung
    private var direction: Direction = .right
    private var nextDirection: Direction = .right
    
    // Spiel-State
    private var length: Int = 5                // Aktuelle Schlangenlänge
    private var foodPosition: CGPoint = .zero  // Futter-Position
    private var score: Int = 0                 // Aktuelle Punktzahl
    private var gameOver: Bool = false         // Spielstatus
    
    // Timer für Spielschleife
    private var lastUpdateTime: TimeInterval = 0
    
    // UI-Elemente
    private var scoreLabel: SKLabelNode!
    private var gameOverLabel: SKLabelNode!
    private var finalScoreLabel: SKLabelNode!
    private var instructionLabel: SKLabelNode!
    
    // Snake-Sprites
    private var snakeNodes: [SKShapeNode] = []
    private var foodNode: SKShapeNode!
    
    // ================================================
    // 4. SZENE INITIALISIERUNG
    // ================================================
    
    override func didMove(to view: SKView) {
        backgroundColor = GameConstants.colorBlack
        
        // UI-Elemente erstellen
        setupUI()
        
        // Spiel initialisieren
        resetGame()
        
        // Swipe-Gesten für iOS hinzufügen
        #if os(iOS)
        setupSwipeGestures(for: view)
        #endif
    }
    
    private func setupUI() {
        // Score Label (oben links)
        scoreLabel = SKLabelNode(fontNamed: "Courier")
        scoreLabel.fontSize = 20
        scoreLabel.fontColor = GameConstants.colorWhite
        scoreLabel.horizontalAlignmentMode = .left
        scoreLabel.position = CGPoint(x: 20, y: GameConstants.screenHeight - 30)
        addChild(scoreLabel)
        
        // Game Over Labels (zentriert)
        gameOverLabel = SKLabelNode(fontNamed: "Courier-Bold")
        gameOverLabel.fontSize = 40
        gameOverLabel.fontColor = GameConstants.colorWhite
        gameOverLabel.text = "*** GAME OVER ***"
        gameOverLabel.position = CGPoint(x: GameConstants.screenWidth / 2,
                                         y: GameConstants.screenHeight / 2 + 40)
        gameOverLabel.isHidden = true
        addChild(gameOverLabel)
        
        finalScoreLabel = SKLabelNode(fontNamed: "Courier")
        finalScoreLabel.fontSize = 24
        finalScoreLabel.fontColor = GameConstants.colorWhite
        finalScoreLabel.position = CGPoint(x: GameConstants.screenWidth / 2,
                                           y: GameConstants.screenHeight / 2)
        finalScoreLabel.isHidden = true
        addChild(finalScoreLabel)
        
        instructionLabel = SKLabelNode(fontNamed: "Courier")
        instructionLabel.fontSize = 18
        instructionLabel.fontColor = GameConstants.colorWhite
        #if os(macOS)
        instructionLabel.text = "Druecke SPACE fuer Neustart oder ESC zum Beenden"
        #else
        instructionLabel.text = "Tippe zum Neustart"
        #endif
        instructionLabel.position = CGPoint(x: GameConstants.screenWidth / 2,
                                           y: GameConstants.screenHeight / 2 - 40)
        instructionLabel.isHidden = true
        addChild(instructionLabel)
    }
    
    #if os(iOS)
    private func setupSwipeGestures(for view: SKView) {
        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        swipeUp.direction = .up
        view.addGestureRecognizer(swipeUp)
        
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        swipeDown.direction = .down
        view.addGestureRecognizer(swipeDown)
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        swipeLeft.direction = .left
        view.addGestureRecognizer(swipeLeft)
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        swipeRight.direction = .right
        view.addGestureRecognizer(swipeRight)
    }
    
    @objc private func handleSwipe(_ gesture: UISwipeGestureRecognizer) {
        guard !gameOver else { return }
        
        switch gesture.direction {
        case .up:
            if !direction.isOpposite(to: .up) { nextDirection = .up }
        case .down:
            if !direction.isOpposite(to: .down) { nextDirection = .down }
        case .left:
            if !direction.isOpposite(to: .left) { nextDirection = .left }
        case .right:
            if !direction.isOpposite(to: .right) { nextDirection = .right }
        default:
            break
        }
    }
    #endif
    
    // ================================================
    // 5. SPIEL ZURÜCKSETZEN
    // ================================================
    
    private func resetGame() {
        // Alte Snake-Nodes entfernen
        snakeNodes.forEach { $0.removeFromParent() }
        snakeNodes.removeAll()
        foodNode?.removeFromParent()
        
        // Startposition: Mitte des Bildschirmes
        snake.removeAll()
        snake.append(CGPoint(x: 320, y: 240))
        
        // Startrichtung: Nach rechts
        direction = .right
        nextDirection = .right
        
        // Startlänge: 5 Segmente
        length = 5
        score = 0
        gameOver = false
        
        // Erste Schlangensegmente (dahinter): Körper nach links
        for i in 1..<5 {
            snake.append(CGPoint(x: 320 - CGFloat(i) * GameConstants.gridSize, y: 240))
        }
        
        // Snake-Nodes erstellen
        createSnakeNodes()
        
        // Erstes Futter platzieren
        placeFood()
        
        // UI aktualisieren
        updateUI()
        gameOverLabel.isHidden = true
        finalScoreLabel.isHidden = true
        instructionLabel.isHidden = true
        
        // Spielfeld-Rand zeichnen
        drawBorder()
    }
    
    private func createSnakeNodes() {
        for _ in 0..<GameConstants.maxSnakeLength {
            let node = SKShapeNode(rectOf: CGSize(width: 16, height: 16))
            node.fillColor = GameConstants.colorWhite
            node.strokeColor = GameConstants.colorBlack
            node.lineWidth = 1
            node.isHidden = true
            addChild(node)
            snakeNodes.append(node)
        }
    }
    
    private func drawBorder() {
        // Spielfeld-Rand zeichnen
        let border = SKShapeNode(rect: CGRect(
            x: GameConstants.borderOffset,
            y: GameConstants.borderOffset,
            width: GameConstants.screenWidth - 2 * GameConstants.borderOffset,
            height: GameConstants.screenHeight - 2 * GameConstants.borderOffset
        ))
        border.strokeColor = GameConstants.colorWhite
        border.lineWidth = 2
        border.fillColor = .clear
        border.zPosition = -1
        addChild(border)
    }
    
    // ================================================
    // 6. FUTTER PLATZIEREN
    // ================================================
    // ZWECK: Neue Futter-Position generieren
    //        (nicht auf Schlange, nicht außerhalb Spielfeld)
    
    private func placeFood() {
        var validPosition = false
        
        repeat {
            validPosition = true
            
            // Zufällige Position im Gitter (20x20 Pixel pro Gitter-Zelle)
            let gridX = Int.random(in: 0..<29)
            let gridY = Int.random(in: 0..<21)
            foodPosition = CGPoint(
                x: CGFloat(gridX) * GameConstants.gridSize + 40,
                y: CGFloat(gridY) * GameConstants.gridSize + 40
            )
            
            // Prüfen ob Futter nicht auf Schlangen-Segment liegt
            for i in 0..<length {
                if foodPosition == snake[i] {
                    validPosition = false
                    break
                }
            }
        } while !validPosition
        
        // Futter-Node erstellen oder aktualisieren
        if foodNode == nil {
            foodNode = SKShapeNode(rectOf: CGSize(width: 16, height: 16))
            foodNode.fillColor = GameConstants.colorWhite
            foodNode.strokeColor = GameConstants.colorBlack
            foodNode.lineWidth = 1
            addChild(foodNode)
        }
        
        foodNode.position = foodPosition
    }
    
    // ================================================
    // 7. EINGABE BEHANDELN (macOS Keyboard)
    // ================================================
    
    #if os(macOS)
    override func keyDown(with event: NSEvent) {
        guard !gameOver else {
            // Game Over: Neustart oder Beenden
            if event.keyCode == 49 { // SPACE
                resetGame()
            } else if event.keyCode == 53 { // ESC
                view?.window?.close()
            }
            return
        }
        
        // Pfeiltasten-Handler (nur wenn nicht entgegengesetzt zu aktueller Richtung)
        switch event.keyCode {
        case 126: // Pfeil OBEN
            if !direction.isOpposite(to: .up) {
                nextDirection = .up
            }
        case 125: // Pfeil UNTEN
            if !direction.isOpposite(to: .down) {
                nextDirection = .down
            }
        case 123: // Pfeil LINKS
            if !direction.isOpposite(to: .left) {
                nextDirection = .left
            }
        case 124: // Pfeil RECHTS
            if !direction.isOpposite(to: .right) {
                nextDirection = .right
            }
        case 53: // ESC
            view?.window?.close()
        default:
            break
        }
    }
    #else
    // iOS: Touch für Neustart
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if gameOver {
            resetGame()
        }
    }
    #endif
    
    // ================================================
    // 8. HAUPTSPIEL-SCHLEIFE (Update)
    // ================================================
    
    override func update(_ currentTime: TimeInterval) {
        // Geschwindigkeit kontrollieren (8 FPS)
        if lastUpdateTime == 0 {
            lastUpdateTime = currentTime
        }
        
        let deltaTime = currentTime - lastUpdateTime
        
        if deltaTime >= GameConstants.gameFPS {
            lastUpdateTime = currentTime
            
            if !gameOver {
                updateGame()
            }
        }
    }
    
    private func updateGame() {
        // Richtung aktualisieren
        direction = nextDirection
        
        // --- 8a. SCHLANGE BEWEGEN ---
        // Body-Segmente nachfolgen (von hinten nach vorne schieben)
        for i in stride(from: length - 1, through: 1, by: -1) {
            if i < snake.count {
                snake[i] = snake[i - 1]
            }
        }
        
        // Kopf bewegen in aktuelle Richtung
        let moveVector = direction.vector
        snake[0] = CGPoint(
            x: snake[0].x + moveVector.x,
            y: snake[0].y + moveVector.y
        )
        
        // --- 8b. KOLLISIONEN PRÜFEN ---
        
        // Wandkollision
        if snake[0].x < GameConstants.playfieldLeft ||
           snake[0].x >= GameConstants.playfieldRight ||
           snake[0].y < GameConstants.playfieldTop ||
           snake[0].y >= GameConstants.playfieldBottom {
            gameOver = true
            handleGameOver()
            return
        }
        
        // Selbstkollision (Kopf trifft Body)
        for i in 1..<length {
            if snake[0] == snake[i] {
                gameOver = true
                handleGameOver()
                return
            }
        }
        
        // --- 8c. FUTTER-LOGIK ---
        // Prüfe ob Kopf das Futter frisst
        if snake[0] == foodPosition {
            length += 1              // Schlange wächst um 1
            score += 10              // 10 Punkte
            placeFood()              // Neues Futter platzieren
            
            // Audio-Feedback
            run(SKAction.playSoundFileNamed("beep.wav", waitForCompletion: false))
        }
        
        // --- 8d. GRAFIK AKTUALISIEREN ---
        updateSnakeNodes()
        updateUI()
    }
    
    private func updateSnakeNodes() {
        // Alle Nodes verstecken
        for node in snakeNodes {
            node.isHidden = true
        }
        
        // Nur aktive Segmente anzeigen
        for i in 0..<length {
            if i < snakeNodes.count {
                snakeNodes[i].position = snake[i]
                snakeNodes[i].isHidden = false
            }
        }
    }
    
    private func updateUI() {
        scoreLabel.text = "SCORE: \(score)  LAENGE: \(length)"
    }
    
    // ================================================
    // 9. GAME OVER BEHANDLUNG
    // ================================================
    
    private func handleGameOver() {
        gameOverLabel.isHidden = false
        finalScoreLabel.text = "FINAL SCORE: \(score)"
        finalScoreLabel.isHidden = false
        instructionLabel.isHidden = false
    }
}

// ================================================
// 10. SWIFTUI VIEW (App-Wrapper)
// ================================================

struct SnakeGameView: View {
    var scene: SKScene {
        let scene = SnakeGameScene()
        scene.size = CGSize(width: GameConstants.screenWidth,
                           height: GameConstants.screenHeight)
        scene.scaleMode = .aspectFit
        return scene
    }
    
    var body: some View {
        SpriteView(scene: scene)
            .frame(width: GameConstants.screenWidth,
                   height: GameConstants.screenHeight)
            .edgesIgnoringSafeArea(.all)
    }
}

// ================================================
// 11. APP ENTRY POINT
// ================================================

@main
struct SnakeGameApp: App {
    var body: some Scene {
        WindowGroup {
            SnakeGameView()
                #if os(macOS)
                .frame(width: GameConstants.screenWidth,
                       height: GameConstants.screenHeight)
                #endif
        }
        #if os(macOS)
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)
        #endif
    }
}

// ================================================
// ENDE DES PROGRAMMS
// ================================================
//
// KOMPILIERUNG UND AUSFÜHRUNG:
//
// === Xcode (macOS/iOS) ===
// 1. Öffne Xcode
// 2. File → New → Project
// 3. Wähle "iOS App" oder "macOS App"
// 4. Interface: SwiftUI
// 5. Ersetze ContentView.swift mit diesem Code
// 6. Cmd+R zum Ausführen
//
// === Swift Package Manager ===
// 1. Erstelle Package.swift:
//    swift package init --type executable
// 2. Füge Dependencies hinzu (keine benötigt!)
// 3. swift run
//
// === Kommandozeile (nur macOS Playground) ===
// swiftc snake_swift.swift -o snake_swift
// ./snake_swift
//
// HINWEISE:
// - Benötigt: macOS 11+ oder iOS 14+
// - SpriteKit ist Teil von Foundation (keine externe Dependency!)
// - Läuft nativ auf Apple Silicon (M1/M2/M3)
// - Kann zu iOS/iPadOS/tvOS kompiliert werden
// - Für beep.wav Sound: Asset Catalog hinzufügen oder entfernen
//
// PLATTFORM-SPEZIFISCH:
// - macOS: Pfeiltasten + SPACE + ESC
// - iOS: Swipe-Gesten + Touch zum Neustart
// ================================================

