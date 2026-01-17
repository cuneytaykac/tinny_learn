# TinyLearners MVP Task List

## Setup & Infrastructure
- [x] Initialize Flutter project `tiny_learners`
- [x] Configure `assets` directory structure (images, audio)
- [x] Add dependencies (`provider`, `audioplayers`, `flutter_svg` (if needed), `shared_preferences`)

## Core Features (MVP)
- [x] **Data Model**: specific classes for `Category`, `LearningItem` (name, imagePath, audioPath, shadowPath)
- [x] **State Management**: `GameProvider` to handle unlocked categories and progress
- [x] **Main Menu**:
    - [x] Category Selector (Animals, Vehicles, etc.)
    - [x] Lock mechanism for premium categories
- [ ] **Game Modes**:
    - [x] **Flashcards Mode**: Swipable cards with audio (Refining visuals & interactions)
    - [x] **Quiz Mode**: "Find the [Item]" logic (Completed with Audio & Confetti)
    - [ ] **Shadow Match Mode**: Drag and drop logic
    - [ ] **Surprise Egg**: Simple tap-to-reveal animation

## UI/UX
- [x] Create a "Kid-Friendly" theme (colors, fonts, big buttons)
- [x] Implement smooth page transitions

## Assets
- [x] Generate/Place placeholder images for Animals & Vehicles
- [x] **Audio**: 
    - [x] Implement Text-to-Speech for names (Tr/En)
    - [x] Add placeholder files for animal sounds
