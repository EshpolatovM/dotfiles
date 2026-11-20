# 🐧 Dotfiles — Sway WM & Developer Environment

Assalomu alaykum!
Linux Sway WM (Wayland) interfeysida birinchi qadam qo'yganlar va dasturchilar uchun to'liq tayyor, qulay va optimallashtirilgan sozlamalar to'plami (Fedora / Arch / Ubuntu Wayland).

---

## 🚀 Tarkibi va Xususiyatlari

- **Sway WM**: Yengil, tezkor va zamonaviy Wayland tiling window manager.
- **Foot Terminal**: Ultra-tezkor Wayland terminal emulyatori (OLED dark mavzu).
- **Neovim (Lazy.nvim)**: Modulli zamonaviy Neovim konfiguratsiyasi (LSP, Treesitter, Telescope, Bufferline, Live Server).
- **Zsh & Powerlevel10k**: Chiroyli va tezkor buyruqlar satri (avtoto'ldirish, syntax highlighting, fzf).
- **Ekran Yozish (wf-recorder)**: Ovoz bilan birga yuqori sifatli video yozish va to'xtatish skriptlari.
- **Ekran Chizish (Gromit-MPX & Wayscriber)**: Dars o'tish, videorolik va taqdimotlar uchun to'g'ridan-to'g'ri ekranga chizish vositalari.
- **Avtomatik Ovoz Boshqaruvi**: Quloqchin (3.5mm jack) ulanganda avtomatik profil almashtirish skripti va mikrafon boshqaruvi.
- **Tmux & Starship & IdeaVim**: Qo'shimcha terminal va JetBrains IDE vim sozlamalari.

---

## ⌨️ Asosiy Qaynoq Tugmalar (Keybindings)

### 🪟 Sway WM Asosiy
| Tugmalar | Vazifasi |
|---|---|
| `Super + Enter` | Foot terminalini ochish |
| `Super + d` | Ilovalar menyusi (`wmenu-run`) |
| `Super + Shift + q` | Oynani yopish |
| `Super + h/j/k/l` | Oynalar bo'ylab harakatlanish |
| `Super + Shift + h/j/k/l` | Oynani siljitish |
| `Super + f` | To'liq ekran (Fullscreen) |
| `Super + Space` | Floating / Tiling rejimiga o'tish |
| `Super + Shift + c` | Sway konfiguratsiyasini qayta yuklash (Reload) |
| `Super + Shift + e` | Sway'dan chiqish (Logout menyusi) |

### 📸 Skrinshot & Ekran Chizish (Annotation)
| Tugmalar | Vazifasi |
|---|---|
| `PrtSc` | Wayscriber ekran chizish overlay rejimini yoqish/o'chirish |
| `Shift + PrtSc` | Belgilangan maydonni skrinshot qilish (`grim` + `slurp`) |
| `Super + F9` | Gromit-MPX ekran chizish rejimini yoqish/o'chirish |
| `Super + Shift + F9` | Ekranni barcha chiziqlardan tozalash (Clear) |
| `Super + F8` / `Super + Shift + F8` | Qaytish (Undo) / Oldinga (Redo) |
| `Super + Ctrl + F9` | Chizmalarni yashirish / ko'rsatish (Visibility) |

### 🎥 Ekran Yozish (Screen Recording)
| Tugmalar | Vazifasi |
|---|---|
| `Super + Shift + V` | Ekran va mikrafon ovozini yozishni boshlash (`wf-record-start`) |
| `Super + Shift + X` | Yozishni xavfsiz to'xtatish va saqlash (`wf-record-stop`) |
> *Yozilgan videolar avtomatik ravishda `~/developer/navi/video/` papkasiga saqlanadi va xabar beriladi.*

### 🔊 Ovoz va Yorqinlik
| Tugmalar | Vazifasi |
|---|---|
| `Fn + Ovoz balandligi` | Ovozni oshirish / pasaytirish / o'chirish |
| `Super + Shift + M` | Garnitura mikrafoni va ichki mikrafon o'rtasida almashish |
| `Fn + Yorqinlik` | Ekran yorqinligini boshqarish (`brightnessctl`) |

---

## 📂 Papkalar Tuzilishi

```text
dotfiles/
├── foot/                  # Foot terminal sozlamalari (foot.ini)
├── git/                   # Git (.gitconfig, .gitignore_global)
├── gromit-mpx/            # Ekranga chizish sozlamalari (gromit-mpx.cfg)
├── ideavim/               # WebStorm / IntelliJ IdeaVim (.ideavimrc)
├── nvim/                  # Modulli Neovim konfiguratsiyasi (lazy.nvim, lsp, treesitter)
│   ├── init.lua
│   ├── lazy-lock.json
│   └── lua/
│       ├── live_server.lua
│       └── plugins/       # colorscheme, editor, lsp, ui, treesitter
├── psql/                  # PostgreSQL CLI sozlamalari (.psqlrc)
├── scripts/               # Yordamchi skriptlar (~/.local/bin ga ulanadi)
│   ├── auto-headphone-switch.sh  # Quloqchin ulanganda avtomatik tovush almashtirish
│   ├── wf-record-start           # Ekranni yozishni boshlash
│   ├── wf-record-stop            # Ekranni yozishni to'xtatish
│   └── ws                        # WebStorm tezkor ishga tushirish skripti
├── starship/              # Starship prompt (starship.toml)
├── sway/                  # Sway WM konfiguratsiyasi va fon rasmi
│   ├── config
│   └── wallpaper.png
├── tmux/                  # Tmux terminal multiplexer (.tmux.conf)
├── wayscriber/            # Wayscriber chizish vositasi (config.toml)
├── zsh/                   # Zsh va Powerlevel10k sozlamalari (.zshrc, .p10k.zsh)
├── install.sh             # Barcha fayllarni avtomatik o'rnatuvchi skript
└── README.md
```

---

## 🛠️ O'rnatish (Installation)

1. **Repozitoriyani klonlash:**
   ```bash
   git clone git@github.com:EshpolatovM/dotfiles.git ~/developer/linux/dotfiles
   cd ~/developer/linux/dotfiles
   ```

2. **O'rnatish skriptini ishga tushirish:**
   ```bash
   chmod +x install.sh
   ./install.sh
   ```

Skript barcha fayllarni `~/.config/`, `~/.local/bin/` va `~/` papkalariga xavfsiz holda (mavjud fayllarni `.bak` qilib zaxiralab) symlink orqali ulaydi.

3. **O'zgarishlarni qo'llash:**
   - Sway'ni qayta yuklash: `Super + Shift + c` yoki `swaymsg reload`
   - Shell'ni yangilash: `exec zsh`
