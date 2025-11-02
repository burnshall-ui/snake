' ================================================
' SNAKE SPIEL - GW-BASIC Style / QB64
' ================================================
' ZWECK: Klassisches Snake-Spiel als Blueprint
'        für verschiedene Programmiersprachen
'
' STEUERUNG:
'   - Pfeiltasten: Schlange lenken
'   - SPACE: Neustart nach Game Over
'   - ESC: Beenden
'
' SPIELMECHANIK:
'   - Schlange frisst Futter und wächst
'   - Punkte: 10 pro Futter
'   - Game Over: Wandkollision oder Selbstkollision
' ================================================

' ================================================
' 1. DISPLAY-KONFIGURATION
' ================================================
SCREEN _NEWIMAGE(640, 480, 32)  ' 640x480 Fenster, 32-Bit Farbe
_TITLE "SNAKE - Klassisch"       ' Fenster-Titel
_SCREENMOVE _MIDDLE              ' Fenster zentrieren

' ================================================
' 2. KONSTANTEN DEFINIEREN
' ================================================
' Spielfeld-Dimensionen
CONST SCREEN_WIDTH = 640
CONST SCREEN_HEIGHT = 480
CONST GRID_SIZE = 20             ' Größe jedes Gitter-Quadrats (Pixel)
CONST BORDER_OFFSET = 10         ' Abstand vom Bildschirmrand
CONST MAX_SNAKE_LENGTH = 500     ' Maximale Schlangenlänge

' Spielgeschwindigkeit
CONST GAME_FPS = 8               ' Frames per Second (klassisches Tempo)

' Spielfeldbegrenzungen
CONST PLAYFIELD_LEFT = BORDER_OFFSET + 10
CONST PLAYFIELD_RIGHT = SCREEN_WIDTH - 20
CONST PLAYFIELD_TOP = BORDER_OFFSET + 10
CONST PLAYFIELD_BOTTOM = SCREEN_HEIGHT - 20

' Farben (RGB32 Format)
CONST COLOR_WHITE = _RGB32(255, 255, 255)
CONST COLOR_BLACK = _RGB32(0, 0, 0)
CONST COLOR_GREEN = _RGB32(0, 255, 0)

' ================================================
' 3. VARIABLEN INITIALISIEREN
' ================================================

' Schlangen-Array: Position jedes Segmentes
DIM snakeX(MAX_SNAKE_LENGTH) AS INTEGER
DIM snakeY(MAX_SNAKE_LENGTH) AS INTEGER

' Bewegungsrichtung (in Pixel pro Frame)
DIM dirX AS INTEGER  ' -20, 0, oder +20
DIM dirY AS INTEGER  ' -20, 0, oder +20

' Spiel-State
DIM length AS INTEGER      ' Aktuelle Schlangenlänge
DIM foodX AS INTEGER       ' X-Position des Futters
DIM foodY AS INTEGER       ' Y-Position des Futters
DIM score AS INTEGER       ' Aktuelle Punktzahl
DIM gameOver AS INTEGER    ' Spielstatus: 0=läuft, 1=vorbei

' Input
DIM k$ AS STRING           ' Letzter Tastendruck

' Schleifenzähler
DIM i AS INTEGER

' ================================================
' 4. SPIEL INITIALISIEREN
' ================================================

' Startposition: Mitte des Bildschirmes
snakeX(0) = 320
snakeY(0) = 240

' Startrichtung: Nach rechts
dirX = GRID_SIZE
dirY = 0

' Startlänge: 5 Segmente
length = 5
score = 0
gameOver = 0

' Erste Schlangensegmente (dahinter): Körper nach links
FOR i = 1 TO 4
    snakeX(i) = snakeX(0) - i * GRID_SIZE
    snakeY(i) = snakeY(0)
NEXT i

' Erstes Futter platzieren
GOSUB PlaceFood

' ================================================
' 5. HAUPTSPIEL-SCHLEIFE
' ================================================
DO
    ' Geschwindigkeit kontrollieren (klassisch: 8 FPS)
    _LIMIT GAME_FPS
    
    ' --- 5a. BILDSCHIRM LÖSCHEN ---
    CLS
    COLOR COLOR_WHITE, COLOR_BLACK
    
    ' --- 5b. EINGABE VERARBEITEN ---
    k$ = INKEY$
    
    ' Pfeiltasten-Handler (nur wenn nicht entgegengesetzt zu aktueller Richtung)
    IF k$ = CHR$(0) + CHR$(72) AND dirY = 0 THEN ' Pfeil OBEN
        dirX = 0: dirY = -GRID_SIZE
    ELSEIF k$ = CHR$(0) + CHR$(80) AND dirY = 0 THEN ' Pfeil UNTEN
        dirX = 0: dirY = GRID_SIZE
    ELSEIF k$ = CHR$(0) + CHR$(75) AND dirX = 0 THEN ' Pfeil LINKS
        dirX = -GRID_SIZE: dirY = 0
    ELSEIF k$ = CHR$(0) + CHR$(77) AND dirX = 0 THEN ' Pfeil RECHTS
        dirX = GRID_SIZE: dirY = 0
    ELSEIF k$ = CHR$(27) THEN ' ESC = Beenden
        gameOver = 1
    END IF
    
    ' --- 5c. SCHLANGE BEWEGEN ---
    ' Body-Segmente nachfolgen (von hinten nach vorne schieben)
    FOR i = length - 1 TO 1 STEP -1
        snakeX(i) = snakeX(i - 1)
        snakeY(i) = snakeY(i - 1)
    NEXT i
    
    ' Kopf bewegen in aktuelle Richtung
    snakeX(0) = snakeX(0) + dirX
    snakeY(0) = snakeY(0) + dirY
    
    ' --- 5d. KOLLISIONEN PRÜFEN ---
    
    ' Wandkollision
    IF snakeX(0) < PLAYFIELD_LEFT OR snakeX(0) >= PLAYFIELD_RIGHT OR _
       snakeY(0) < PLAYFIELD_TOP OR snakeY(0) >= PLAYFIELD_BOTTOM THEN
        gameOver = 1
    END IF
    
    ' Selbstkollision (Kopf trifft Body)
    FOR i = 1 TO length - 1
        IF snakeX(0) = snakeX(i) AND snakeY(0) = snakeY(i) THEN
            gameOver = 1
        END IF
    NEXT i
    
    ' --- 5e. FUTTER-LOGIK ---
    ' Prüfe ob Kopf das Futter frisst
    IF snakeX(0) = foodX AND snakeY(0) = foodY THEN
        length = length + 1           ' Schlange wächst um 1
        score = score + 10            ' 10 Punkte
        GOSUB PlaceFood               ' Neues Futter platzieren
        SOUND 800, 0.5                ' Audio-Feedback (800Hz, 0.5 Sekunden)
    END IF
    
    ' --- 5f. GRAFIK ZEICHNEN ---
    
    ' Spielfeld-Rand zeichnen (Rechteck)
    LINE (BORDER_OFFSET, BORDER_OFFSET)-(SCREEN_WIDTH - BORDER_OFFSET, SCREEN_HEIGHT - BORDER_OFFSET), _
         COLOR_WHITE, B
    
    ' Futter zeichnen (weißes Quadrat)
    ' Größe: 16x16 Pixel (±8 vom Mittelpunkt)
    LINE (foodX - 8, foodY - 8)-(foodX + 8, foodY + 8), COLOR_WHITE, BF
    
    ' Schlange zeichnen (weiße Quadrate für jedes Segment)
    FOR i = 0 TO length - 1
        LINE (snakeX(i) - 8, snakeY(i) - 8)-(snakeX(i) + 8, snakeY(i) + 8), COLOR_WHITE, BF
    NEXT i
    
    ' --- 5g. HUD (HEAD-UP-DISPLAY) ---
    ' Score und Länge in Zeile 1
    LOCATE 1, 2
    PRINT "SCORE:"; score; "  LAENGE:"; length
    
    ' --- 5h. GAME OVER BEHANDLUNG ---
    IF gameOver = 1 THEN
        ' Game Over Screen anzeigen
        LOCATE 15, 25
        PRINT "*** GAME OVER ***"
        LOCATE 17, 22
        PRINT "FINAL SCORE:"; score
        LOCATE 19, 20
        PRINT "Druecke SPACE fuer Neustart"
        LOCATE 20, 24
        PRINT "oder ESC zum Beenden"
        _DISPLAY
        
        ' Warten auf Spieler-Input (Neustart oder Beenden)
        DO
            k$ = INKEY$
            
            IF k$ = " " THEN ' SPACE = Neustart
                ' Spiel komplett zurücksetzen
                snakeX(0) = 320
                snakeY(0) = 240
                dirX = GRID_SIZE
                dirY = 0
                length = 5
                score = 0
                gameOver = 0
                
                ' Körper neu initialisieren
                FOR i = 1 TO 4
                    snakeX(i) = snakeX(0) - i * GRID_SIZE
                    snakeY(i) = snakeY(0)
                NEXT i
                
                ' Futter platzieren
                GOSUB PlaceFood
                EXIT DO ' Game Over Schleife verlassen, zurück zum Hauptspiel
                
            ELSEIF k$ = CHR$(27) THEN ' ESC = Beenden
                SYSTEM ' Programm beenden
            END IF
            
            _LIMIT 30 ' Input-Schleife begrenzen
        LOOP
    END IF
    
    ' Bildschirm aktualisieren
    _DISPLAY
    
' Hauptschleife: Läuft bis GameOver=1 UND ESC gedrückt wurde
LOOP UNTIL gameOver = 1 AND k$ = CHR$(27)

SYSTEM ' Programm beenden

' ================================================
' 6. SUBROUTINE: FUTTER PLATZIEREN
' ================================================
' ZWECK: Neue Futter-Position generieren
'        (nicht auf Schlange, nicht außerhalb Spielfeld)
'
' INPUT: length (aktuelle Schlangenlänge)
'        snakeX() / snakeY() (Schlangen-Positionen)
'
' OUTPUT: foodX, foodY (neue Futter-Position)
' ================================================
PlaceFood:
    ' Zufällige Position im Gitter (20x20 Pixel pro Gitter-Zelle)
    ' Range: 40-620 Pixel horizontal, 40-440 Pixel vertikal
    foodX = INT(RND * 29) * GRID_SIZE + 40
    foodY = INT(RND * 21) * GRID_SIZE + 40
    
    ' Prüfen ob Futter nicht auf Schlangen-Segment liegt
    FOR i = 0 TO length - 1
        IF foodX = snakeX(i) AND foodY = snakeY(i) THEN
            ' Position ist besetzt - neu generieren
            GOTO PlaceFood
        END IF
    NEXT i
    
RETURN

