# Промпт для генерации картинок темы «Динозавры»

## Назначение
Картинки для слов из `words_dinosaurs.txt` (15 реальных динозавров и птеродактилей).

## Технические требования
- 1024×1024 PNG, прозрачный/светлый фон (потом обрабатывается через rembg)
- Один объект по центру, занимает 70-80% кадра
- Без текста, без водяных знаков

## Стиль
Тот же стиль что в `image_prompt.md` — единая визуальная вселенная:
- **flat illustration for children**, soft rounded shapes
- warm pastel colour palette (мятные, коралловые, жёлтые, лавандовые тона)
- gentle outline, friendly cute style
- picture book style, age 4-7
- minimalist composition, clean vector look
- single object centered on plain white background, no shadows on background
- **baby / cartoon / chibi proportions** — крупная голова, добрые большие глаза, без агрессии и зубастых пастей

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
| Раптор | raptor.png | a cute baby velociraptor dinosaur, pastel mint green, friendly smile, big eyes, small claws, chibi proportions |
| Динозавр | dinozavr.png | a cute generic baby dinosaur, pastel green, friendly smile, big eyes, simple cartoon style, chibi proportions |
| Стегозавр | stegozavr.png | a cute baby stegosaurus dinosaur, pastel olive green, friendly smile, plates on back, chibi proportions |
| Бронтозавр | brontozavr.png | a cute baby brontosaurus dinosaur, long neck, pastel sage green, friendly smile, big eyes, chibi proportions |
| Аллозавр | allozavr.png | a cute baby allosaurus dinosaur, pastel ochre, friendly smile, small front arms, chibi proportions |
| Спинозавр | spinozavr.png | a cute baby spinosaurus dinosaur, pastel teal blue, sail on back, friendly smile, chibi proportions |
| Диплодок | diplodok.png | a cute baby diplodocus dinosaur, very long neck and tail, pastel beige, friendly smile, chibi proportions |
| Тарбозавр | tarbozavr.png | a cute baby tarbosaurus dinosaur, pastel rust orange, big head, friendly smile, chibi proportions |
| Карнозавр | karnozavr.png | a cute baby carnosaurus dinosaur, pastel coral, friendly smile, big eyes, chibi proportions |
| Гадрозавр | gadrozavr.png | a cute baby hadrosaurus duck-billed dinosaur, pastel mustard yellow, friendly smile, chibi proportions |
| Тираннозавр | tirannozavr.png | a cute baby tyrannosaurus rex, pastel forest green, big head, tiny arms, friendly smile, chibi proportions |
| Трицератопс | tritseratops.png | a cute baby triceratops dinosaur, pastel terracotta, three small horns, neck frill, friendly smile, chibi proportions |
| Птеродактиль | pterodaktil.png | a cute baby pterodactyl pterosaur, pastel lavender purple, big wings spread, friendly smile, chibi proportions |
| Анкилозавр | ankilozavr.png | a cute baby ankylosaurus dinosaur, armored back with plates, pastel olive, club tail, friendly smile, chibi proportions |
| Дилофозавр | dilofozavr.png | a cute baby dilophosaurus dinosaur, two crests on head, pastel turquoise, friendly smile, chibi proportions |

## Постобработка
1. Прогнать через `tool/remove_bg.py assets/images/words/dinosaurs assets/images/words/dinosaurs/_nobg`
2. Перенести из `_nobg/` в `assets/images/words/dinosaurs/`
3. Удалить временную `_nobg/`
