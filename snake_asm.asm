; ================================================
; SNAKE SPIEL - x86-64 Assembler (NASM)
; ================================================
; ZWECK: Textbasierte Implementierung für das Linux-Terminal.
;        Fokus auf Low-Level-Logik.
;
; STEUERUNG (geplant):
;   - W, A, S, D: Schlange lenken
;   - Q: Beenden
; ================================================

SECTION .data
    ; --- Konstanten ---
    BOARD_WIDTH     EQU 32
    BOARD_HEIGHT    EQU 20

    SNAKE_CHAR      DB '#'
    FOOD_CHAR       DB '*'
    WALL_CHAR       DB 'X'
    EMPTY_CHAR      DB ' '

    ; --- Debug-Nachricht ---
    hello_msg       DB 'Assembler Snake - Initialized.', 0xA ; 0xA = Newline
    hello_len       EQU $ - hello_msg

    clear_code      DB 0x1B, '[2J', 0x1B, '[H'
    clear_len       EQU $ - clear_code

    ; timespec für nanosleep (1/8 Sekunde = 125,000,000 Nanosekunden)
    game_speed      DQ 0                  ; Sekunden
                    DQ 125000000          ; Nanosekunden

SECTION .bss
    ; Spielfeld-Buffer: Jede Zelle ist ein Byte
    game_board      RESB BOARD_WIDTH * BOARD_HEIGHT + BOARD_HEIGHT ; +Höhe für Newlines

    ; Schlangen-Array: x, y, x, y, ...
    snake_body      RESD 500 * 2
    snake_len       RESD 1

    ; Futter-Position
    food_x          RESD 1
    food_y          RESD 1

    ; Bewegungsrichtung
    dir_x           RESD 1
    dir_y           RESD 1

    ; Buffer für Input
    input_char      RESB 2

SECTION .text
    GLOBAL _start

; ... (clear_screen, init_board, draw_board, init_food, stamp_objects)

; ================================================
; PROZEDUR: init_snake
; ================================================
init_snake:
    MOV dword [snake_len], 5
    MOV dword [dir_x], 1
    MOV dword [dir_y], 0

    ; Kopf & Körper...
    MOV dword [snake_body], BOARD_WIDTH / 2
    MOV dword [snake_body+4], BOARD_HEIGHT / 2
    MOV dword [snake_body+8], BOARD_WIDTH / 2 - 1
    MOV dword [snake_body+12], BOARD_HEIGHT / 2
    MOV dword [snake_body+16], BOARD_WIDTH / 2 - 2
    MOV dword [snake_body+20], BOARD_HEIGHT / 2
    MOV dword [snake_body+24], BOARD_WIDTH / 2 - 3
    MOV dword [snake_body+28], BOARD_HEIGHT / 2
    MOV dword [snake_body+32], BOARD_WIDTH / 2 - 4
    MOV dword [snake_body+36], BOARD_HEIGHT / 2
    RET

; ================================================
; PROZEDUR: move_snake
; ================================================
move_snake:
    ; Körper nachziehen (von hinten nach vorne)
    MOV ecx, [snake_len]
    DEC ecx
.move_loop:
    MOV eax, [snake_body + ecx*8 - 8] ; x_prev
    MOV dword [snake_body + ecx*8], eax
    MOV eax, [snake_body + ecx*8 - 4] ; y_prev
    MOV dword [snake_body + ecx*8 + 4], eax
    DEC ecx
    JNZ .move_loop

    ; Kopf bewegen
    MOV eax, [snake_body]
    ADD eax, [dir_x]
    MOV [snake_body], eax

    MOV eax, [snake_body+4]
    ADD eax, [dir_y]
    MOV [snake_body+4], eax
    RET

; ================================================
; PROZEDUR: process_input
; ================================================
process_input:
    ; Terminal auf non-blocking setzen (vereinfacht)
    ; In einer echten Anwendung wäre hier tcsetattr nötig.
    ; Wir nutzen einen einfachen, blockierenden Read.
    MOV rax, 0              ; syscall: sys_read
    MOV rdi, 0              ; file descriptor: stdin
    MOV rsi, input_char     ; buffer
    MOV rdx, 2              ; max 2 chars lesen
    SYSCALL

    MOV al, [input_char]
    CMP al, 'w'
    JE .go_up
    CMP al, 's'
    JE .go_down
    CMP al, 'a'
    JE .go_left
    CMP al, 'd'
    JE .go_right
    CMP al, 'q'
    JE .quit
    JMP .end_input

.go_up:   MOV dword [dir_x], 0; MOV dword [dir_y], -1; JMP .end_input
.go_down: MOV dword [dir_x], 0; MOV dword [dir_y], 1; JMP .end_input
.go_left: MOV dword [dir_x], -1; MOV dword [dir_y], 0; JMP .end_input
.go_right:MOV dword [dir_x], 1; MOV dword [dir_y], 0; JMP .end_input

.quit:
    MOV rax, 60
    XOR rdi, rdi
    SYSCALL

.end_input:
    RET

; ================================================
; HAUPT-ROUTINE
; ================================================
_start:
    CALL init_board
    CALL init_snake
    CALL init_food

.game_loop:
    CALL clear_screen
    CALL stamp_objects
    CALL draw_board
    CALL process_input
    CALL move_snake

    ; TODO: Kollision, Futter essen, etc.

    ; Reset board for next frame
    CALL init_board

    JMP .game_loop
