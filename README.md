# flame-jump-game

A 2D platformer prototype built with Flutter and Flame.

This project started as a simple jump game prototype and has grown into a small platformer core with coins, hazards, checkpoints, springs, moving platforms, camera follow, and tile-based terrain rendering.

## Features

- Player movement, jump, gravity, and landing
- Coin collection and exit gate clear flow
- Horizontal camera follow with level bounds
- Spike and saw hazards with respawn handling
- Checkpoints that update the respawn position
- Springs that launch the player upward
- Moving platforms that carry the player
- Tile-based terrain rendering using Kenney assets
- Sound effects powered by `flame_audio`

## Tech Stack

- Flutter
- Flame
- flame_audio

## Project Structure

```text
lib/
  main.dart
  src/
    core/
    game/
    world/
    entities/
    systems/
    data/
    ui/
```

## Getting Started

### Requirements

- Flutter SDK
- A device or desktop target such as Windows

### Run

```bash
flutter pub get
flutter run
```

### Check

```bash
flutter analyze
flutter test
```

## Current Status

The platformer core is mostly in place, and the project is now moving from engine setup into gameplay and content expansion.

Implemented so far:

- Core movement and platforming loop
- Collectibles and level clear flow
- Hazard and checkpoint loop
- Spring and moving platform interactions
- Improved terrain visuals

Planned next:

- Basic enemies
- Health and damage rules
- Start, pause, and game over UI
- More level content

## Assets

This prototype uses Kenney platformer assets for terrain, props, hazards, and characters.
