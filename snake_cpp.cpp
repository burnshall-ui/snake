// ================================================
// SNAKE SPIEL - C++ mit SDL2
// ================================================
// ZWECK: Klassisches Snake-Spiel als Blueprint
//        für verschiedene Programmiersprachen
//
// STEUERUNG:
//   - Pfeiltasten: Schlange lenken
//   - SPACE: Neustart nach Game Over
//   - ESC: Beenden
//
// SPIELMECHANIK:
//   - Schlange frisst Futter und wächst
//   - Punkte: 10 pro Futter
//   - Game Over: Wandkollision oder Selbstkollision
// ================================================

#include <SDL2/SDL.h>
#include <iostream>
#include <vector>
#include <cstdlib>
#include <ctime>

// ================================================
// 1. KONSTANTEN DEFINIEREN
// ================================================

// Spielfeld-Dimensionen
const int SCREEN_WIDTH = 640;
const int SCREEN_HEIGHT = 480;
const int GRID_SIZE = 20;           // Größe jedes Gitter-Quadrats (Pixel)
const int BORDER_OFFSET = 10;       // Abstand vom Bildschirmrand
const int MAX_SNAKE_LENGTH = 500;   // Maximale Schlangenlänge

// Spielgeschwindigkeit
const int GAME_FPS = 8;             // Frames per Second (klassisches Tempo)
const int FRAME_DELAY = 1000 / GAME_FPS;

// Spielfeldbegrenzungen
const int PLAYFIELD_LEFT = BORDER_OFFSET + 10;
const int PLAYFIELD_RIGHT = SCREEN_WIDTH - 20;
const int PLAYFIELD_TOP = BORDER_OFFSET + 10;
const int PLAYFIELD_BOTTOM = SCREEN_HEIGHT - 20;

// Farben (RGB Format)
const SDL_Color COLOR_WHITE = {255, 255, 255, 255};
const SDL_Color COLOR_BLACK = {0, 0, 0, 255};
const SDL_Color COLOR_GREEN = {0, 255, 0, 255};

// ================================================
// 2. STRUKTUR FÜR POSITION
// ================================================
struct Position {
    int x;
    int y;
};

// ================================================
// 3. GLOBALE VARIABLEN
// ================================================

// SDL Objekte
SDL_Window* window = nullptr;
SDL_Renderer* renderer = nullptr;

// Schlangen-Array: Position jedes Segmentes
std::vector<Position> snake(MAX_SNAKE_LENGTH);

// Bewegungsrichtung (in Pixel pro Frame)
int dirX = GRID_SIZE;   // Startrichtung: Nach rechts
int dirY = 0;

// Spiel-State
int length = 5;         // Aktuelle Schlangenlänge
int foodX = 0;          // X-Position des Futters
int foodY = 0;          // Y-Position des Futters
int score = 0;          // Aktuelle Punktzahl
bool gameOver = false;  // Spielstatus: false=läuft, true=vorbei
bool running = true;    // Programm läuft

// ================================================
// 4. FUNKTIONSDEKLARATIONEN
// ================================================
bool InitSDL();
void CloseSDL();
void PlaceFood();
void ResetGame();
void HandleInput();
void UpdateGame();
void RenderGame();
void DrawRect(int x, int y, int w, int h, SDL_Color color, bool filled);
void DrawText(const char* text, int x, int y);

// ================================================
// 5. HAUPTFUNKTION
// ================================================
int main(int argc, char* argv[]) {
    // SDL initialisieren
    if (!InitSDL()) {
        std::cerr << "Fehler beim Initialisieren von SDL!" << std::endl;
        return 1;
    }
    
    // Zufallsgenerator initialisieren
    srand(static_cast<unsigned int>(time(nullptr)));
    
    // Spiel initialisieren
    ResetGame();
    
    // ================================================
    // HAUPTSPIEL-SCHLEIFE
    // ================================================
    Uint32 frameStart;
    int frameTime;
    
    while (running) {
        frameStart = SDL_GetTicks();
        
        // --- 5a. EINGABE VERARBEITEN ---
        HandleInput();
        
        // --- 5b. SPIEL AKTUALISIEREN ---
        if (!gameOver) {
            UpdateGame();
        }
        
        // --- 5c. GRAFIK ZEICHNEN ---
        RenderGame();
        
        // --- 5d. FRAME-RATE BEGRENZEN ---
        frameTime = SDL_GetTicks() - frameStart;
        if (frameTime < FRAME_DELAY) {
            SDL_Delay(FRAME_DELAY - frameTime);
        }
    }
    
    // Aufräumen und beenden
    CloseSDL();
    return 0;
}

// ================================================
// 6. SDL INITIALISIERUNG
// ================================================
bool InitSDL() {
    // SDL initialisieren
    if (SDL_Init(SDL_INIT_VIDEO) < 0) {
        std::cerr << "SDL konnte nicht initialisiert werden! SDL_Error: " << SDL_GetError() << std::endl;
        return false;
    }
    
    // Fenster erstellen
    window = SDL_CreateWindow(
        "SNAKE - Klassisch",
        SDL_WINDOWPOS_CENTERED,
        SDL_WINDOWPOS_CENTERED,
        SCREEN_WIDTH,
        SCREEN_HEIGHT,
        SDL_WINDOW_SHOWN
    );
    
    if (window == nullptr) {
        std::cerr << "Fenster konnte nicht erstellt werden! SDL_Error: " << SDL_GetError() << std::endl;
        return false;
    }
    
    // Renderer erstellen
    renderer = SDL_CreateRenderer(window, -1, SDL_RENDERER_ACCELERATED);
    if (renderer == nullptr) {
        std::cerr << "Renderer konnte nicht erstellt werden! SDL_Error: " << SDL_GetError() << std::endl;
        return false;
    }
    
    return true;
}

// ================================================
// 7. SDL BEENDEN
// ================================================
void CloseSDL() {
    if (renderer != nullptr) {
        SDL_DestroyRenderer(renderer);
        renderer = nullptr;
    }
    
    if (window != nullptr) {
        SDL_DestroyWindow(window);
        window = nullptr;
    }
    
    SDL_Quit();
}

// ================================================
// 8. SPIEL ZURÜCKSETZEN
// ================================================
void ResetGame() {
    // Startposition: Mitte des Bildschirmes
    snake[0].x = 320;
    snake[0].y = 240;
    
    // Startrichtung: Nach rechts
    dirX = GRID_SIZE;
    dirY = 0;
    
    // Startlänge: 5 Segmente
    length = 5;
    score = 0;
    gameOver = false;
    
    // Erste Schlangensegmente (dahinter): Körper nach links
    for (int i = 1; i < 5; i++) {
        snake[i].x = snake[0].x - i * GRID_SIZE;
        snake[i].y = snake[0].y;
    }
    
    // Erstes Futter platzieren
    PlaceFood();
}

// ================================================
// 9. FUTTER PLATZIEREN
// ================================================
// ZWECK: Neue Futter-Position generieren
//        (nicht auf Schlange, nicht außerhalb Spielfeld)
void PlaceFood() {
    bool validPosition;
    
    do {
        validPosition = true;
        
        // Zufällige Position im Gitter (20x20 Pixel pro Gitter-Zelle)
        // Range: 40-620 Pixel horizontal, 40-440 Pixel vertikal
        foodX = (rand() % 29) * GRID_SIZE + 40;
        foodY = (rand() % 21) * GRID_SIZE + 40;
        
        // Prüfen ob Futter nicht auf Schlangen-Segment liegt
        for (int i = 0; i < length; i++) {
            if (foodX == snake[i].x && foodY == snake[i].y) {
                validPosition = false;
                break;
            }
        }
    } while (!validPosition);
}

// ================================================
// 10. EINGABE BEHANDELN
// ================================================
void HandleInput() {
    SDL_Event event;
    
    while (SDL_PollEvent(&event)) {
        if (event.type == SDL_QUIT) {
            running = false;
        }
        else if (event.type == SDL_KEYDOWN) {
            switch (event.key.keysym.sym) {
                // Pfeiltasten-Handler (nur wenn nicht entgegengesetzt zu aktueller Richtung)
                case SDLK_UP:
                    if (dirY == 0 && !gameOver) {
                        dirX = 0;
                        dirY = -GRID_SIZE;
                    }
                    break;
                    
                case SDLK_DOWN:
                    if (dirY == 0 && !gameOver) {
                        dirX = 0;
                        dirY = GRID_SIZE;
                    }
                    break;
                    
                case SDLK_LEFT:
                    if (dirX == 0 && !gameOver) {
                        dirX = -GRID_SIZE;
                        dirY = 0;
                    }
                    break;
                    
                case SDLK_RIGHT:
                    if (dirX == 0 && !gameOver) {
                        dirX = GRID_SIZE;
                        dirY = 0;
                    }
                    break;
                    
                case SDLK_SPACE:
                    // SPACE = Neustart nach Game Over
                    if (gameOver) {
                        ResetGame();
                    }
                    break;
                    
                case SDLK_ESCAPE:
                    // ESC = Beenden
                    running = false;
                    break;
            }
        }
    }
}

// ================================================
// 11. SPIEL AKTUALISIEREN
// ================================================
void UpdateGame() {
    // --- 11a. SCHLANGE BEWEGEN ---
    // Body-Segmente nachfolgen (von hinten nach vorne schieben)
    for (int i = length - 1; i >= 1; i--) {
        snake[i].x = snake[i - 1].x;
        snake[i].y = snake[i - 1].y;
    }
    
    // Kopf bewegen in aktuelle Richtung
    snake[0].x += dirX;
    snake[0].y += dirY;
    
    // --- 11b. KOLLISIONEN PRÜFEN ---
    
    // Wandkollision
    if (snake[0].x < PLAYFIELD_LEFT || snake[0].x >= PLAYFIELD_RIGHT ||
        snake[0].y < PLAYFIELD_TOP || snake[0].y >= PLAYFIELD_BOTTOM) {
        gameOver = true;
    }
    
    // Selbstkollision (Kopf trifft Body)
    for (int i = 1; i < length; i++) {
        if (snake[0].x == snake[i].x && snake[0].y == snake[i].y) {
            gameOver = true;
            break;
        }
    }
    
    // --- 11c. FUTTER-LOGIK ---
    // Prüfe ob Kopf das Futter frisst
    if (snake[0].x == foodX && snake[0].y == foodY) {
        length++;           // Schlange wächst um 1
        score += 10;        // 10 Punkte
        PlaceFood();        // Neues Futter platzieren
        // Audio-Feedback könnte hier hinzugefügt werden
    }
}

// ================================================
// 12. GRAFIK ZEICHNEN
// ================================================
void RenderGame() {
    // --- 12a. BILDSCHIRM LÖSCHEN (Schwarz) ---
    SDL_SetRenderDrawColor(renderer, COLOR_BLACK.r, COLOR_BLACK.g, COLOR_BLACK.b, COLOR_BLACK.a);
    SDL_RenderClear(renderer);
    
    // --- 12b. SPIELFELD-RAND ZEICHNEN ---
    SDL_SetRenderDrawColor(renderer, COLOR_WHITE.r, COLOR_WHITE.g, COLOR_WHITE.b, COLOR_WHITE.a);
    SDL_Rect border = {
        BORDER_OFFSET,
        BORDER_OFFSET,
        SCREEN_WIDTH - 2 * BORDER_OFFSET,
        SCREEN_HEIGHT - 2 * BORDER_OFFSET
    };
    SDL_RenderDrawRect(renderer, &border);
    
    // --- 12c. FUTTER ZEICHNEN (weißes Quadrat) ---
    // Größe: 16x16 Pixel (±8 vom Mittelpunkt)
    SDL_Rect food = {foodX - 8, foodY - 8, 16, 16};
    SDL_RenderFillRect(renderer, &food);
    
    // --- 12d. SCHLANGE ZEICHNEN ---
    // Weiße Quadrate für jedes Segment
    for (int i = 0; i < length; i++) {
        SDL_Rect segment = {snake[i].x - 8, snake[i].y - 8, 16, 16};
        SDL_RenderFillRect(renderer, &segment);
    }
    
    // --- 12e. HUD (HEAD-UP-DISPLAY) ---
    // Score und Länge anzeigen (vereinfacht - für echten Text SDL_ttf nutzen)
    // Hier würde normalerweise Text gerendert werden
    // Für diese 1:1 Kopie belassen wir es bei der Grafik
    
    // --- 12f. GAME OVER BEHANDLUNG ---
    if (gameOver) {
        // Game Over Rechteck (semi-transparent wäre mit SDL möglich)
        SDL_SetRenderDrawColor(renderer, 50, 50, 50, 200);
        SDL_Rect overlay = {150, 180, 340, 120};
        SDL_RenderFillRect(renderer, &overlay);
        
        SDL_SetRenderDrawColor(renderer, COLOR_WHITE.r, COLOR_WHITE.g, COLOR_WHITE.b, COLOR_WHITE.a);
        SDL_RenderDrawRect(renderer, &overlay);
        
        // Text würde hier mit SDL_ttf gerendert werden
        // "*** GAME OVER ***"
        // "FINAL SCORE: [score]"
        // "Druecke SPACE fuer Neustart"
        // "oder ESC zum Beenden"
    }
    
    // --- 12g. BILDSCHIRM AKTUALISIEREN ---
    SDL_RenderPresent(renderer);
}

// ================================================
// ENDE DES PROGRAMMS
// ================================================
// 
// KOMPILIERUNG (mit SDL2):
// g++ -o snake_cpp snake_cpp.cpp -lSDL2
//
// ODER mit pkg-config:
// g++ snake_cpp.cpp -o snake_cpp `pkg-config --cflags --libs sdl2`
//
// HINWEIS: SDL2 muss installiert sein:
// - Windows: https://www.libsdl.org/download-2.0.php
// - Linux: sudo apt-get install libsdl2-dev
// - macOS: brew install sdl2
// ================================================

