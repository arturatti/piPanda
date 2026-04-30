# Промпт для генерации картинок темы «Рептилии»

## Назначение
Картинки для слов из `words_reptiles.txt` (6 слов: рептилии и амфибия).

## Технические требования
- 1024×1024 PNG, прозрачный/светлый фон (потом обрабатывается через rembg)
- Один объект по центру, занимает 70-80% кадра
- Без текста, без водяных знаков

## Стиль
Тот же стиль что в `image_prompt.md` и `image_prompt_dinosaurs.md` — единая визуальная вселенная:
- **flat illustration for children**, soft rounded shapes
- warm pastel colour palette (мятные, коралловые, жёлтые, лавандовые тона)
- gentle outline, friendly cute style
- picture book style, age 4-7
- minimalist composition, clean vector look
- single object centered on plain white background, no shadows on background
- **baby / cartoon / chibi proportions** — крупная голова, добрые большие глаза, без агрессии

## Универсальный промпт-шаблон
```
A {object_en}, flat illustration for children, soft rounded shapes,
warm pastel color palette, gentle outline, friendly cute style,
single object centered on plain white background, no text, no shadows on background,
picture book style, age 4-7, minimalist composition, clean vector look, 1024x1024
```

## Список картинок к генерации

| Слово | Файл | Объект (для промпта) |
|---|---|---|
| Дракон | drakon.png | a cute friendly cartoon baby dragon, smiling, small wings, pastel mint green, big friendly eyes, chibi proportions |
| Крокодил | krokodil.png | a cute baby cartoon crocodile, smiling, soft pastel sage green, friendly look, chibi proportions |
| Игуана | iguana.png | a cute baby iguana lizard, soft pastel mint green skin with gentle spikes on back, friendly smile, chibi proportions |
| Ящерица | yashcheritsa.png | a cute small cartoon lizard, pastel coral colors, big friendly eyes, sitting, chibi proportions |
| Черепаха | cherepaha.png | a cute baby turtle, pastel green shell with hexagon pattern, friendly smile, chibi proportions |
| Лягушка | lyagushka.png | a cute baby frog, pastel mint green, big friendly eyes, sitting on lily pad, chibi proportions |

## Постобработка
1. Прогнать через `tool/remove_bg.py assets/images/words/reptiles assets/images/words/reptiles/_nobg`
2. Перенести из `_nobg/` в `assets/images/words/reptiles/`
3. Удалить временную `_nobg/`
