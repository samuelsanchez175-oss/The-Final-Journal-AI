# Speech Recognition Permission Setup

## Required Info.plist Key

To enable on-device speech recognition, you must add the following key to your app's Info.plist:

**Key**: `NSSpeechRecognitionUsageDescription`
**Type**: String
**Value**: "This app needs access to speech recognition to transcribe audio recordings."

## How to Add in Xcode

1. Open your project in Xcode
2. Select your app target
3. Go to the "Info" tab
4. Click the "+" button to add a new key
5. Search for or manually add: `Privacy - Speech Recognition Usage Description`
6. Set the value to: "This app needs access to speech recognition to transcribe audio recordings."

Alternatively, if you have an Info.plist file:
1. Open `Info.plist` as source code
2. Add the following entry:
```xml
<key>NSSpeechRecognitionUsageDescription</key>
<string>This app needs access to speech recognition to transcribe audio recordings.</string>
```

## Note

The app will request this permission automatically when the user first imports an audio file. The permission is required for on-device transcription using Apple's Speech framework.
