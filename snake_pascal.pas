{
================================================
 SNAKE SPIEL - Turbo Pascal Style
================================================
 ZWECK: Klassisches Snake-Spiel als 1:1-Übersetzung
        des GW-BASIC Blueprints.

 STEUERUNG:
   - Pfeiltasten: Schlange lenken
   - SPACE: Neustart nach Game Over
   - ESC: Beenden
================================================
}

PROGRAM SnakePascal;

USES Crt, Graph;

// ================================================
// 1. KONSTANTEN DEFINIEREN
//    (Direkt aus dem BASIC-Blueprint übernommen)
// ================================================
CONST
  SCREEN_WIDTH = 640;
  SCREEN_HEIGHT = 480;
  GRID_SIZE = 20;
  BORDER_OFFSET = 10;
  MAX_SNAKE_LENGTH = 500;
  GAME_FPS = 8;

  PLAYFIELD_LEFT = BORDER_OFFSET;
  PLAYFIELD_RIGHT = SCREEN_WIDTH - BORDER_OFFSET;
  PLAYFIELD_TOP = BORDER_OFFSET;
  PLAYFIELD_BOTTOM = SCREEN_HEIGHT - BORDER_OFFSET;

  // BGI Farbkonstanten (Standard-Palette)
  COLOR_BG = Black;
  COLOR_FG = White;
  COLOR_FOOD = Green;

// ================================================
// 2. TYPEN & VARIABLEN INITIALISIEREN
// ================================================
TYPE
  TSnakeArray = ARRAY[0..MAX_SNAKE_LENGTH] OF Integer;

VAR
  // Grafiktreiber und -modus
  gd, gm: Integer;

  // Schlangen-Array
  snakeX, snakeY: TSnakeArray;

  // Bewegungsrichtung
  dirX, dirY: Integer;

  // Spiel-State
  length: Integer;
  foodX, foodY: Integer;
  score: Integer;
  gameOver: Boolean;

  // Input & Schleifen
  k: Char;
  i: Integer;

// ================================================
// 3. SPIEL-INITIALISIERUNG (Platzhalter)
// ================================================
// Forward-Deklaration, damit InitializeGame sie aufrufen kann
PROCEDURE PlaceFood;

// ================================================
// 3. SPIEL-INITIALISIERUNG
//    (Übersetzung von BASIC-Abschnitt 4)
// ================================================
PROCEDURE InitializeGame;
BEGIN
  // Zufallsgenerator initialisieren
  Randomize;

  // Startposition: Mitte des Bildschirms
  snakeX[0] := SCREEN_WIDTH DIV 2;
  snakeY[0] := SCREEN_HEIGHT DIV 2;

  // Startrichtung: Nach rechts
  dirX := GRID_SIZE;
  dirY := 0;

  // Startwerte
  length := 5;
  score := 0;
  gameOver := False;

  // Erste Schlangensegmente initialisieren
  FOR i := 1 TO 4 DO
  BEGIN
    snakeX[i] := snakeX[0] - i * GRID_SIZE;
    snakeY[i] := snakeY[0];
  END;

  // Erstes Futter platzieren
  PlaceFood;
END;

// ================================================
// 4. SUBROUTINE: FUTTER PLATZIEREN
//    (Übersetzung von BASIC-Abschnitt 6)
// ================================================
PROCEDURE PlaceFood;
VAR
  onSnake: Boolean;
BEGIN
  REPEAT
    // Zufällige Position im Gitter generieren
    // Random(N) gibt eine Zahl von 0 bis N-1 zurück
    foodX := (Random(SCREEN_WIDTH DIV GRID_SIZE - 2) + 1) * GRID_SIZE;
    foodY := (Random(SCREEN_HEIGHT DIV GRID_SIZE - 2) + 1) * GRID_SIZE;

    // Prüfen, ob die Futter-Position auf der Schlange liegt
    onSnake := False;
    FOR i := 0 TO length - 1 DO
    BEGIN
      IF (foodX = snakeX[i]) AND (foodY = snakeY[i]) THEN
      BEGIN
        onSnake := True;
        BREAK; // Verlässt die FOR-Schleife
      END;
    END;

  UNTIL NOT onSnake; // Wiederholen, bis eine freie Position gefunden wurde
END;

// ================================================
// 4. HAUPTSPIEL-SCHLEIFE (Platzhalter)
// ================================================
BEGIN
  // Grafikmodus initialisieren
  gd := Detect;
  InitGraph(gd, gm, '');

  // Spiel initialisieren
  InitializeGame;

  // Hauptschleife (Übersetzung von BASIC-Abschnitt 5)
  REPEAT
    // --- 5a. GESCHWINDIGKEIT KONTROLLIEREN ---
    Delay(1000 DIV GAME_FPS);

    // --- 5b. EINGABE VERARBEITEN ---
    IF KeyPressed THEN
    BEGIN
      k := ReadKey;
      // Pfeiltasten abfragen (ReadKey gibt bei Pfeiltasten #0, dann den Scan-Code)
      IF k = #0 THEN
      BEGIN
        k := ReadKey; // Echten Scan-Code lesen
        CASE k OF
          #72: IF dirY = 0 THEN BEGIN dirX := 0; dirY := -GRID_SIZE; END; // Oben
          #80: IF dirY = 0 THEN BEGIN dirX := 0; dirY := GRID_SIZE;  END; // Unten
          #75: IF dirX = 0 THEN BEGIN dirX := -GRID_SIZE; dirY := 0; END; // Links
          #77: IF dirX = 0 THEN BEGIN dirX := GRID_SIZE; dirY := 0;  END; // Rechts
        END;
      END
      ELSE IF k = #27 THEN // ESC
      BEGIN
        gameOver := True;
      END;
    END;

    // --- 5c. SCHLANGE BEWEGEN ---
    // Körpersegmente nachziehen (von hinten nach vorne)
    FOR i := length - 1 DOWNTO 1 DO
    BEGIN
      snakeX[i] := snakeX[i-1];
      snakeY[i] := snakeY[i-1];
    END;

    // Kopf in die aktuelle Richtung bewegen
    snakeX[0] := snakeX[0] + dirX;
    snakeY[0] := snakeY[0] + dirY;

    // --- 5d. KOLLISIONEN PRÜFEN ---
    // Wandkollision
    IF (snakeX[0] < PLAYFIELD_LEFT) OR (snakeX[0] >= PLAYFIELD_RIGHT) OR
       (snakeY[0] < PLAYFIELD_TOP) OR (snakeY[0] >= PLAYFIELD_BOTTOM) THEN
    BEGIN
      gameOver := True;
    END;

    // Selbstkollision (Kopf trifft Körper)
    FOR i := 1 TO length - 1 DO
    BEGIN
      IF (snakeX[0] = snakeX[i]) AND (snakeY[0] = snakeY[i]) THEN
      BEGIN
        gameOver := True;
        BREAK;
      END;
    END;

    // --- 5e. FUTTER-LOGIK ---
    IF (snakeX[0] = foodX) AND (snakeY[0] = foodY) THEN
    BEGIN
      length := length + 1;
      score := score + 10;
      PlaceFood;
      Sound(800); Delay(50); NoSound; // Kurzer Ton
    END;

    // --- 5f. GRAFIK ZEICHNEN ---
    // Bildschirm löschen
    SetFillStyle(SolidFill, COLOR_BG);
    Bar(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);

    // Spielfeld-Rand
    SetColor(COLOR_FG);
    Rectangle(PLAYFIELD_LEFT, PLAYFIELD_TOP, PLAYFIELD_RIGHT, PLAYFIELD_BOTTOM);

    // Futter
    SetFillStyle(SolidFill, COLOR_FOOD);
    Bar(foodX, foodY, foodX + GRID_SIZE, foodY + GRID_SIZE);

    // Schlange
    SetFillStyle(SolidFill, COLOR_FG);
    FOR i := 0 TO length - 1 DO
    BEGIN
      Bar(snakeX[i], snakeY[i], snakeX[i] + GRID_SIZE, snakeY[i] + GRID_SIZE);
    END;

    // --- 5g. HUD ANZEIGEN ---
    SetColor(COLOR_FG);
    OutTextXY(20, SCREEN_HEIGHT - 15, 'SCORE: ' + IntToStr(score) + '  LAENGE: ' + IntToStr(length));

    // --- 5h. GAME OVER BEHANDLUNG ---
    IF gameOver THEN
    BEGIN
      SetColor(Yellow);
      SetTextJustify(CenterText, CenterText);
      OutTextXY(SCREEN_WIDTH DIV 2, SCREEN_HEIGHT DIV 2 - 20, '*** GAME OVER ***');
      OutTextXY(SCREEN_WIDTH DIV 2, SCREEN_HEIGHT DIV 2, 'FINAL SCORE: ' + IntToStr(score));
      OutTextXY(SCREEN_WIDTH DIV 2, SCREEN_HEIGHT DIV 2 + 40, 'Druecke SPACE fuer Neustart oder ESC zum Beenden');
      SetTextJustify(LeftText, TopText);

      // Warten auf Input
      REPEAT
        k := ReadKey;
        IF k = ' ' THEN // Neustart
        BEGIN
          InitializeGame;
          gameOver := False; // Zurück zum Spiel
        END
        ELSE IF k = #27 THEN // Beenden
        BEGIN
          // Die äußere Schleife wird durch gameOver=True beendet
        END;
      UNTIL (k = ' ') OR (k = #27);
    END;

  UNTIL gameOver AND (k = #27);

  // Grafikmodus beenden
  CloseGraph;
END.
