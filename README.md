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

- [X] Implement identical game logic across languages
- [X] Understand language differences and trade-offs
- [X] Explore different paradigms (imperative, OOP, functional, systems)
- [X] Build a "Rosetta Stone" of programming knowledge
- [X] Cover 8 distinct programming languages
- [X] Compare memory management approaches
- [ ] Reach 10+ language implementations
- [ ] Add web-based implementation (JavaScript/WASM)

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
+-- snake_rust.rs          # Rust/Macroquad version
+-- snake_pascal.pas       # Turbo Pascal version
+-- snake_elixir.exs       # Elixir terminal version
+-- snake_cpp.cpp          # C++ with SDL2
+-- snake_csharp.cs        # C# with Windows Forms
+-- snake_asm.asm          # x86-64 Assembly (experimental)
|
+-- Cargo.toml             # Rust configuration
+-- SnakeGame.csproj       # C# project configuration
+-- src/                   # Additional source files
```

---

## IMPLEMENTATIONS

### [1] QB64 - Original Blueprint ✅

FILE: snake_gwbasic.bas

The reference implementation defining the entire blueprint.
Fully documented with inline comments.

CHARACTERISTICS:
- Imperative programming style
- GOSUB subroutines instead of functions
- Global variable arrays
- Classic BASIC style with QB64 extensions

RUN:
    qb64 snake_gwbasic.bas


### [2] Python - Object-Oriented ✅

FILE: snake_python.py

Modern OOP implementation using Pygame framework.

CHARACTERISTICS:
- Class-based architecture (GameState, Renderer)
- Event-driven input handling
- Enums for directions
- Pythonic conventions
- NumPy for sound generation

RUN:
    pip install -r requirements.txt
    python snake_python.py


### [3] Rust - Systems Programming ✅

FILE: snake_rust.rs

High-performance implementation with memory safety guarantees.

CHARACTERISTICS:
- Ownership and borrowing
- Zero-cost abstractions
- Type safety with strong guarantees
- Macroquad game framework
- Async main loop

RUN:
    cargo run


### [4] Pascal - Structured Programming ✅

FILE: snake_pascal.pas

Classic Turbo Pascal implementation with BGI graphics.

CHARACTERISTICS:
- Structured procedural programming
- Type-safe with strong typing
- Crt and Graph units for I/O
- Classic Pascal syntax
- DOS-era graphics (BGI)

RUN:
    fpc snake_pascal.pas     # Free Pascal Compiler
    ./snake_pascal


### [5] Elixir - Functional ✅

FILE: snake_elixir.exs

Functional programming approach with immutable data structures.
Terminal-based rendering with ANSI escape codes.

CHARACTERISTICS:
- Pattern matching
- Immutable state
- Process-based architecture
- Functional paradigm
- Terminal graphics

RUN:
    elixir snake_elixir.exs


### [6] C++ - Modern Systems Programming ✅

FILE: snake_cpp.cpp

Low-level implementation with SDL2 graphics library.

CHARACTERISTICS:
- Modern C++ with STL containers
- Manual memory management (SDL resources)
- SDL2 for cross-platform graphics
- Object-oriented with structs
- Direct hardware access

RUN:
    g++ snake_cpp.cpp -o snake_cpp -lSDL2
    ./snake_cpp

    # Or with pkg-config:
    g++ snake_cpp.cpp -o snake_cpp `pkg-config --cflags --libs sdl2`


### [7] C# - Enterprise OOP ✅

FILE: snake_csharp.cs

Windows Forms implementation with .NET framework.

CHARACTERISTICS:
- Full object-oriented design
- Event-driven architecture
- Windows Forms for GUI
- Garbage collected
- Double-buffered rendering

RUN:
    # With .NET SDK:
    dotnet run

    # Or compile with:
    csc /target:winexe snake_csharp.cs


### [8] x86-64 Assembly - Low-Level Experimental 🔬

FILE: snake_asm.asm

Bare-metal implementation for Linux terminal.

CHARACTERISTICS:
- Direct syscalls (no libc)
- Register-based operations
- NASM syntax
- Linux-specific
- Minimalist approach

STATUS:
    Work in progress - basic structure implemented

RUN:
    nasm -f elf64 snake_asm.asm -o snake_asm.o
    ld snake_asm.o -o snake_asm
    ./snake_asm

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

    Aspect          QB64       Python     Rust       Pascal     Elixir     C++        C#         ASM
    --------------------------------------------------------------------------------------------------------
    Paradigm        Imperative OOP        Systems    Structured Functional Systems    OOP        Bare-Metal
    Input           INKEY$     Events     Events     ReadKey    Raw IO     Events     Events     Syscalls
    Data            Arrays     Lists      Vec        Arrays     Maps       Vector     List       Registers
    Functions       GOSUB      Methods    Fns+Traits Procedures Functions  Methods    Methods    Labels
    Graphics        LINE       Pygame     Macroquad  BGI        ANSI       SDL2       WinForms   Syscalls
    Memory          Auto       GC         Ownership  Manual     GC         Manual     GC         Manual
    Type Safety     Weak       Dynamic    Strong     Strong     Strong     Strong     Strong     None
    Complexity      Simple     Moderate   High       Moderate   Moderate   High       Moderate   Very High
    Era             1980s      Modern     Modern     1980s      Modern     1980s+     Modern     1970s
    Platform        Windows    Cross      Cross      DOS/Win    Cross      Cross      Windows    Linux

---

## LEARNING GOALS

### Completed Implementations

#### QB64 ✅
- [X] Procedural programming
- [X] BASIC syntax and GOSUB subroutines
- [X] Game loop fundamentals
- [X] Collision detection basics

#### Python ✅
- [X] Object-oriented design
- [X] Classes and methods
- [X] Event-driven programming
- [X] Modern game frameworks (Pygame)
- [X] NumPy for audio synthesis

#### Rust ✅
- [X] Ownership and borrowing
- [X] Memory safety without GC
- [X] Async/await patterns
- [X] Modern game frameworks (Macroquad)
- [X] Strong type system

#### Pascal ✅
- [X] Structured programming
- [X] Strong static typing
- [X] DOS-era graphics (BGI)
- [X] Procedural paradigm
- [X] Classic compiler (Free Pascal)

#### Elixir ✅
- [X] Functional programming
- [X] Pattern matching
- [X] Immutable data structures
- [X] Process-based architecture
- [X] Terminal graphics with ANSI codes

#### C++ ✅
- [X] Low-level systems programming
- [X] Manual memory management
- [X] SDL2 graphics library
- [X] Modern C++ (STL containers)
- [X] Cross-platform development

#### C# ✅
- [X] Enterprise-level OOP
- [X] Event-driven GUI programming
- [X] Windows Forms framework
- [X] .NET ecosystem
- [X] Garbage collection

#### x86-64 Assembly 🔬
- [X] Direct syscalls
- [X] Register operations
- [ ] Full game loop (WIP)
- [ ] Collision detection
- [ ] Input handling refinement

### Future Implementations
- [ ] JavaScript/TypeScript (web-based, Canvas API)
- [ ] Go (goroutines, simplicity)
- [ ] Haskell (pure functional)
- [ ] Lua with LÖVE (game framework)
- [ ] Zig (modern systems programming)

---

## REQUIREMENTS & DEPENDENCIES

### Language Versions
- **QB64**: v2.0+ (https://qb64phoenix.com/)
- **Python**: 3.8+ with Pygame, NumPy
- **Rust**: 1.70+ with Macroquad
- **Pascal**: Free Pascal Compiler 3.0+
- **Elixir**: 1.12+
- **C++**: GCC/Clang with C++11, SDL2 library
- **C#**: .NET 6.0+ or .NET Framework 4.7+
- **Assembly**: NASM 2.14+ (Linux x86-64 only)

### Platform Support
```
Language    Windows    Linux    macOS    Web
-------------------------------------------------
QB64        ✅         ✅       ✅       ❌
Python      ✅         ✅       ✅       ❌
Rust        ✅         ✅       ✅       ✅ (WASM)
Pascal      ✅         ✅       ❌       ❌
Elixir      ✅         ✅       ✅       ❌
C++         ✅         ✅       ✅       ❌
C#          ✅         ⚠️       ⚠️       ❌
Assembly    ❌         ✅       ❌       ❌

✅ Full Support  |  ⚠️ Partial (Mono/Wine)  |  ❌ Not Available
```

---

## INSTALLATION

### QB64 Setup
```bash
# Download from https://qb64phoenix.com/
# Extract and run QB64 IDE
# Open snake_gwbasic.bas and press F5
```

### Python Setup
```bash
# Create virtual environment (recommended)
python -m venv venv
venv\Scripts\activate         # Windows
source venv/bin/activate      # Unix/Mac

# Install dependencies
pip install -r requirements.txt

# Run
python snake_python.py
```

### Rust Setup
```bash
# Install Rust toolchain
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

# Build and run
cargo run --release
```

### Pascal Setup
```bash
# Install Free Pascal
# Ubuntu/Debian:
sudo apt-get install fpc

# Compile and run
fpc snake_pascal.pas
./snake_pascal
```

### Elixir Setup
```bash
# Install Elixir from https://elixir-lang.org/install.html

# Run directly
elixir snake_elixir.exs
```

### C++ Setup
```bash
# Install SDL2
# Ubuntu/Debian:
sudo apt-get install libsdl2-dev

# Windows: Download from https://www.libsdl.org/

# Compile and run
g++ snake_cpp.cpp -o snake_cpp -lSDL2
./snake_cpp
```

### C# Setup
```bash
# Install .NET SDK from https://dotnet.microsoft.com/

# Run
dotnet run

# Or compile manually
csc /target:winexe snake_csharp.cs
```

### Assembly Setup (Linux only)
```bash
# Install NASM
sudo apt-get install nasm

# Assemble and link
nasm -f elf64 snake_asm.asm -o snake_asm.o
ld snake_asm.o -o snake_asm
./snake_asm
```

---

## DOCUMENTATION

All implementations are fully documented with inline comments:

- **snake_gwbasic.bas** - Reference implementation, most detailed
- **snake_python.py** - OOP structure with docstrings
- **snake_rust.rs** - Rust idioms and borrowing patterns
- **snake_pascal.pas** - Classic Pascal structured programming
- **snake_elixir.exs** - Functional programming with pattern matching
- **snake_cpp.cpp** - C++ with SDL2 API documentation
- **snake_csharp.cs** - C# Windows Forms architecture
- **snake_asm.asm** - Low-level assembly with syscall comments

Each file follows the 6-phase blueprint structure for easy comparison.

---

## KEY INSIGHTS ACROSS LANGUAGES

### Memory Management
- **QB64/Python/C#/Elixir**: Automatic (GC)
- **Rust**: Ownership system (compile-time safety)
- **C++**: Manual (RAII pattern for SDL resources)
- **Pascal**: Manual (but simpler than C++)
- **Assembly**: Direct register/stack manipulation

### Type Systems
- **Weakly Typed**: QB64 (WITH CONST helps)
- **Dynamically Typed**: Python (runtime checks)
- **Strongly Typed**: Rust, C#, C++, Pascal, Elixir (compile-time safety)
- **No Types**: Assembly (raw bytes)

### Concurrency Models
- **Single-threaded**: QB64, Pascal, Python (GIL), C++, C#, Assembly
- **Actor model**: Elixir (lightweight processes)
- **Async/await**: Rust (Macroquad uses it)

### Graphics Approaches
- **Built-in**: QB64 (SCREEN, LINE commands)
- **Framework**: Python (Pygame), Rust (Macroquad)
- **Library**: C++ (SDL2), C# (Windows Forms)
- **Legacy**: Pascal (BGI - DOS graphics)
- **Terminal**: Elixir (ANSI escape codes)
- **Raw**: Assembly (framebuffer/syscalls)

---

## LICENSE

Open source educational project.
Free to use, modify, and learn from.

---

## GETTING STARTED

### For Beginners
1. **Start with QB64** (`snake_gwbasic.bas`) - Easiest to understand
2. **Try Python** (`snake_python.py`) - Modern and readable
3. **Explore others** based on interest

### For Experienced Developers
1. **Read the Blueprint** - Understand game mechanics in BASIC
2. **Pick your language** - Choose one you want to learn
3. **Compare implementations** - See how same logic differs
4. **Add your own** - Implement in a new language!

### Learning Path by Interest

**Want to learn OOP?** → Python → C# → C++  
**Want to learn Functional?** → Elixir → (Haskell next)  
**Want to learn Systems?** → Rust → C++ → Assembly  
**Want nostalgia?** → QB64 → Pascal  

---

## CONTRIBUTING

Feel free to:
- Add new language implementations
- Improve existing code
- Fix bugs
- Enhance documentation
- Share insights and comparisons

---

## PROJECT STATISTICS

```
Language        Lines of Code    Complexity    Time to Implement
----------------------------------------------------------------
QB64            262              Low           Reference
Python          374              Medium        2-3 hours
Rust            256              High          4-5 hours
Pascal          264              Medium        3-4 hours
Elixir          218              Medium        3-4 hours
C++             417              High          5-6 hours
C#              473              Medium        4-5 hours
Assembly        163 (partial)    Very High     10+ hours (WIP)
```

---

Created as a programming learning journey - **returning to code after 20+ years**.  
Classic Snake serves as a stable, well-defined blueprint for multi-language exploration.

**8 languages implemented. Many more to come!**

Last updated: **November 3, 2025**
