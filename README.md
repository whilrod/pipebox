# 🎧 Pipebox Music Mixer

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter)](https://flutter.dev/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS%20%7C%20Web-lightgrey)](https://flutter.dev/multi-platform/)

🎛️ An interactive drag-and-drop music creation app inspired by **Incredibox**, built with **Flutter & Dart**. Assign sound loops to characters, mix beats in real-time, and create unique audio compositions.

---

## 🖼️ Preview

> 💡 
><img width="570" height="264" alt="pipebox" src="https://github.com/user-attachments/assets/df708983-843f-444a-9f69-0072d1061aa2" />

---

## ✨ Features

- 🎭 **7 Interactive Characters** with idle, hover, and playing states
- 🎛️ **14 Draggable Sound Selectors** to assign custom audio loops
- 🔊 **Simultaneous Playback** – Clean mixing with independent `AudioPlayer` instances
- 🔇 **Per-Character Mute/Unmute** – Toggle volume without stopping the loop
- 🖼️ **Modern UI** – Responsive frames, hover effects, and landscape-optimized layout
- ℹ️ **Built-in Tutorial** – Info popup with step-by-step instructions
- 📱 **Landscape-First** – Enforced orientation for tablet/desktop experience

---

## 🎮 How to Play

1. **Drag** a sound selector 🎛️ onto an empty character 🎭
2. The character starts playing the loop automatically ▶️
3. **Tap the 🔇 icon** on a character to mute/unmute it
4. **Drag the selector off** the character to remove it & stop the sound
5. Mix multiple characters to create your own beat! 🎧

---

## 🛠️ Tech Stack

| Technology | Purpose |
|------------|---------|
| `Flutter` & `Dart` | UI, State Management, Cross-Platform |
| `audioplayers` | Low-latency audio, simultaneous playback, volume control |
| `Material Design 3` | Consistent theming & responsive widgets |
| Custom Drag & Drop | `Draggable` / `DragTarget` with layout preservation |

---

## 📦 Installation & Setup

### 1️⃣ Prerequisites
- Flutter SDK `3.10+`
- Dart `3.0+`
- Android Studio / VS Code with Flutter extension

### 2️⃣ Clone & Install
```bash
git clone https://github.com/TU_USUARIO/flutter-music-mixer.git
cd flutter-music-mixer
flutter pub get


3️⃣ Asset Structure ⚠️ Important
The app expects assets in the following structure:
assets/
├── images/
│   ├── inicial_01.png
│   ├── activo_01.png
│   ├── reproduciendo_01.gif
│   └── selector_01.png
├── sounds/
│   ├── matimassa-drum-loop-trap.mp3
│   ├── reverse-scratch.mp3
│   ├── kick-sample.mp3
│   └── ... (other .mp3 files)
Update pubspec.yaml accordingly:
yaml
flutter:
  assets:
    - assets/images/
    - assets/sounds/
4️⃣ Run
bash
flutter run
⚙️ Audio Configuration
The app uses audioplayers with a custom Android AudioContext to allow true simultaneous playback:
dart
AudioContext(
  android: AudioContextAndroid(
    usageType: AndroidUsageType.media,
    audioFocus: AndroidAudioFocus.none, // 🔑 Allows multiple players
  ),
)
This prevents Android from muting background tracks when a new sound starts.
📁 Project Structure
lib/
├── main.dart          # Entry point & App configuration
├── screens/           # (Optional) HomeScreen logic
└── models/            # (Optional) CharacterConfig & SelectorConfig
pubspec.yaml           # Dependencies & assets
assets/                # Images & audio files
👥 Credits
💡 Concept: Pipe Rodríguez
👨‍💻 Development: whilrod@gmail.com
🎵 Audio Samples: Pixabay Creative Commons
🎨 UI/UX: Custom Flutter implementation inspired by Incredibox
📄 License
This project is licensed under the MIT License – see the LICENSE file for details.
🤝 Contributing
Contributions are welcome! Please follow these steps:
Fork the repository
Create your feature branch (git checkout -b feature/amazing-feature)
Commit your changes (git commit -m 'Add amazing feature')
Push to the branch (git push origin feature/amazing-feature)
Open a Pull Request<img width="570" height="264" alt="pipebox" src="https://github.com/user-attachments/assets/8968333c-4190-4262-920b-a944c93fc18d" />

📬 Contact
📧 whilrod@gmail.com
🌐 pipebox.netlify.com
🐛 Report issues or request features via GitHub Issues
