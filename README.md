<div align="center">
  <h1>Spud Customs</h1>
  <img src="project_management/dist/marketing/LRD_Logo.png" alt="Lost Rabbit Digital Logo" width="200"/>
  <h3>A dystopian document thriller game set in a world of anthropomorphic potatoes</h3>
  
  <p>
    <a href="https://store.steampowered.com/app/3291880/Spud_Customs/"><img src="https://img.shields.io/badge/Steam-Available-blue?style=for-the-badge&logo=steam" alt="Steam"></a>
    <a href="https://lost-rabbit-digital.itch.io/spud-customs"><img src="https://img.shields.io/badge/itch.io-Available-red?style=for-the-badge&logo=itch.io" alt="itch.io"></a>
    <img src="https://img.shields.io/badge/Godot-4.0+-blue?style=for-the-badge&logo=godot-engine" alt="Godot 4.0+">
    <img src="https://img.shields.io/badge/license-MPL_2.0-yellow?style=for-the-badge" alt="MPL 2.0 License">
  </p>
</div>

<div align="center">
  <img src="project_management/dist/images/screenshot_inspector.png" alt="Game Screenshot" width="600"/>
</div>

---

## 📖 About The Game

**Spud Customs** is a dystopian document thriller inspired by "Papers, Please" but with a darkly humorous twist. Players take on the role of a customs officer at the Spudarado border, processing documents and making critical decisions while uncovering a deeper conspiracy involving the potato world.

In this world of anthropomorphic potatoes, your job is to:
- ✅ Verify potato passports and documents
- 📜 Enforce ever-changing immigration rules
- ⏱️ Make split-second decisions under time pressure
- 🚀 Use missiles to prevent unauthorized border crossings
- 🔍 Navigate moral choices and uncover the truth

<div align="center">
  <img src="project_management/dist/images/screenshot_tree.png" alt="Game Screenshot" width="600"/>
</div>

---

## 🎮 Features

<table>
  <tr>
    <td width="50%">
      <h3>📄 Document Processing</h3>
      <p>Examine passports for inconsistencies and rule violations</p>
    </td>
    <td width="50%">
      <h3>⚖️ Dynamic Rules</h3>
      <p>New immigration rules each shift challenge your attention to detail</p>
    </td>
  </tr>
  <tr>
    <td width="50%">
      <h3>💣 Border Security</h3>
      <p>Stop unauthorized potatoes from crossing with air-to-surface missiles</p>
    </td>
    <td width="50%">
      <h3>📚 Story Mode</h3>
      <p>Experience a satirical narrative with multiple endings</p>
    </td>
  </tr>
  <tr>
    <td width="50%">
      <h3>🔄 Endless Mode</h3>
      <p>Test your skills with progressively difficult challenges</p>
    </td>
    <td width="50%">
      <h3>🏆 Steam Integration</h3>
      <p>Achievements, leaderboards, and cloud saves</p>
    </td>
  </tr>
</table>

---

## 🚀 Getting Started

### Prerequisites

<div align="center">
  <table>
    <tr>
      <td align="center"><img src="https://godotengine.org/assets/press/icon_color.svg" width="48"/></td>
      <td><a href="https://godotengine.org/download">Godot Engine 4.0+</a></td>
    </tr>
    <tr>
      <td align="center"><img src="https://git-lfs.github.com/images/thumbnail.png" width="48"/></td>
      <td><a href="https://git-lfs.github.com/">Git LFS</a> (for handling large assets)</td>
    </tr>
  </table>
</div>

### Installation

```bash
# Clone the repository
git clone https://github.com/lost-rabbit-digital/spud-customs.git

# Change to project directory
cd spud-customs

# Pull LFS files
git lfs pull

# Open the project in Godot
godot -e
```

---

## 🏗️ Project Structure

<details>
  <summary>Click to expand</summary>
  
  ```
  spud-customs/
  ├── assets/              # Game assets (sprites, audio, etc.)
  ├── scenes/              # Game scenes
  │   ├── main/            # Main game scenes
  │   ├── ui/              # UI scenes
  │   └── menus/           # Menu scenes
  ├── scripts/             # GDScript files
  │   ├── core/            # Core game systems
  │   ├── managers/        # Game managers
  │   └── entities/        # Game entities
  ├── addons/              # Godot plugins
  ├── project_management/  # Project documentation and planning
  └── export/              # Export configuration
  ```
</details>

---

## 🔧 Development

<table>
  <tr>
    <td width="33%" align="center">
      <h3>🧩 Code Style</h3>
      <p>We follow the <a href="https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_styleguide.html">GDScript style guide</a></p>
    </td>
    <td width="33%" align="center">
      <h3>🌿 Branches</h3>
      <p><code>main</code>, <code>develop</code>,<br><code>feature/X</code>, <code>bugfix/X</code></p>
    </td>
    <td width="33%" align="center">
      <h3>🔄 Workflow</h3>
      <p>Fork → Branch → Commit → PR</p>
    </td>
  </tr>
</table>

---

## 📝 Roadmap

<div align="center">
  <table>
    <tr>
      <th colspan="2">In Development - Version 1.0.3</th>
    </tr>
    <tr>
      <td>✨ Visual Effects Improvements</td>
      <td>🎯 Enhanced Feedback Systems</td>
    </tr>
    <tr>
      <td>🎲 Minigame Expansion</td>
      <td>🛠️ Technical Improvements</td>
    </tr>
    <tr>
      <th colspan="2">Future Plans</th>
    </tr>
    <tr>
      <td>🌐 Localization Support</td>
      <td>📱 Mobile Adaptation</td>
    </tr>
    <tr>
      <td>🧩 Additional Content</td>
      <td>👥 Multiplayer Exploration</td>
    </tr>
  </table>
</div>

See our [project board](https://github.com/lost-rabbit-digital/spud-customs/projects) for the full development roadmap.

---

## 📚 Documentation

<div align="center">
  <a href="project_management/spud_customs_design_document.md">
    <img src="https://img.shields.io/badge/Game_Design_Document-blue?style=for-the-badge" alt="GDD">
  </a>
  <a href="project_management/new_features/">
    <img src="https://img.shields.io/badge/Feature_Implementation-orange?style=for-the-badge" alt="Features">
  </a>
  <a href="project_management/testing/">
    <img src="https://img.shields.io/badge/Testing_Procedures-darkgreen?style=for-the-badge" alt="Testing">
  </a>
</div>

---

## 📜 License

<div align="center">
  <a href="LICENSE">
    <img src="https://img.shields.io/badge/License-MPL_2.0-yellow.svg?style=for-the-badge" alt="License: MPL 2.0">
  </a>
  <p>This project is licensed under the MPL 2.0 License - see the <a href="LICENSE">LICENSE</a> file for details.</p>
</div>

---

## 👨‍💻 Team

<div align="center">
  <table>
    <tr>
      <td align="center"><img src="https://github.com/dmchaledev.png" width="100px;" alt=""/><br /><sub><b>David</b></sub></td>
      <td>Developer<br><a href="https://github.com/dmchaledev">GitHub</a></td>
    </tr>
    <tr>
      <td align="center"><img src="https://github.com/BodenMcHale.png" width="100px;" alt=""/><br /><sub><b>Boden</b></sub></td>
      <td>Developer<br><a href="https://github.com/BodenMcHale">GitHub</a> | <a href="https://www.bodenmchale.com/">Website</a></td>
    </tr>
    <tr>
      <td align="center"><img src="project_management/dist/marketing/LRD_Logo.png" width="100px;" alt=""/><br /><sub><b>Lost Rabbit Digital</b></sub></td>
      <td>Development Team<br><a href="https://lostrabbitdigital.com">Website</a></td>
    </tr>
  </table>
</div>

---


<div align="center">
  <table>
    <tr>
      <td align="center"><img src="project_management/dist/marketing/discord_card.png" alt="Discord Community" width="500"></td>
    </tr>
    <tr>
      <td align="center">
        <h3>Join our community!</h3>
        <p>Chat with developers, share strategies, report bugs, and get the latest updates on out games and plugins</p>
        <a href="https://discord.gg/Y7caBf7gBj">Join the Lost Rabbit Digital Server →</a>
      </td>
    </tr>
  </table>
</div>

### Why Join Our Discord?

- 💬 **Direct Developer Access** - Chat with the team and influence development
- 🎮 **Community Events** - Participate in challenges and events
- 🔍 **Early Updates** - Be the first to know about new features and patches
- 🐛 **Bug Reports** - Help us improve by reporting issues
- 🥔 **Spud Stories** - Share your best (or worst) border control experiences

### Bluesky
<div align="center">
  <table>
    <tr>
      <td align="center"><a href="https://bsky.app/profile/bodengamedev.bsky.social">@BodenGameDev</a></td>
      <td align="center"><a href="https://bsky.app/profile/heartcoded.bsky.social">@HeartCoded</a></td>
    </tr>
  </table>
</div>

---

## 🙏 Acknowledgements

<div align="center">
  <table>
    <tr>
      <td align="center">👥</td>
      <td>Special thanks to our <a href="project_management/user_feedback/special_thanks.md">community contributors</a></td>
    </tr>
    <tr>
      <td align="center">🎮</td>
      <td><a href="https://godotengine.org/">Godot Engine</a></td>
    </tr>
    <tr>
      <td align="center">📝</td>
      <td><a href="https://papersplea.se/">Papers, Please</a> for inspiration</td>
    </tr>
    <tr>
      <td align="center">📊</td>
      <td><a href="https://github.com/Maaack/Godot-Menus-Template">Maaack's Godot Menus Template</a> - Menu system foundation</td>
    </tr>
    <tr>
      <td align="center">🎲</td>
      <td>All our players and testers</td>
    </tr>
  </table>
</div>

---

<div align="center">
  <img src="project_management/dist/marketing/splashscreen.png" alt="Spud Customs" width="400"/>
  <h3>Made with 🥔 by Lost Rabbit Digital</h3>
</div>