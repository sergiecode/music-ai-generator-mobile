# 🎵 Music AI Generator Mobile

**Created by Sergie Code - Software Engineer & Programming Educator**

A cross-platform mobile app built with Flutter (using Cupertino design) that connects to the Music AI Generator backend service. This is part of a comprehensive AI tools ecosystem for musicians.

---

## 📱 **Project Description**

This Flutter mobile app serves as the client application for the Music AI Generator system. It provides musicians and content creators with an intuitive mobile interface to generate AI-powered music using simple text prompts. The app features a clean Cupertino (iOS-style) design that works seamlessly on both iOS and Android devices.

### **Key Features**
- 🎨 **Clean Cupertino Design** - Native iOS-style interface that works on all platforms
- 🎵 **AI Music Generation** - Generate music from text prompts (e.g., "energetic rock", "relaxing piano")
- ⏱️ **Flexible Duration** - Choose music length from 5 seconds to 5 minutes
- 📊 **Real-time Progress** - Live progress updates during generation
- 📥 **Easy Download** - Direct download links for generated tracks
- 🔄 **Smart Retry** - Automatic server connection checking and retry functionality
- 📱 **Cross-platform** - Works on iOS, Android, and other platforms

---

## 🏗️ **Architecture & Components**

### **Main Components**

#### **1. MusicService (`lib/services/music_service.dart`)**
The core service that handles all backend API communication:
- **Health Checking**: Monitors backend server status
- **Music Generation**: Sends POST requests to `/music/generate` endpoint
- **Status Polling**: Continuously checks generation progress
- **Error Handling**: Comprehensive error management and retry logic

**Key Methods:**
```dart
// Check server health
Future<bool> checkServerHealth()

// Generate music with prompt and duration
Future<MusicGenerationResponse> generateMusic(MusicGenerationRequest request)

// Get current track status
Future<TrackStatus> getTrackStatus(String trackId)

// Stream of status updates
Stream<TrackStatus> pollTrackStatus(String trackId)
```

#### **2. GeneratorPage (`lib/pages/generator_page.dart`)**
The main user interface screen featuring:
- **Prompt Input**: Multi-line text field for music descriptions
- **Duration Slider**: Interactive slider (5-300 seconds)
- **Server Status**: Real-time backend connection indicator
- **Progress Display**: Visual progress bar and track information
- **Download Integration**: Direct integration with device download functionality

#### **3. Main App (`lib/main.dart`)**
The application entry point with:
- **Cupertino Theme**: Consistent iOS-style design system
- **App Configuration**: Title, theme, and navigation setup

### **Backend Integration**

The app connects to the Music AI Generator backend with these endpoints:

```http
POST /music/generate
{
  "prompt": "energetic rock",
  "duration": 60
}

GET /music/status/{track_id}
GET /health
```

**API Base URLs:**
- **Android Emulator**: `http://10.0.2.2:8000`
- **iOS Simulator**: `http://127.0.0.1:8000`
- **Physical Device**: `http://YOUR_COMPUTER_IP:8000`

---

## 🚀 **Installation and Usage**

### **Prerequisites**
- Flutter SDK (3.8.1+)
- Dart SDK
- iOS Simulator / Android Emulator / Physical Device
- Music AI Generator Backend running (see backend repository)

### **Installation Steps**

1. **Clone the repository**
   ```bash
   git clone https://github.com/SergieCODE/music-ai-generator-mobile.git
   cd music-ai-generator-mobile
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure backend URL** (if needed)
   
   Edit `lib/services/music_service.dart` to match your backend setup:
   ```dart
   // For physical device, update to your computer's IP
   static const String baseUrl = 'http://192.168.1.XXX:8000';
   ```

4. **Run the app**
   
   **For iOS:**
   ```bash
   flutter run -d ios
   ```
   
   **For Android:**
   ```bash
   flutter run -d android
   ```
   
   **For any available device:**
   ```bash
   flutter run
   ```

### **Backend Setup**
Make sure the Music AI Generator backend is running:
```bash
# In the backend repository directory
.\start_server.ps1
```

The backend should be accessible at `http://127.0.0.1:8000` with docs at `http://127.0.0.1:8000/docs`.

---

## 💡 **Example Usage**

### **Basic Workflow**

1. **Launch the App**: Open the Music AI Generator on your device
2. **Check Server Status**: Ensure the green "Server Online" indicator is showing
3. **Enter Prompt**: Type your music description in the text field
   ```
   Examples:
   - "energetic rock"
   - "relaxing piano melody for meditation"
   - "upbeat electronic dance music"
   - "acoustic guitar ballad"
   ```
4. **Set Duration**: Use the slider to choose duration (5-300 seconds)
5. **Generate**: Tap "🎵 Generate Music" button
6. **Monitor Progress**: Watch the real-time progress bar
7. **Download**: Once complete, tap "Download Track" to save the music

### **Sample Prompts**
- **Genres**: "jazz", "classical", "rock", "electronic", "folk"
- **Moods**: "energetic", "relaxing", "mysterious", "happy", "melancholic"
- **Instruments**: "piano", "guitar", "violin", "drums", "synthesizer"
- **Combinations**: "energetic rock with electric guitar", "peaceful piano and strings"

---

## 🔧 **Development**

### **Project Structure**
```
lib/
├── main.dart                 # App entry point
├── pages/
│   └── generator_page.dart   # Main UI screen
└── services/
    └── music_service.dart    # Backend API service
```

### **Key Dependencies**
```yaml
dependencies:
  flutter: sdk
  cupertino_icons: ^1.0.8
  http: ^1.1.0                # HTTP client for API requests
  url_launcher: ^6.2.1        # For opening download links
```

### **Development Tips**
- **Hot Reload**: Save files for instant UI updates during development
- **Debug Mode**: Use `flutter run --debug` for development builds
- **Error Logs**: Check console output for API connection issues
- **Network Issues**: Ensure backend is running and accessible from your device

---

## 🚀 **Future Improvements**

### **Planned Features**
- [ ] **Audio Player UI**: Built-in audio player with controls (play, pause, seek)
- [ ] **Local Storage**: Save generated tracks locally on device
- [ ] **History**: Track generation history and favorites
- [ ] **Sharing**: Share generated music via social media or messaging
- [ ] **Multiple Formats**: Support for different audio formats (MP3, WAV, etc.)
- [ ] **Advanced Settings**: Tempo, key, genre preferences
- [ ] **Offline Mode**: Cache functionality for previously generated tracks
- [ ] **User Profiles**: Personal music libraries and preferences
- [ ] **Collaboration**: Share prompts and tracks with other users
- [ ] **Push Notifications**: Alerts when long generations complete

### **Technical Enhancements**
- [ ] **State Management**: Implement Provider/Riverpod for better state handling
- [ ] **Background Processing**: Continue generation when app is backgrounded
- [ ] **Better Error Handling**: More specific error messages and retry strategies
- [ ] **Performance Optimization**: Reduce memory usage and improve responsiveness
- [ ] **Accessibility**: VoiceOver support and accessibility improvements
- [ ] **Internationalization**: Multi-language support
- [ ] **Dark Mode**: Dark theme support
- [ ] **Tablet Support**: Optimized layouts for tablet devices

---

## 🎯 **About the Creator**

**Sergie Code** is a Software Engineer and Programming Educator who creates AI tools for musicians through educational content on YouTube. This project is part of a comprehensive series teaching AI development for the music industry.

### **Connect with Sergie Code**
- 🎥 **YouTube**: Programming tutorials and AI development
- 💻 **GitHub**: Open-source projects and educational repositories
- 🎵 **Mission**: Making AI accessible for musicians and content creators

---

## 🤝 **Contributing**

This project is part of an educational series. Feel free to:
- Report bugs and issues
- Suggest new features
- Submit pull requests for improvements
- Use this code for learning purposes

---

## 📄 **License**

This project is created for educational purposes. Please respect the educational nature of this content and give credit to Sergie Code when using or sharing this code.

---

**🎵 Ready to create amazing AI-generated music on your mobile device! Perfect for musicians, content creators, and anyone interested in AI music generation. 🎵**
