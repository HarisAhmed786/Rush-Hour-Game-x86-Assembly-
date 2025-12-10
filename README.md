# Rush Hour — x86 Assembly Arcade Game

Rush Hour is a fully functional, console-based arcade game built entirely in **x86 Assembly (MASM)** using the **Irvine32 library**. This project serves as a deep exploration of systems-level programming, demonstrating low-level control over memory, logic, and hardware interaction without relying on modern game engines or high-level abstractions.

---

## ⚙️ Technical Overview

- **Language & Environment:** MASM (Microsoft Macro Assembler) with Irvine32 for core input/output  
- **Architecture:** 32-bit x86 protected mode  
- **Game Board:** 20×20 grid mapped manually from a flat **400-byte array**, with explicit address calculations for every coordinate lookup *(row × width + column)*  
- **AI Systems:** Real-time NPC traffic behavior implemented using conditional jumps (CMP/JMP) and register-based state management  
- **Core Logic:** Custom collision detection, player movement, scoring system, and difficulty scaling  
- **Persistence:** Binary file I/O for saving and loading game state  
- **Audio:** Real-time sound effects integrated via the **Windows Multimedia API (winmm.lib)**  
- **Optimization Fixes:** Refactored control flow to resolve MASM limitations such as **“Jump destination too far”** using logic inversion and localized short-jump sequences

---

## 🎮 Game Features

### Gameplay
- Pick up passengers (**P**) and deliver them to destinations (**D**)  
- Avoid AI-controlled traffic enemies (**E**) and obstacles (**O**)

### Game Modes
- **Career Mode** — progressive difficulty scaling  
- **Time Attack** — race against the clock  
- **Endless Mode** — survival-based scoring challenge

### Vehicle Classes
- **Yellow Car (Fast):** Higher speed with increased collision penalties  
- **Red Car (Sturdy):** Slower movement with reduced collision impact

### Dynamic Systems
- Difficulty increases based on player performance and progression

---

## 🧠 Learning Outcomes

This project demonstrates practical mastery of:

- Low-level memory management  
- Assembly-level control flow engineering  
- Systems programming fundamentals  
- AI implementation without high-level data structures  
- Debugging and optimization under architectural constraints

---

## ⚙️ Build & Run Instructions

### Requirements
- Windows OS  
- MASM (Microsoft Macro Assembler)  
- Irvine32 library  
- Visual Studio or MASM32 SDK

### Setup

1. Ensure MASM and Irvine32 are properly configured.
2. Open the project directory.
3. Build the project using the provided `.asm` file.
4. Run the compiled executable from the command line or Visual Studio debugger.

---
## 🎥 Live Demo
[![Rush Hour Demo](https://github.com/user-attachments/assets/5095da91-a057-4ba9-910b-b15003a63427)](https://drive.google.com/file/d/1S7o_SWdVZUg_d4Y6lUUL0j93ADwJEEDx/view?usp=sharing)

## Screenshots

<img width="589" height="574" alt="Game Board" src="https://github.com/user-attachments/assets/b5278bf1-73c7-4391-a4b6-178faf3c7fda" />
<img width="804" height="572" alt="Game Menu" src="https://github.com/user-attachments/assets/5095da91-a057-4ba9-910b-b15003a63427" />
<img width="1211" height="601" alt="Game Over Screen" src="https://github.com/user-attachments/assets/93023c8d-6864-41af-a0d2-fb3993ff8a47" />
<img width="770" height="260" alt="Leader Board" src="https://github.com/user-attachments/assets/71cec8e5-6aac-4b55-b21d-6cb01f3f9a2e" />
