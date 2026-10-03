# Big B's Fitness Solutions

iPhone fitness app built with **SwiftUI** and **SwiftData**.

## Requirements

- macOS with **Xcode 15+**
- iOS **17.0+** deployment target
- Apple ID for Simulator / device signing

## Open in Xcode

```bash
git clone https://github.com/hwhyle/big-bs-fitness-solutions.git
cd big-bs-fitness-solutions
open BigBsFitnessSolutions.xcodeproj
```

1. Select the **BigBsFitnessSolutions** scheme.
2. Choose an iPhone Simulator (or your device).
3. Press **Run** (⌘R).

If Xcode asks you to select a development team, open the target → **Signing & Capabilities** and pick your Apple ID team.

## What it does

A repeating weekly schedule. Each weekday gets a workout type: Push, Pull, Legs, HIIT, Cardio, Full body, Rest, or Custom. On training days you build the workout in order:

- Recommended machines match the day's type and fill muscle groups you have not added yet.
- Search the gym catalog, or add a custom machine.
- Remove or reorder machines.
- For each machine, log sets as the same weight, a custom weight per set, or a progression (start at 50 lb, 3 sets, +10 lb). The screen shows the resulting loads.

Plans are stored on device with SwiftData.

## App overview

| Tab | Description |
|-----|-------------|
| **Home** | Today's workout type and ordered set plan |
| **Schedule** | Week calendar, day type, and workout builder |
| **Profile** | Weekly lineup and on-device storage note |

## Project layout

```
BigBsFitnessSolutions/
  BigBsFitnessSolutionsApp.swift
  ContentView.swift
  Features/
    Home/
    Schedule/
    Profile/
  Models/
  Assets.xcassets/
BigBsFitnessSolutions.xcodeproj/
```

## Bundle ID

`com.hwhyle.BigBsFitnessSolutions`
