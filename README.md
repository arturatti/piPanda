<div align="center">

<img src="assets/images/mascot/panda_cheer.png" width="220" alt="piPanda mascot" />

# 🐼 piPanda

**Учимся читать по слогам — играя**

Детская Android-игра для дошколят: ребёнок собирает слова из слогов через drag&drop, слышит как звучит каждый слог и каждое слово целиком.

[![Скачать APK](https://img.shields.io/badge/⬇%20Скачать-APK-FF7B5C?style=for-the-badge)](https://github.com/arturatti/piPanda/releases/latest)
[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?style=for-the-badge&logo=flutter)](https://flutter.dev)
[![License: MIT](https://img.shields.io/badge/License-MIT-FFC93C?style=for-the-badge)](LICENSE)

</div>

---

## Что это

piPanda — это образовательное приложение для детей 4–7 лет. Цель — помочь ребёнку перейти от букв к слогам, а от слогов — к чтению целых слов. Без штрафов, таймеров и рекламы. Только тёплая палитра, добрая панда-маскот и понятная механика.

<div align="center">
<img src="assets/images/mascot/panda_idle.png" width="120" />
<img src="assets/images/mascot/panda_smile.png" width="120" />
<img src="assets/images/mascot/panda_think.png" width="120" />
</div>

## Что внутри

### 📚 Три тематических набора слов

| Набор | Что внутри | Слов |
|---|---|---|
| 🌈 **Стандартный** | Знакомые бытовые слова: мама, аптека, ракета, корова, малина… | 35 |
| 🦖 **Динозавры** | Тираннозавр, стегозавр, бронтозавр, диплодок, птеродактиль… | 15 |
| 🐲 **Рептилии** | Дракон, крокодил, игуана, ящерица, черепаха, лягушка | 6 |

### 🎮 Три режима сложности

- **🔆 Базовый** — картинка + слово + слоги
- **🔵 Без картинки** — только слово, надо опираться на чтение
- **💗 На слух** — нет картинки, нет слова, только озвучка

### ✨ Ещё

- Все слова и слоги озвучены живым голосом (Yandex SpeechKit, Marina)
- Подсветка и анимация: текущий слог в слове светится, заполненные становятся зелёными
- Звёздочки за раунд: 3⭐ без ошибок, 2⭐ с ошибкой, 1⭐ с подсказкой
- Прогресс по словам сохраняется локально, родитель видит сложные слова
- Поддержка планшетов (адаптивный layout, landscape/portrait)
- Фоновая музыка с паузой при сворачивании
- Настройка количества слогов в задаче (6/8/10)

## Скачать готовое приложение

APK с подписью лежит в [Releases](https://github.com/arturatti/piPanda/releases). Скачайте и установите на Android-устройство (нужно разрешить установку из неизвестных источников).

## Запустить из исходников

Нужен Flutter SDK 3.11+ и Android toolchain.

```bash
git clone https://github.com/arturatti/piPanda.git
cd piPanda
flutter pub get
flutter run                    # debug на подключенном устройстве
flutter build apk --release    # сборка релизного APK
```

## Структура проекта

```
piPanda/
├── lib/                      # Flutter код
│   ├── models/               # Word, GameMode, WordSet, RoundState, AppSettings
│   ├── screens/              # Home, WordSet/Mode select, Game, Stats, Settings
│   ├── widgets/              # SyllableCard, SyllableSlot, Mascot, CelebrationOverlay
│   ├── services/             # AudioService, BgmService, ProgressService, SettingsService
│   ├── state/                # Riverpod providers + GameNotifier
│   └── theme/                # AppTheme — палитра + Comfortaa
├── assets/
│   ├── data/<set>/words.txt  # Словари по темам в формате  Слово|Сло-ги|картинка.png
│   ├── images/words/<set>/   # Картинки слов
│   ├── images/mascot/        # 4 позы панды
│   ├── images/backgrounds/   # Фоны экранов
│   └── audio/                # Слоги, слова целиком, UI-звуки, фоновая музыка
├── tool/
│   ├── check_assets.dart            # Проверка что все ассеты на месте
│   ├── generate_voice_yandex.py     # TTS для слов и слогов
│   └── remove_bg.py                 # rembg + birefnet для прозрачных PNG
└── .info/                    # Документация (PROJECT.md, words_*.txt, image_prompt_*.md)
```

## Стек

- **[Flutter](https://flutter.dev)** + Dart, целевая платформа Android
- **[Riverpod](https://riverpod.dev)** для состояния
- **[just_audio](https://pub.dev/packages/just_audio)** для воспроизведения mp3/wav
- **[google_fonts](https://pub.dev/packages/google_fonts)** — шрифт Comfortaa
- **[flutter_animate](https://pub.dev/packages/flutter_animate)** + **[confetti](https://pub.dev/packages/confetti)** для анимаций и победного фейерверка
- **[shared_preferences](https://pub.dev/packages/shared_preferences)** + JSON-файл для прогресса
- **[Yandex SpeechKit TTS v3](https://cloud.yandex.com/services/speechkit)** для генерации озвучки (вне приложения, готовые wav в assets)
- **[Gemini](https://gemini.google.com/)** + **[rembg](https://github.com/danielgatis/rembg)** для генерации прозрачных PNG-иллюстраций

## Как добавить новый набор слов

1. Создайте `assets/data/<set_id>/words.txt` в формате `Слово|Сло-ги|filename.png`
2. Положите 1024×1024 PNG в `assets/images/words/<set_id>/`
3. Добавьте `WordSet.<set_id>` в `lib/models/word_set.dart` (название, иконка, цвет, hero-картинка)
4. Сгенерируйте недостающие слоги/слова: `python tool/generate_voice_yandex.py syllables` / `words`
5. Проверьте что всё на месте: `dart run tool/check_assets.dart`

## Лицензия

Код — [MIT](LICENSE). Картинки слов и панды-маскота сгенерированы AI и распространяются вместе с проектом для свободного использования. Звуки UI — [Mixkit](https://mixkit.co/free-sound-effects/) (свободная лицензия).

## Спасибо

Маскот-панда и иллюстрации сгенерированы через Gemini. Озвучка — Yandex SpeechKit (голос Marina, friendly). Звуки UI — Mixkit. Фон-обои детских доодлов — Gemini.

---

<div align="center">
Сделано для одного маленького читателя. Может пригодиться вашему. 🐼
</div>
