# Background Audio Setup Instructions

## Enable Background Modes in Xcode

To allow your Planet ProTrader app to play the interstellar theme in the background:

### 1. Open Your Xcode Project
- Select your project in the navigator
- Select your app target

### 2. Enable Background Modes
- Go to the "Signing & Capabilities" tab
- Click the "+ Capability" button
- Search for and add "Background Modes"

### 3. Configure Background Audio
- Check the "Audio, AirPlay, and Picture in Picture" option
- This allows your app to continue playing audio when backgrounded

### 4. Info.plist Configuration (Automatic)
Xcode will automatically add this to your Info.plist: