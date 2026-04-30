# Handoff: контент для piPanda

## Цель документа

Чёткое разделение того, что **генерит пользователь через Antigravity (нанобанана)** и что **делает Claude в коде**.

## Принцип разделения

- **Код** — все что про логику, верстку, навигацию, состояние, парсеры, плееры, темы цветов, fallback. Любая часть, которую можно делать без визуального/звукового контента.
- **Контент** — все что про реальную графику, аудио, голос. Файлы, которые лежат в `assets/`.

Код запускается и работает БЕЗ контента — на placeholder'ах. Контент подкладывается параллельно.

---

## Текущее состояние (2026-04-30)

| Контент | Статус | Кто делает |
|---|---|---|
| 35 картинок слов | ⏳ ждёт | Antigravity |
| Иконка приложения | ⏳ ждёт | Antigravity |
| 3 фона (home/game/victory) | ⏳ ждёт | Antigravity |
| Аудио слогов (46 mp3) | ✅ готово | сгенерил Claude через edge-tts (`tool/generate_audio.py`) |
| Аудио слов (35 mp3) | ✅ готово | сгенерил Claude через edge-tts |
| UI-звуки (3 wav) | ✅ готово | сгенерил Claude через `tool/generate_ui_sounds.py` (синтез numpy) |
| Фоновая музыка | ⏳ опц. | Pixabay/Mubert (вручную скачать) |

**Голос для TTS:** `ru-RU-SvetlanaNeural` (Microsoft Edge TTS, женский, дружелюбный, бесплатно). Если хочешь заменить на студийную запись — просто положи свои mp3 поверх (имена сохраняются).

**UI-звуки** сейчас — простые синусоидальные плейсхолдеры. По желанию замени на качественные SFX из Pixabay/Mixkit (тогда можно класть mp3 — они приоритетнее, see `audio_service.dart` extension fallback).

---

## ЧАСТЬ 1: КОНТЕНТ (зона Antigravity)

### 1.1 Картинки слов (35 шт)

**Где лежит:** `assets/images/words/<имя>.png`

**Имена и объекты:** см. [image_prompt.md](image_prompt.md) — там полный промпт-шаблон + таблица всех 35 имён файлов и объектов.

**Спецификация:**
- PNG, прозрачный фон
- 1024×1024 px (приложение даунскейлит)
- Один объект по центру, занимает 70-80% кадра
- Без текста на картинке
- Стиль: flat illustration for children, soft rounded shapes, warm pastel palette

### 1.2 Иконка приложения

**Где лежит:** `assets/icon/icon.png`

**Спецификация:**
- PNG, **квадрат 1024×1024**
- Без прозрачности (или с — Android маска применится)
- Узнаваемый «маскот»: панда (т.к. название piPanda)
- Стиль тот же что и картинки слов

**Промпт для нанобанана:**
```
A cute panda head mascot, holding wooden syllable letter blocks "PI",
flat illustration for children, soft rounded shapes, warm pastel palette,
gentle outline, friendly cute style, on white square background,
1024x1024 PNG, app icon style, picture book look
```

### 1.3 Фоны (3 шт)

**Где лежат:** `assets/images/backgrounds/`

| Файл | Назначение | Стиль |
|---|---|---|
| `home.png` | Главный экран (логотип + кнопки) | Тёплый пастельный фон с лёгким паттерном (звёзды, облачка, листья) — не отвлекает от кнопок |
| `game.png` | Игровой экран | Очень светлый/нейтральный — карточки и слоты должны выделяться |
| `victory.png` | Опционально, фон для overlay победы | Праздничный — звёзды, серпантин |

**Спецификация:**
- PNG (или JPG), 1080×1920 (портрет, телефон)
- Если паттерн — он должен быть тонким (10-15% opacity, чтоб не перебивал интерфейс)
- Без UI-элементов, текста, навигации
- Цветовая палитра соответствует теме приложения (см. ниже)

**Палитра приложения (используй в фонах):**
- Главный: `#FFB997` (тёплый персиковый)
- Акцент: `#A0E7E5` (мятный)
- Soft yellow: `#FFE5A0`
- Background: `#FFF5EB` (кремовый)
- Текст: `#3D3A3A`

**Промпт для нанобанана (домашний фон):**
```
Soft pastel children's wallpaper, very light cream background #FFF5EB,
delicate scattered pattern of small clouds, stars, leaves and tiny pandas,
warm peach and mint accents, very low contrast, gentle dreamy mood,
no text, no UI, no objects in foreground, mobile portrait 1080x1920
```

**Промпт для нанобанана (игровой фон):**
```
Very light cream wallpaper #FFF5EB, almost plain with subtle texture,
tiny barely-visible dots and gentle paper grain, no distractions,
no foreground objects, mobile portrait 1080x1920
```

**Промпт для нанобанана (победный фон):**
```
Festive children's celebration wallpaper, scattered confetti,
gold and pink stars, party streamers, very soft pastel,
no text, no characters, mobile portrait 1080x1920
```

### 1.4 Аудио — слоги (60 файлов)

**Где лежит:** `assets/audio/syllables/<key>.mp3`

**Что в файле:** один слог, чётко произнесённый.

**Список ключей (имена файлов):** запусти `dart run tool/check_assets.dart` — выдаст полный список того что не хватает.

**Голос:**
- Женский, мягкий, тёплый
- Темп размеренный (не торопиться)
- Чёткая артикуляция, разборчивость
- Без эмоциональной окраски (просто называние)

**Технические требования:**
- mp3, 128 kbps, mono
- 0.5–1.5 секунды на файл
- Без посторонних шумов и реверберации
- Громкость одинаковая на всех файлах (нормализация -3 dB)

### 1.5 Аудио — слова целиком (35 файлов)

**Где лежит:** `assets/audio/words/<key>.mp3`

**Что в файле:** слово целиком (для режима «На слух» и для подсказки после победы)

**Голос и технические требования:** те же что и слоги.

**Длительность:** 0.5–2.5 секунды.

### 1.6 Аудио — UI-звуки (3-4 файла)

**Где лежат:** `assets/audio/ui/`

| Файл | Контекст | Описание |
|---|---|---|
| `success.mp3` | Все правильно собрано | Короткие фанфары / детская мелодия победы (~1.5–2с) |
| `drop_correct.mp3` | Слог правильно стал в слот | Лёгкий приятный «дзынь» (~0.3с) |
| `drop_wrong.mp3` | Неправильный слог в слот | Мягкий отскок «уфф» — НЕ агрессивный, не «ошибочный сигнал» (~0.4с) |

**Стиль:** дружелюбный, без агрессии, без «провального» тона. Дети должны хотеть пробовать ещё, а не бояться ошибок.

**Где взять:** банки free SFX (Freesound, Pixabay, Mixkit) или AI-генерация. Не сложно найти готовое.

### 1.7 Фоновая музыка (1 файл, опционально)

**Где лежит:** `assets/audio/bgm/loop.mp3`

**Что:** фоновая музыка для главного и игрового экранов. Включается в настройках (по умолчанию выключена, чтобы не раздражать родителя).

**Спецификация:**
- mp3, 128-192 kbps, stereo
- 60–120 секунд, **бесшовно лупится** (важно — иначе будет слышен «щелчок»)
- Громкость на 30-50% ниже голоса (мы прокинем в коде)
- Стиль: мягкая укулеле / маримба / детское фортепиано, без вокала, **позитивный мажор**
- Никаких резких ударных, баса, тревожных нот

**Где взять:** Pixabay Music, Bensound, Mubert (платный) или AI-генерация (Suno, Udio).

---

## ЧАСТЬ 2: КОД (зона Claude)

### 2.1 Уже сделано

- Каркас Flutter, структура папок, парсер словаря
- 5 режимов сложности
- Drag&drop, проверка слогов, подсказка после 3 ошибок
- Конфетти + автопереход на победу
- Сохранение прогресса, экран статистики (звёзды, топ-5 сложных)
- Экран настроек (громкость, эффекты, анимации, сброс)
- Виджеты: WordImage с placeholder, SyllableCard (Draggable), SyllableSlot (DragTarget)
- Тема Nunito + пастельная палитра
- Helper-скрипт `tool/check_assets.dart` — список missing-ассетов

### 2.2 Делается следующим (после этого handoff)

- Переименование на **piPanda** (заголовки UI, Android applicationLabel, package name остаётся `syllables_apk` — он внутренний)
- Поддержка фонов экранов через виджет `ScreenBackground` (с graceful fallback на solid color если файла нет)
- Поддержка фоновой музыки через `BackgroundMusicService` (loop, mute через настройку)
- Тогглы в Settings: «Фоновая музыка вкл/выкл»
- Конфиги для `flutter_launcher_icons` и `flutter_native_splash` (срабатывают когда положишь icon.png)

### 2.3 Финальная сборка (Этап 7) — ждёт твоих действий

- Положить `assets/icon/icon.png` (1024×1024)
- Запустить `flutter pub run flutter_launcher_icons` (сгенерит mipmap'ы)
- Запустить `flutter pub run flutter_native_splash:create` (сгенерит splash)
- Создать keystore: `keytool -genkey -v -keystore upload-keystore.jks -alias upload -keyalg RSA -keysize 2048 -validity 10000`
- Прописать `android/key.properties` (НЕ коммитить)
- `flutter build apk --release`

---

## Workflow генерации в Antigravity

1. Открыть проект `e:\Web\Projects\hobby\syllables_apk` в Antigravity
2. Сослаться на этот handoff: «возьми из `.info/CONTENT_HANDOFF.md` зону `КОНТЕНТ`»
3. Сослаться на промпты:
   - Картинки слов → таблица в `.info/image_prompt.md`
   - Иконка / фоны → промпты в этом файле (раздел КОНТЕНТ)
   - Аудио → спецификация в этом файле + готовые ключи через `dart run tool/check_assets.dart`
4. Класть файлы в указанные пути. Имена строго по таблицам.
5. После генерации (или по ходу) — `dart run tool/check_assets.dart` покажет что осталось.

---

## Что попросить у Antigravity, чтоб не путал

> «Это проект Flutter-приложения piPanda для обучения слоговому чтению. Зону кода веду я и Claude, твоя задача — только графика и аудио по спецификации в `.info/CONTENT_HANDOFF.md`. Не трогай папки `lib/`, `android/`, `ios/`, `pubspec.yaml`. Складывай только в `assets/`. Имена файлов — строго как в таблицах.»
