```
 _____ _   _    _    _  _______   ____  _    _   _ _____ ____  ____  ___ _   _ _____
/ ____| \ | |  / \  | |/ / ____| | __ )| |  | | | | ____|  _ \|  _ \|_ _| \ | |_   _|
\___ \|  \| | / _ \ | ' /|  _|   |  _ \| |  | | | |  _| | |_) | |_) || ||  \| | | |
 ___) | |\  |/ ___ \| . \| |___  | |_) | |__| |_| | |___|  __/|  _ < | || |\  | | |
|____/|_| \_/_/   \_\_|\_\_____| |____/|_____\___/|_____|_|   |_| \_\___|_| \_| |_|
```

## PROJECT OVERVIEW

A classic Snake game implemented across multiple programming languages to serve
as a blueprint for learning different programming paradigms and language features.

Started as a comeback to programming after 20+ years. Snake provides a stable,
well-defined specification to compare languages side-by-side.

---

## OBJECTIVES

[X] Implement identical game logic across languages
[X] Understand language differences and trade-offs
[X] Explore different paradigms (imperative, OOP, functional)
[X] Build a "Rosetta Stone" of programming knowledge

---

## GAME MECHANICS

### Controls
- Arrow Keys    : Steer the snake (UP/DOWN/LEFT/RIGHT)
- SPACE         : Restart after Game Over
- ESC           : Exit game

### Rules
- Snake starts with 5 segments in screen center
- Moves continuously in current direction
- Eating food grows snake by 1 segment and awards 10 points
- Game Over occurs on:
  * Wall collision (head hits playfield boundary)
  * Self collision (head hits body)

### Technical Specification

    Parameter             Value
    ----------------------------------
    Window Resolution     640 x 480 px
    Grid Size             20 x 20 px
    Game Speed            8 FPS
    Starting Length       5 segments
    Points per Food       10
    Max Snake Length      500 segments

---

## PROJECT STRUCTURE

```
snake/
|
+-- README.md              # This file
+-- requirements.txt       # Python dependencies
|
+-- snake_gwbasic.bas      # QB64 version (Original Blueprint)
+-- snake_python.py        # Python/Pygame version
+-- snake_elixir.exs       # Elixir version
+-- snake_rust.rs          # Rust version (WIP)
|
+-- Cargo.toml             # Rust configuration
+-- src/                   # Additional source files
```

---

## IMPLEMENTATIONS

### [1] QB64 - Original Blueprint

FILE: snake_gwbasic.bas

The reference implementation defining the entire blueprint.
Fully documented with inline comments.

CHARACTERISTICS:
- Imperative programming style
- GOSUB subroutines instead of functions
- Global variable arrays
- Classic BASIC style

RUN:
    qb64 snake_gwbasic.bas


### [2] Python - Object-Oriented

FILE: snake_python.py

Modern OOP implementation using Pygame framework.

CHARACTERISTICS:
- Class-based architecture (GameState, Renderer)
- Event-driven input handling
- Enums for directions
- Pythonic conventions

RUN:
    pip install -r requirements.txt
    python snake_python.py


### [3] Elixir - Functional

FILE: snake_elixir.exs

Functional programming approach with immutable data structures.

CHARACTERISTICS:
- Pattern matching
- Immutable state
- Process-based architecture
- Functional paradigm

RUN:
    elixir snake_elixir.exs


### [4] Rust - Systems Programming (WIP)

FILE: snake_rust.rs

High-performance implementation with memory safety guarantees.

CHARACTERISTICS:
- Ownership and borrowing
- Zero-cost abstractions
- Type safety
- Performance-focused

RUN:
    cargo run

---

## BLUEPRINT STRUCTURE

All implementations follow this 6-phase structure:

    [1] Display Configuration
        Window setup and graphics initialization

    [2] Constants
        All magic numbers as named constants

    [3] Variable Initialization
        State declaration and data structures

    [4] Game Initialization
        Starting position and initial values

    [5] Main Game Loop
        - 5a: Clear screen
        - 5b: Process input
        - 5c: Move snake
        - 5d: Check collisions
        - 5e: Food logic
        - 5f: Draw graphics
        - 5g: Display HUD
        - 5h: Handle game over

    [6] Subroutine: Place Food
        Random position without snake overlap

---

## LANGUAGE COMPARISON

    Aspect          QB64          Python        Elixir        Rust
    ---------------------------------------------------------------------
    Paradigm        Imperative    OOP           Functional    Systems
    Input           INKEY$        Event Loop    GenServer     Event Loop
    Data            Arrays        Lists/Class   Maps/Lists    Vec/Struct
    Functions       GOSUB         Methods       Functions     Methods
    Graphics        LINE          pygame.draw   Scenic        SDL/OpenGL
    Complexity      Procedural    Modular       Concurrent    Safe
    Type Safety     Weak          Dynamic       Strong        Strong

---

## LEARNING GOALS

### After QB64
- [X] Procedural programming
- [X] BASIC syntax
- [X] Game loop fundamentals
- [X] Collision detection

### After Python
- [X] Object-oriented design
- [X] Classes and methods
- [X] Event-driven programming
- [X] Modern game frameworks

### After Elixir
- [X] Functional programming
- [X] Pattern matching
- [X] Immutable data
- [X] Process-based architecture

### Future Implementations
- [ ] JavaScript/Canvas (web-based)
- [ ] C#/Unity (game engine)
- [ ] Go (simplicity + performance)
- [ ] C++ (low-level control)

---

## REQUIREMENTS

- QB64: v2.0+ (https://qb64phoenix.com/)
- Python: 3.8+
- Elixir: 1.12+
- Rust: 1.70+

---

## INSTALLATION

### Python Setup
```bash
# Create virtual environment (recommended)
python -m venv venv
venv\Scripts\activate         # Windows
source venv/bin/activate      # Unix/Mac

# Install dependencies
pip install -r requirements.txt
```

### Rust Setup
```bash
# Install Rust toolchain
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

# Build project
cargo build --release
```

---

## DOCUMENTATION

- snake_gwbasic.bas  : Fully commented reference implementation
- Each .bas/.py/.exs : Inline documentation following blueprint phases

---

## LICENSE

Open source project for educational and demonstration purposes.

---

## NEXT STEPS

1. Run QB64 version         - Understand the baseline
2. Study Python version     - Learn OOP structure
3. Explore Elixir version   - Grasp functional paradigm
4. Choose next language     - JavaScript, Rust, Go, C++
5. Implement blueprint      - Write new code
6. Compare and contrast     - Analyze differences

---

Created as a programming learning journey after 20+ years.
Classic Snake as a stable blueprint for multi-language exploration.

Last updated: November 2025
