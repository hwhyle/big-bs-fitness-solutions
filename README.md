# Big B's Fitness Solutions

iPhone fitness app built with **SwiftUI**.

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

## App overview

Tab-based starter UI:

| Tab | Description |
|-----|-------------|
| **Home** | Welcome screen and weekly quick stats |
| **Workouts** | Sample workout list with detail screens |
| **Progress** | Placeholder weekly activity chart |
| **Profile** | Placeholder athlete profile card |

## Project layout

```
BigBsFitnessSolutions/
  BigBsFitnessSolutionsApp.swift
  ContentView.swift
  Features/
    Home/
    Workouts/
    Progress/
    Profile/
  Models/
  Assets.xcassets/
BigBsFitnessSolutions.xcodeproj/
```

## Bundle ID

`com.hwhyle.BigBsFitnessSolutions`
