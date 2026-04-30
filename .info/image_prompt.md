# Промпт для генерации картинок слов

## Назначение

Все картинки слов должны быть в едином визуальном стиле. Этот файл — единый источник истины для промпта генерации, чтобы любая картинка, добавленная позже, выглядела как часть набора.

> Этот файл — про **картинки слов**. Промпты для **иконки приложения, фонов экранов, фоновой музыки и UI-звуков** см. в [CONTENT_HANDOFF.md](CONTENT_HANDOFF.md).

## Технические требования

- **Формат:** PNG с прозрачным фоном
- **Разрешение:** 1024×1024 (приложение даунскейлит до нужного)
- **Один объект в кадре** (никаких сцен, фонов, контекста)
- **Объект по центру**, занимает ~70-80% кадра
- **Без текста и подписей** — слово отображается отдельно в UI

## Стиль (использовать в промпте дословно)

```
flat illustration for children, soft rounded shapes, warm pastel color palette,
gentle outline, friendly cute style, single object centered on transparent background,
no text, no shadows on background, picture book style, age 4-7,
minimalist composition, clean vector look
```

## Универсальный промпт-шаблон

Скопируй это в Antigravity, подставив `{ОБЪЕКТ}`:

```
A {ОБЪЕКТ}, flat illustration for children, soft rounded shapes,
warm pastel color palette, gentle outline, friendly cute style,
single object centered on transparent background, no text, no shadows on background,
picture book style, age 4-7, minimalist composition, clean vector look,
1024x1024, PNG with transparent background
```

## Список картинок к генерации

Имя файла → промпт-объект (на английском, чтобы AI лучше понимал):

| Слово | Файл | Объект для промпта |
|---|---|---|
| Аптека | apteka.png | a small pharmacy building with a green cross sign |
| Телега | telega.png | a wooden horse cart with two large wheels |
| Карета | kareta.png | a fairytale royal carriage with golden details |
| Ракета | raketa.png | a cute cartoon rocket with flames |
| Дерево | derevo.png | a single round-leaved tree |
| Молоко | moloko.png | a glass bottle of milk |
| Мимоза | mimoza.png | a yellow mimosa flower branch |
| Малина | malina.png | a single raspberry with a green leaf |
| Борода | boroda.png | a friendly bearded face cartoon portrait |
| Овца | ovtsa.png | a fluffy cute sheep |
| Колесо | koleso.png | a single wooden cart wheel |
| Забота | zabota.png | a heart with hands holding it gently |
| Фиалка | fialka.png | a violet flower with green leaves |
| Лама | lama.png | a cute fluffy llama |
| Лиса | lisa.png | a friendly orange fox |
| Собака | sobaka.png | a cute cartoon puppy |
| Курица | kuritsa.png | a friendly hen |
| Рыба | ryba.png | a colorful cartoon fish |
| Радуга | raduga.png | a rainbow with clouds at both ends |
| Панама | panama.png | a sun hat (panama hat) |
| Гора | gora.png | a single snow-capped mountain |
| Мама | mama.png | a smiling mother cartoon portrait |
| Дыня | dynya.png | a yellow melon |
| Корова | korova.png | a friendly spotted cow |
| Ворона | vorona.png | a black cartoon crow |
| Облако | oblako.png | a fluffy white cloud |
| Корона | korona.png | a golden royal crown with gems |
| Сапоги | sapogi.png | a pair of rubber boots |
| Сова | sova.png | a cute owl |
| Каша | kasha.png | a bowl of porridge with a spoon |
| Море | more.png | a stylized wave with the sun |
| Коза | koza.png | a friendly goat |
| Луна | luna.png | a crescent moon with a sleepy face |
| Рябина | ryabina.png | a rowan branch with red berries |
| Гитара | gitara.png | an acoustic guitar |

## Workflow

1. Прогнать список через Antigravity (можно батчем или по одному)
2. Сохранять файлы под именем из колонки **Файл**
3. Класть в `assets/images/words/`
4. Если картинка получилась плохо — перегенерить с тем же промптом несколько раз, выбрать лучшую
5. Если AI не справляется с объектом (например, "Забота" — абстракция) — упростить промпт или заменить объект на более конкретный (например "two hands holding a heart")

## Контроль качества

Перед добавлением в проект проверить:
- Объект узнаваем без подписи (попроси кого-то постороннего сказать что это)
- Стиль соответствует остальным (поставь рядом с уже готовыми)
- Нет фона / фон прозрачный
- Нет текста на картинке
- Объект не обрезан краями
