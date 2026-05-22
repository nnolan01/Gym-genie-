# GymGenie — iOS Share-to-Workout App

## What this is
An iOS app that lets you share any video/article from Instagram, TikTok, YouTube, Safari, or any app via the iOS Share Sheet. The app sends the content to OpenAI GPT-4o and generates a structured gym workout program.

## File Structure
```
GymGenie/
├── GymGenie.xcodeproj          ← Xcode project (open this in Xcode)
├── GymGenie/
│   ├── App/GymGenieApp.swift
│   ├── Models/
│   ├── Services/
│   ├── Views/
│   └── ViewModels/
├── ShareExtension/              ← iOS Share Extension
├── Config/                      ← Entitlements
└── codemagic.yaml               ← Codemagic CI/CD config
```

## Setup

### Option A: Codemagic (No Mac needed)
1. Push this repo to GitHub
2. Go to codemagic.io → Add Application → select this repo
3. Go to Settings → Code signing → connect your Apple Developer account
4. Tap "Start new build"
5. Codemagic builds on a cloud Mac and uploads to TestFlight

### Option B: Xcode (Mac required)
1. Open `GymGenie.xcodeproj` in Xcode
2. Sign in with your Apple ID in Xcode Preferences → Accounts
3. Select the GymGenie target → Signing & Capabilities → select your team
4. Update `AppConstants.swift` with your OpenAI API key
5. Product → Archive → Distribute App → Upload

## Requirements
- Apple Developer Account ($99/yr) — required for TestFlight
- OpenAI API key — get at platform.openai.com

## Before building
1. Update bundle ID in `codemagic.yaml` and project settings from `com.yourcompany.gymgenie` to your own
2. Update App Group ID in `AppConstants.swift` and entitlements files
3. Add your OpenAI API key in `GymGenie/Models/AppConstants.swift`
