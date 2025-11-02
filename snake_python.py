# ================================================
# SNAKE SPIEL - Python / Pygame
# ================================================
# ZWECK: Klassisches Snake-Spiel als Blueprint
#        für verschiedene Programmiersprachen
#
# STEUERUNG:
#   - Pfeiltasten: Schlange lenken
#   - SPACE: Neustart nach Game Over
#   - ESC: Beenden
#
# SPIELMECHANIK:
#   - Schlange frisst Futter und wächst
#   - Punkte: 10 pro Futter
#   - Game Over: Wandkollision oder Selbstkollision
# ================================================

import pygame
import random
import sys
from enum import Enum
import numpy as np  # Für Sound-Generierung

# ================================================
# 1. PYGAME INITIALISIERUNG
# ================================================
pygame.init()

# ================================================
# 2. KONSTANTEN DEFINIEREN
# ================================================
# Spielfeld-Dimensionen
SCREEN_WIDTH = 640
SCREEN_HEIGHT = 480
GRID_SIZE = 20  # Größe jedes Gitter-Quadrats (Pixel)
BORDER_OFFSET = 10  # Abstand vom Bildschirmrand
MAX_SNAKE_LENGTH = 500  # Maximale Schlangenlänge

# Spielgeschwindigkeit
GAME_FPS = 8  # Frames per Second (klassisches Tempo)

# Spielfeldbegrenzungen
PLAYFIELD_LEFT = BORDER_OFFSET + 10
PLAYFIELD_RIGHT = SCREEN_WIDTH - 20
PLAYFIELD_TOP = BORDER_OFFSET + 10
PLAYFIELD_BOTTOM = SCREEN_HEIGHT - 20

# Farben (RGB Format)
COLOR_WHITE = (255, 255, 255)
COLOR_BLACK = (0, 0, 0)
COLOR_GREEN = (0, 255, 0)


# ================================================
# 3. RICHTUNGS-ENUM
# ================================================
class Direction(Enum):
    """Mögliche Richtungen für die Schlange"""
    UP = (0, -GRID_SIZE)
    DOWN = (0, GRID_SIZE)
    LEFT = (-GRID_SIZE, 0)
    RIGHT = (GRID_SIZE, 0)


# ================================================
# 4. GAME-STATE-KLASSE
# ================================================
class GameState:
    """Verwaltet den kompletten Spiel-State"""

    def __init__(self):
        """Initialisiere das Spiel"""
        self.reset_game()

    def reset_game(self):
        """Setze das Spiel auf Anfangszustand zurück"""
        # Schlangen-Array: Position jedes Segmentes
        self.snake_x = [0] * MAX_SNAKE_LENGTH
        self.snake_y = [0] * MAX_SNAKE_LENGTH

        # Startposition: Mitte des Bildschirms
        self.snake_x[0] = 320
        self.snake_y[0] = 240

        # Bewegungsrichtung (in Pixel pro Frame)
        self.dir_x, self.dir_y = GRID_SIZE, 0

        # Spiel-State
        self.length = 5  # Aktuelle Schlangenlänge
        self.score = 0  # Aktuelle Punktzahl
        self.game_over = False  # Spielstatus

        # Erste Schlangensegmente (dahinter): Körper nach links
        for i in range(1, 5):
            self.snake_x[i] = self.snake_x[0] - i * GRID_SIZE
            self.snake_y[i] = self.snake_y[0]

        # Erstes Futter platzieren
        self.food_x, self.food_y = self.place_food()

    def place_food(self):
        """
        Platziere neues Futter an zufälliger Position
        - nicht auf Schlange
        - innerhalb des Spielfelds
        """
        while True:
            # Zufällige Position im Gitter (20x20 Pixel pro Gitter-Zelle)
            food_x = int(random.random() * 29) * GRID_SIZE + 40
            food_y = int(random.random() * 21) * GRID_SIZE + 40

            # Prüfen ob Futter nicht auf Schlangen-Segment liegt
            is_on_snake = False
            for i in range(self.length):
                if food_x == self.snake_x[i] and food_y == self.snake_y[i]:
                    is_on_snake = True
                    break

            if not is_on_snake:
                return food_x, food_y

    def handle_input(self, keys):
        """
        Verarbeite Tasteneingaben
        - Pfeiltasten zum Lenken
        - Nur wenn nicht entgegengesetzt zu aktueller Richtung
        """
        # Pfeil OBEN
        if keys[pygame.K_UP] and self.dir_y == 0:
            self.dir_x, self.dir_y = 0, -GRID_SIZE
        # Pfeil UNTEN
        elif keys[pygame.K_DOWN] and self.dir_y == 0:
            self.dir_x, self.dir_y = 0, GRID_SIZE
        # Pfeil LINKS
        elif keys[pygame.K_LEFT] and self.dir_x == 0:
            self.dir_x, self.dir_y = -GRID_SIZE, 0
        # Pfeil RECHTS
        elif keys[pygame.K_RIGHT] and self.dir_x == 0:
            self.dir_x, self.dir_y = GRID_SIZE, 0

    def update(self):
        """
        Aktualisiere den Spiel-State für einen Frame
        """
        if self.game_over:
            return

        # --- 5c. SCHLANGE BEWEGEN ---
        # Body-Segmente nachfolgen (von hinten nach vorne schieben)
        for i in range(self.length - 1, 0, -1):
            self.snake_x[i] = self.snake_x[i - 1]
            self.snake_y[i] = self.snake_y[i - 1]

        # Kopf bewegen in aktuelle Richtung
        self.snake_x[0] += self.dir_x
        self.snake_y[0] += self.dir_y

        # --- 5d. KOLLISIONEN PRÜFEN ---

        # Wandkollision
        if (
            self.snake_x[0] < PLAYFIELD_LEFT
            or self.snake_x[0] >= PLAYFIELD_RIGHT
            or self.snake_y[0] < PLAYFIELD_TOP
            or self.snake_y[0] >= PLAYFIELD_BOTTOM
        ):
            self.game_over = True

        # Selbstkollision (Kopf trifft Body)
        for i in range(1, self.length):
            if (
                self.snake_x[0] == self.snake_x[i]
                and self.snake_y[0] == self.snake_y[i]
            ):
                self.game_over = True

        # --- 5e. FUTTER-LOGIK ---
        # Prüfe ob Kopf das Futter frisst
        if self.snake_x[0] == self.food_x and self.snake_y[0] == self.food_y:
            self.length += 1  # Schlange wächst um 1
            self.score += 10  # 10 Punkte
            self.food_x, self.food_y = self.place_food()  # Neues Futter
            # Audio-Feedback
            beep_array = create_beep_sound(800, 0.1)
            sound = pygame.sndarray.make_sound(beep_array)
            sound.play()


# ================================================
# 5. GRAFIK-RENDERING
# ================================================
class Renderer:
    """Verwaltet alle Grafik-Ausgabe"""

    def __init__(self, screen):
        self.screen = screen
        self.font = pygame.font.Font(None, 36)
        self.clock = pygame.time.Clock()

    def draw_game(self, game_state):
        """Zeichne den aktuellen Spiel-State"""
        # Bildschirm löschen (schwarz)
        self.screen.fill(COLOR_BLACK)

        # --- 5f. GRAFIK ZEICHNEN ---

        # Spielfeld-Rand zeichnen (Rechteck)
        pygame.draw.rect(
            self.screen,
            COLOR_WHITE,
            (
                BORDER_OFFSET,
                BORDER_OFFSET,
                SCREEN_WIDTH - 2 * BORDER_OFFSET,
                SCREEN_HEIGHT - 2 * BORDER_OFFSET,
            ),
            2,
        )

        # Futter zeichnen (weißes Quadrat)
        # Größe: 16x16 Pixel (±8 vom Mittelpunkt)
        pygame.draw.rect(
            self.screen,
            COLOR_WHITE,
            (
                game_state.food_x - 8,
                game_state.food_y - 8,
                16,
                16,
            ),
        )

        # Schlange zeichnen (weiße Quadrate für jedes Segment)
        for i in range(game_state.length):
            pygame.draw.rect(
                self.screen,
                COLOR_WHITE,
                (
                    game_state.snake_x[i] - 8,
                    game_state.snake_y[i] - 8,
                    16,
                    16,
                ),
            )

        # --- 5g. HUD (HEAD-UP-DISPLAY) ---
        hud_text = f"SCORE: {game_state.score}  LAENGE: {game_state.length}"
        text_surface = self.font.render(hud_text, True, COLOR_WHITE)
        self.screen.blit(text_surface, (10, 10))

        # --- 5h. GAME OVER BEHANDLUNG ---
        if game_state.game_over:
            self.draw_game_over(game_state)

        pygame.display.flip()

    def draw_game_over(self, game_state):
        """Zeichne Game Over Screen"""
        # Semi-transparent overlay
        overlay = pygame.Surface((SCREEN_WIDTH, SCREEN_HEIGHT))
        overlay.set_alpha(200)
        overlay.fill(COLOR_BLACK)
        self.screen.blit(overlay, (0, 0))

        # Game Over Text
        font_large = pygame.font.Font(None, 60)
        game_over_text = font_large.render("*** GAME OVER ***", True, COLOR_WHITE)
        self.screen.blit(
            game_over_text,
            (
                SCREEN_WIDTH // 2 - game_over_text.get_width() // 2,
                SCREEN_HEIGHT // 2 - 100,
            ),
        )

        # Final Score
        score_text = self.font.render(
            f"FINAL SCORE: {game_state.score}", True, COLOR_WHITE
        )
        self.screen.blit(
            score_text,
            (
                SCREEN_WIDTH // 2 - score_text.get_width() // 2,
                SCREEN_HEIGHT // 2,
            ),
        )

        # Instructions
        instructions_text = self.font.render(
            "Druecke SPACE fuer Neustart oder ESC zum Beenden", True, COLOR_WHITE
        )
        self.screen.blit(
            instructions_text,
            (
                SCREEN_WIDTH // 2 - instructions_text.get_width() // 2,
                SCREEN_HEIGHT // 2 + 80,
            ),
        )

    def limit_fps(self):
        """Begrenze die Frames pro Sekunde"""
        self.clock.tick(GAME_FPS)


# ================================================
# HELPER-FUNKTIONEN
# ================================================
def create_beep_sound(frequency, duration):
    """
    Erstelle ein Numpy-Array für einen einfachen Beep-Sound
    - frequency: Hz (z.B. 800)
    - duration: Sekunden (z.B. 0.1)
    """
    sample_rate = 44100  # Standard Audio-Sample-Rate
    t = np.linspace(0, duration, int(sample_rate * duration), False)
    wave = np.sin(2 * np.pi * frequency * t)
    audio = (wave * 32767).astype(np.int16)
    stereo = np.column_stack((audio, audio))  # Stereo (links/rechts gleich)
    return stereo


# ================================================
# 6. HAUPTSPIEL-SCHLEIFE
# ================================================
def main():
    """Hauptprogramm - Spiel-Schleife"""
    # Display erstellen
    screen = pygame.display.set_mode((SCREEN_WIDTH, SCREEN_HEIGHT))
    pygame.display.set_caption("SNAKE - Klassisch")

    # Komponenten initialisieren
    game_state = GameState()
    renderer = Renderer(screen)

    # Hauptspiel-Schleife
    running = True
    while running:
        # --- 5b. EINGABE VERARBEITEN ---
        for event in pygame.event.get():
            if event.type == pygame.QUIT:
                running = False
            elif event.type == pygame.KEYDOWN:
                if event.key == pygame.K_ESCAPE:
                    if game_state.game_over:
                        running = False
                    else:
                        game_state.game_over = True
                elif event.key == pygame.K_SPACE:
                    if game_state.game_over:
                        game_state.reset_game()

        # Handle continuous key presses
        keys = pygame.key.get_pressed()
        game_state.handle_input(keys)

        # --- 5c. GAME-STATE AKTUALISIEREN ---
        game_state.update()

        # --- 5f. GRAFIK ZEICHNEN ---
        renderer.draw_game(game_state)

        # --- GESCHWINDIGKEIT KONTROLLIEREN ---
        renderer.limit_fps()

    pygame.quit()
    sys.exit()


# ================================================
# 7. PROGRAMM STARTEN
# ================================================
if __name__ == "__main__":
    main()
