use macroquad::prelude::*;

const SCREEN_WIDTH: i32 = 640;
const SCREEN_HEIGHT: i32 = 480;
const GRID_SIZE: i32 = 20; // Größe jedes Gitter-Quadrats (Pixel)
const BORDER_OFFSET: i32 = 10; // Abstand vom Bildschirmrand
const MAX_SNAKE_LENGTH: usize = 500; // Maximale Schlangenlänge

const GAME_FPS: f32 = 8.0; // Frames per Second (klassisches Tempo)

const PLAYFIELD_LEFT: i32 = BORDER_OFFSET + 10;
const PLAYFIELD_RIGHT: i32 = SCREEN_WIDTH - 20;
const PLAYFIELD_TOP: i32 = BORDER_OFFSET + 10;
const PLAYFIELD_BOTTOM: i32 = SCREEN_HEIGHT - 20;

#[macroquad::main(window_conf)]
async fn main() {
    // Schlangen-Arrays: Position jedes Segmentes
    let mut snake_x: [i32; MAX_SNAKE_LENGTH] = [0; MAX_SNAKE_LENGTH];
    let mut snake_y: [i32; MAX_SNAKE_LENGTH] = [0; MAX_SNAKE_LENGTH];

    // Bewegungsrichtung (in Pixel pro Frame)
    let mut dir_x: i32; // -20, 0, oder +20
    let mut dir_y: i32; // -20, 0, oder +20

    // Spiel-State
    let mut length: usize; // Aktuelle Schlangenlänge
    let mut food_x: i32; // X-Position des Futters
    let mut food_y: i32; // Y-Position des Futters
    let mut score: i32; // Aktuelle Punktzahl
    let mut game_over: bool; // Spielstatus: false=läuft, true=vorbei

    // Startposition: Mitte des Bildschirmes
    snake_x[0] = 320;
    snake_y[0] = 240;

    // Startrichtung: Nach rechts
    dir_x = GRID_SIZE;
    dir_y = 0;

    // Startlänge: 5 Segmente
    length = 5;
    score = 0;
    game_over = false;

    // Erste Schlangensegmente (dahinter): Körper nach links
    for i in 1..5 {
        snake_x[i] = snake_x[0] - (i as i32) * GRID_SIZE;
        snake_y[i] = snake_y[0];
    }

    // Erstes Futter platzieren
    let (fx, fy) = place_food(length, &snake_x, &snake_y);
    food_x = fx;
    food_y = fy;

    let mut tick_accumulator: f32 = 0.0;
    let tick_interval: f32 = 1.0 / GAME_FPS; // 8 FPS

    loop {
        let dt = get_frame_time();
        tick_accumulator += dt;

        // Eingabe (nicht blockierend)
        // Pfeiltasten-Handler (nur wenn nicht entgegengesetzt zu aktueller Richtung)
        if is_key_pressed(KeyCode::Up) && dir_y == 0 {
            dir_x = 0;
            dir_y = -GRID_SIZE;
        } else if is_key_pressed(KeyCode::Down) && dir_y == 0 {
            dir_x = 0;
            dir_y = GRID_SIZE;
        } else if is_key_pressed(KeyCode::Left) && dir_x == 0 {
            dir_x = -GRID_SIZE;
            dir_y = 0;
        } else if is_key_pressed(KeyCode::Right) && dir_x == 0 {
            dir_x = GRID_SIZE;
            dir_y = 0;
        } else if is_key_pressed(KeyCode::Escape) {
            game_over = true;
        }

        // Update- und Render-Schritt nur alle 1/8 Sekunde
        if tick_accumulator >= tick_interval {
            tick_accumulator -= tick_interval;

            // Bildschirm löschen (Hintergrund schwarz)
            clear_background(BLACK);

            // --- Schlange bewegen ---
            // Body-Segmente nachfolgen (von hinten nach vorne schieben)
            if length > 1 {
                for i in (1..length).rev() {
                    snake_x[i] = snake_x[i - 1];
                    snake_y[i] = snake_y[i - 1];
                }
            }

            // Kopf bewegen in aktuelle Richtung
            snake_x[0] += dir_x;
            snake_y[0] += dir_y;

            // --- Kollisionen prüfen ---
            // Wandkollision
            if snake_x[0] < PLAYFIELD_LEFT
                || snake_x[0] >= PLAYFIELD_RIGHT
                || snake_y[0] < PLAYFIELD_TOP
                || snake_y[0] >= PLAYFIELD_BOTTOM
            {
                game_over = true;
            }

            // Selbstkollision (Kopf trifft Body)
            if !game_over {
                for i in 1..length {
                    if snake_x[0] == snake_x[i] && snake_y[0] == snake_y[i] {
                        game_over = true;
                        break;
                    }
                }
            }

            // --- Futter-Logik ---
            if !game_over && snake_x[0] == food_x && snake_y[0] == food_y {
                // Schlange wächst um 1
                if length + 1 < MAX_SNAKE_LENGTH {
                    length += 1;
                }
                // 10 Punkte
                score += 10;
                // Neues Futter platzieren
                let (nfx, nfy) = place_food(length, &snake_x, &snake_y);
                food_x = nfx;
                food_y = nfy;
                // SOUND 800, 0.5 (nicht implementiert)
            }

            // --- Grafik zeichnen ---
            // Spielfeld-Rand zeichnen (Rechteck)
            draw_rectangle_lines(
                (BORDER_OFFSET) as f32,
                (BORDER_OFFSET) as f32,
                (SCREEN_WIDTH - 2 * BORDER_OFFSET) as f32,
                (SCREEN_HEIGHT - 2 * BORDER_OFFSET) as f32,
                1.0,
                WHITE,
            );

            // Futter zeichnen (weißes Quadrat) Größe: 16x16 Pixel (±8 vom Mittelpunkt)
            draw_rectangle((food_x - 8) as f32, (food_y - 8) as f32, 16.0, 16.0, WHITE);

            // Schlange zeichnen (weiße Quadrate für jedes Segment)
            for i in 0..length {
                draw_rectangle((snake_x[i] - 8) as f32, (snake_y[i] - 8) as f32, 16.0, 16.0, WHITE);
            }

            // HUD: Score und Länge
            draw_text(
                &format!("SCORE: {}  LAENGE: {}", score, length),
                12.0,
                20.0,
                24.0,
                WHITE,
            );

            // Game Over Behandlung
            if game_over {
                // Game Over Screen anzeigen
                draw_text("*** GAME OVER ***", 200.0, 220.0, 28.0, WHITE);
                draw_text(&format!("FINAL SCORE: {}", score), 210.0, 250.0, 24.0, WHITE);
                draw_text("Druecke SPACE fuer Neustart", 170.0, 280.0, 24.0, WHITE);
                draw_text("oder ESC zum Beenden", 210.0, 310.0, 24.0, WHITE);

                // Warten auf Spieler-Input (Neustart oder Beenden)
                loop {
                    if is_key_pressed(KeyCode::Space) {
                        // Spiel komplett zurücksetzen
                        snake_x[0] = 320;
                        snake_y[0] = 240;
                        dir_x = GRID_SIZE;
                        dir_y = 0;
                        length = 5;
                        score = 0;
                        game_over = false;

                        for i in 1..5 {
                            snake_x[i] = snake_x[0] - (i as i32) * GRID_SIZE;
                            snake_y[i] = snake_y[0];
                        }

                        let (nfx, nfy) = place_food(length, &snake_x, &snake_y);
                        food_x = nfx;
                        food_y = nfy;
                        break;
                    } else if is_key_pressed(KeyCode::Escape) {
                        // Programm beenden
                        return;
                    }

                    // Anzeige aktualisieren während Wartebildschirm
                    next_frame().await;
                    clear_background(BLACK);
                    draw_rectangle_lines(
                        (BORDER_OFFSET) as f32,
                        (BORDER_OFFSET) as f32,
                        (SCREEN_WIDTH - 2 * BORDER_OFFSET) as f32,
                        (SCREEN_HEIGHT - 2 * BORDER_OFFSET) as f32,
                        1.0,
                        WHITE,
                    );
                    draw_text("*** GAME OVER ***", 200.0, 220.0, 28.0, WHITE);
                    draw_text(&format!("FINAL SCORE: {}", score), 210.0, 250.0, 24.0, WHITE);
                    draw_text("Druecke SPACE fuer Neustart", 170.0, 280.0, 24.0, WHITE);
                    draw_text("oder ESC zum Beenden", 210.0, 310.0, 24.0, WHITE);
                }
            }
        }

        next_frame().await;
    }
}

fn window_conf() -> Conf {
    Conf {
        window_title: String::from("SNAKE - Klassisch"),
        window_width: SCREEN_WIDTH,
        window_height: SCREEN_HEIGHT,
        window_resizable: false,
        ..Default::default()
    }
}

fn place_food(length: usize, snake_x: &[i32; MAX_SNAKE_LENGTH], snake_y: &[i32; MAX_SNAKE_LENGTH]) -> (i32, i32) {
    // Zufällige Position im Gitter (20x20 Pixel pro Gitter-Zelle)
    // Range: INT(RND * 29) * 20 + 40 (horizontal), INT(RND * 21) * 20 + 40 (vertikal)
    use macroquad::rand::gen_range;
    loop {
        let fx = gen_range(0, 29) * GRID_SIZE + 40;
        let fy = gen_range(0, 21) * GRID_SIZE + 40;

        let mut collides = false;
        for i in 0..length {
            if snake_x[i] == fx && snake_y[i] == fy {
                collides = true;
                break;
            }
        }

        if !collides {
            return (fx, fy);
        }
        // entspricht GOTO PlaceFood in GW-BASIC
    }
}


