// ================================================
// SNAKE SPIEL - C# mit Windows Forms
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

using System;
using System.Collections.Generic;
using System.Drawing;
using System.Windows.Forms;

namespace SnakeGame
{
    // ================================================
    // 1. HAUPTPROGRAMM KLASSE
    // ================================================
    public class Program
    {
        [STAThread]
        static void Main()
        {
            Application.EnableVisualStyles();
            Application.SetCompatibleTextRenderingDefault(false);
            Application.Run(new SnakeGameForm());
        }
    }

    // ================================================
    // 2. STRUKTUR FÜR POSITION
    // ================================================
    public struct Position
    {
        public int X;
        public int Y;

        public Position(int x, int y)
        {
            X = x;
            Y = y;
        }
    }

    // ================================================
    // 3. HAUPT-FORM KLASSE
    // ================================================
    public class SnakeGameForm : Form
    {
        // ================================================
        // 3a. KONSTANTEN DEFINIEREN
        // ================================================
        
        // Spielfeld-Dimensionen
        private const int SCREEN_WIDTH = 640;
        private const int SCREEN_HEIGHT = 480;
        private const int GRID_SIZE = 20;           // Größe jedes Gitter-Quadrats (Pixel)
        private const int BORDER_OFFSET = 10;       // Abstand vom Bildschirmrand
        private const int MAX_SNAKE_LENGTH = 500;   // Maximale Schlangenlänge

        // Spielgeschwindigkeit
        private const int GAME_FPS = 8;             // Frames per Second (klassisches Tempo)
        private const int FRAME_DELAY = 1000 / GAME_FPS;

        // Spielfeldbegrenzungen
        private const int PLAYFIELD_LEFT = BORDER_OFFSET + 10;
        private const int PLAYFIELD_RIGHT = SCREEN_WIDTH - 20;
        private const int PLAYFIELD_TOP = BORDER_OFFSET + 10;
        private const int PLAYFIELD_BOTTOM = SCREEN_HEIGHT - 20;

        // ================================================
        // 3b. VARIABLEN INITIALISIEREN
        // ================================================
        
        // Schlangen-Array: Position jedes Segmentes
        private List<Position> snake;

        // Bewegungsrichtung (in Pixel pro Frame)
        private int dirX;   // -20, 0, oder +20
        private int dirY;   // -20, 0, oder +20

        // Spiel-State
        private int length;         // Aktuelle Schlangenlänge
        private int foodX;          // X-Position des Futters
        private int foodY;          // Y-Position des Futters
        private int score;          // Aktuelle Punktzahl
        private bool gameOver;      // Spielstatus: false=läuft, true=vorbei

        // Timer für Spielschleife
        private Timer gameTimer;

        // Zufallsgenerator
        private Random random;

        // Grafik-Objekte
        private Brush whiteBrush;
        private Brush blackBrush;
        private Pen whitePen;
        private Font gameFont;
        private Font titleFont;

        // ================================================
        // 4. KONSTRUKTOR
        // ================================================
        public SnakeGameForm()
        {
            // Fenster-Eigenschaften
            this.Text = "SNAKE - Klassisch";
            this.ClientSize = new Size(SCREEN_WIDTH, SCREEN_HEIGHT);
            this.FormBorderStyle = FormBorderStyle.FixedSingle;
            this.MaximizeBox = false;
            this.StartPosition = FormStartPosition.CenterScreen;
            this.DoubleBuffered = true;  // Flicker-freies Zeichnen
            this.BackColor = Color.Black;

            // Event-Handler
            this.Paint += new PaintEventHandler(OnPaint);
            this.KeyDown += new KeyEventHandler(OnKeyDown);

            // Grafik-Objekte initialisieren
            whiteBrush = new SolidBrush(Color.White);
            blackBrush = new SolidBrush(Color.Black);
            whitePen = new Pen(Color.White, 2);
            gameFont = new Font("Courier New", 12, FontStyle.Bold);
            titleFont = new Font("Courier New", 16, FontStyle.Bold);

            // Zufallsgenerator
            random = new Random();

            // Schlangen-Liste initialisieren
            snake = new List<Position>(MAX_SNAKE_LENGTH);
            for (int i = 0; i < MAX_SNAKE_LENGTH; i++)
            {
                snake.Add(new Position(0, 0));
            }

            // Timer initialisieren
            gameTimer = new Timer();
            gameTimer.Interval = FRAME_DELAY;
            gameTimer.Tick += new EventHandler(GameLoop);

            // Spiel initialisieren
            ResetGame();

            // Timer starten
            gameTimer.Start();
        }

        // ================================================
        // 5. SPIEL ZURÜCKSETZEN
        // ================================================
        private void ResetGame()
        {
            // Startposition: Mitte des Bildschirmes
            snake[0] = new Position(320, 240);

            // Startrichtung: Nach rechts
            dirX = GRID_SIZE;
            dirY = 0;

            // Startlänge: 5 Segmente
            length = 5;
            score = 0;
            gameOver = false;

            // Erste Schlangensegmente (dahinter): Körper nach links
            for (int i = 1; i < 5; i++)
            {
                snake[i] = new Position(snake[0].X - i * GRID_SIZE, snake[0].Y);
            }

            // Erstes Futter platzieren
            PlaceFood();
        }

        // ================================================
        // 6. FUTTER PLATZIEREN
        // ================================================
        // ZWECK: Neue Futter-Position generieren
        //        (nicht auf Schlange, nicht außerhalb Spielfeld)
        private void PlaceFood()
        {
            bool validPosition;

            do
            {
                validPosition = true;

                // Zufällige Position im Gitter (20x20 Pixel pro Gitter-Zelle)
                // Range: 40-620 Pixel horizontal, 40-440 Pixel vertikal
                foodX = random.Next(29) * GRID_SIZE + 40;
                foodY = random.Next(21) * GRID_SIZE + 40;

                // Prüfen ob Futter nicht auf Schlangen-Segment liegt
                for (int i = 0; i < length; i++)
                {
                    if (foodX == snake[i].X && foodY == snake[i].Y)
                    {
                        validPosition = false;
                        break;
                    }
                }
            } while (!validPosition);
        }

        // ================================================
        // 7. EINGABE BEHANDELN
        // ================================================
        private void OnKeyDown(object sender, KeyEventArgs e)
        {
            // Pfeiltasten-Handler (nur wenn nicht entgegengesetzt zu aktueller Richtung)
            switch (e.KeyCode)
            {
                case Keys.Up:
                    if (dirY == 0 && !gameOver)
                    {
                        dirX = 0;
                        dirY = -GRID_SIZE;
                    }
                    break;

                case Keys.Down:
                    if (dirY == 0 && !gameOver)
                    {
                        dirX = 0;
                        dirY = GRID_SIZE;
                    }
                    break;

                case Keys.Left:
                    if (dirX == 0 && !gameOver)
                    {
                        dirX = -GRID_SIZE;
                        dirY = 0;
                    }
                    break;

                case Keys.Right:
                    if (dirX == 0 && !gameOver)
                    {
                        dirX = GRID_SIZE;
                        dirY = 0;
                    }
                    break;

                case Keys.Space:
                    // SPACE = Neustart nach Game Over
                    if (gameOver)
                    {
                        ResetGame();
                    }
                    break;

                case Keys.Escape:
                    // ESC = Beenden
                    Application.Exit();
                    break;
            }
        }

        // ================================================
        // 8. HAUPTSPIEL-SCHLEIFE (Timer Tick)
        // ================================================
        private void GameLoop(object sender, EventArgs e)
        {
            if (!gameOver)
            {
                UpdateGame();
            }
            
            // Bildschirm neu zeichnen
            Invalidate();
        }

        // ================================================
        // 9. SPIEL AKTUALISIEREN
        // ================================================
        private void UpdateGame()
        {
            // --- 9a. SCHLANGE BEWEGEN ---
            // Body-Segmente nachfolgen (von hinten nach vorne schieben)
            for (int i = length - 1; i >= 1; i--)
            {
                snake[i] = snake[i - 1];
            }

            // Kopf bewegen in aktuelle Richtung
            Position head = snake[0];
            head.X += dirX;
            head.Y += dirY;
            snake[0] = head;

            // --- 9b. KOLLISIONEN PRÜFEN ---

            // Wandkollision
            if (snake[0].X < PLAYFIELD_LEFT || snake[0].X >= PLAYFIELD_RIGHT ||
                snake[0].Y < PLAYFIELD_TOP || snake[0].Y >= PLAYFIELD_BOTTOM)
            {
                gameOver = true;
                System.Media.SystemSounds.Beep.Play();
            }

            // Selbstkollision (Kopf trifft Body)
            for (int i = 1; i < length; i++)
            {
                if (snake[0].X == snake[i].X && snake[0].Y == snake[i].Y)
                {
                    gameOver = true;
                    System.Media.SystemSounds.Beep.Play();
                    break;
                }
            }

            // --- 9c. FUTTER-LOGIK ---
            // Prüfe ob Kopf das Futter frisst
            if (snake[0].X == foodX && snake[0].Y == foodY)
            {
                length++;           // Schlange wächst um 1
                score += 10;        // 10 Punkte
                PlaceFood();        // Neues Futter platzieren
                
                // Audio-Feedback (800Hz, 0.5 Sekunden würde mit System.Media.SoundPlayer gehen)
                System.Media.SystemSounds.Asterisk.Play();
            }
        }

        // ================================================
        // 10. GRAFIK ZEICHNEN
        // ================================================
        private void OnPaint(object sender, PaintEventArgs e)
        {
            Graphics g = e.Graphics;
            g.SmoothingMode = System.Drawing.Drawing2D.SmoothingMode.None; // Pixel-perfekt

            // --- 10a. HINTERGRUND (bereits schwarz) ---
            
            // --- 10b. SPIELFELD-RAND ZEICHNEN ---
            Rectangle border = new Rectangle(
                BORDER_OFFSET,
                BORDER_OFFSET,
                SCREEN_WIDTH - 2 * BORDER_OFFSET,
                SCREEN_HEIGHT - 2 * BORDER_OFFSET
            );
            g.DrawRectangle(whitePen, border);

            // --- 10c. FUTTER ZEICHNEN (weißes Quadrat) ---
            // Größe: 16x16 Pixel (±8 vom Mittelpunkt)
            g.FillRectangle(whiteBrush, foodX - 8, foodY - 8, 16, 16);

            // --- 10d. SCHLANGE ZEICHNEN ---
            // Weiße Quadrate für jedes Segment
            for (int i = 0; i < length; i++)
            {
                g.FillRectangle(whiteBrush, snake[i].X - 8, snake[i].Y - 8, 16, 16);
            }

            // --- 10e. HUD (HEAD-UP-DISPLAY) ---
            // Score und Länge in oberer linker Ecke
            string hudText = $"SCORE: {score}  LAENGE: {length}";
            g.DrawString(hudText, gameFont, whiteBrush, 20, 5);

            // --- 10f. GAME OVER BEHANDLUNG ---
            if (gameOver)
            {
                // Halbtransparentes Overlay (simuliert)
                using (SolidBrush grayBrush = new SolidBrush(Color.FromArgb(200, 50, 50, 50)))
                {
                    g.FillRectangle(grayBrush, 120, 150, 400, 180);
                }
                
                g.DrawRectangle(whitePen, 120, 150, 400, 180);

                // Game Over Text
                string gameOverText = "*** GAME OVER ***";
                SizeF textSize = g.MeasureString(gameOverText, titleFont);
                g.DrawString(
                    gameOverText, 
                    titleFont, 
                    whiteBrush, 
                    (SCREEN_WIDTH - textSize.Width) / 2, 
                    170
                );

                // Final Score
                string scoreText = $"FINAL SCORE: {score}";
                textSize = g.MeasureString(scoreText, gameFont);
                g.DrawString(
                    scoreText, 
                    gameFont, 
                    whiteBrush, 
                    (SCREEN_WIDTH - textSize.Width) / 2, 
                    210
                );

                // Anweisungen
                string restartText = "Druecke SPACE fuer Neustart";
                textSize = g.MeasureString(restartText, gameFont);
                g.DrawString(
                    restartText, 
                    gameFont, 
                    whiteBrush, 
                    (SCREEN_WIDTH - textSize.Width) / 2, 
                    250
                );

                string exitText = "oder ESC zum Beenden";
                textSize = g.MeasureString(exitText, gameFont);
                g.DrawString(
                    exitText, 
                    gameFont, 
                    whiteBrush, 
                    (SCREEN_WIDTH - textSize.Width) / 2, 
                    280
                );
            }
        }

        // ================================================
        // 11. AUFRÄUMEN
        // ================================================
        protected override void Dispose(bool disposing)
        {
            if (disposing)
            {
                gameTimer?.Stop();
                gameTimer?.Dispose();
                whiteBrush?.Dispose();
                blackBrush?.Dispose();
                whitePen?.Dispose();
                gameFont?.Dispose();
                titleFont?.Dispose();
            }
            base.Dispose(disposing);
        }
    }
}

// ================================================
// ENDE DES PROGRAMMS
// ================================================
// 
// KOMPILIERUNG UND AUSFÜHRUNG:
// 
// Option 1 - Mit .NET Framework (Windows):
// csc /target:winexe snake_csharp.cs
//
// Option 2 - Mit .NET Core / .NET 5+ (Cross-Platform):
// 1. Erstelle eine .csproj Datei:
//    dotnet new winforms -n SnakeGame
// 2. Ersetze Program.cs mit diesem Code
// 3. dotnet run
//
// Option 3 - Visual Studio:
// 1. Neues Windows Forms Projekt erstellen
// 2. Code einfügen
// 3. F5 drücken
//
// HINWEISE:
// - Benötigt Windows Forms (.NET Framework oder .NET Core 3.1+)
// - Läuft nur auf Windows (Forms) oder mit Mono
// - Für Cross-Platform: MonoGame oder Unity verwenden
// ================================================

