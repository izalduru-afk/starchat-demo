# StarChat — Demo App

A clickable Android demo of StarChat for presentations. It runs entirely on the phone with sample data: messages you send appear on screen but are not delivered to anyone.

## Download the APK

Open the **Releases** section of this repository (right side of the main page) and download `StarChat-demo.apk` from the latest release. On the phone, allow "Install unknown apps" for your browser or file manager when asked.

## What's in the demo

- Sign in with Google (simulated) and complete your profile (name, username, date of birth, bio)
- Home: Chats and Groups tabs
- Private chat and group chat with announcements (simulated replies)
- Create a group with its own link (`starchat.app/<name>`), find groups, and join them
- Contacts: Following, Followers, and Blocked (with unblock)
- My profile, other users' profiles (Follow, Message, Block)

## How the APK is built

Every push to `main` runs the **Build APK** workflow (`.github/workflows/build-apk.yml`), which builds the app with Flutter and attaches the APK to a new release.
