# BoxOS 🚀 Click. Done. Genius.

![BoxOS Logo](https://img.shields.io/badge/BoxOS-v0.0.2-brightgreen.svg) ![Language](https://img.shields.io/badge/Language-C%2FASM-blue.svg) ![Architecture](https://img.shields.io/badge/Architecture-x86__64-red.svg) ![License](https://img.shields.io/badge/License-MIT-yellow.svg)

![image](https://github.com/user-attachments/assets/b15287e1-a85b-457b-bf2e-ed6b8409ef8a)


**BoxOS** - это минималистичная 64-битная операционная система, написанная с нуля на языках ассемблера и C. Проект демонстрирует основы разработки ОС: от загрузки до управления памятью и вывода на экран.

## ✨ Особенности

- 🎯 **Двухстадийный загрузчик** - Stage1 (MBR) + Stage2 (расширенная загрузка)
- 🔧 **64-битная архитектура** - полная поддержка Long Mode (x86-64)
- 🖥️ **VGA текстовый режим** - цветной вывод с поддержкой прокрутки
- 🧠 **Управление памятью** - настройка страничной адресации для Long Mode
- ⚡ **Минимальное ядро** - базовая функциональность без лишнего кода
- 🎨 **Цветная консоль** - поддержка 16 цветов VGA палитры

## 🏗️ Архитектура

```
BoxOS Structure:
├── Stage1 (MBR)      - Первичный загрузчик (512 байт)
├── Stage2            - Вторичный загрузчик (переход в Long Mode)  
└── Kernel            - Основное ядро системы (64-bit)
```

### Процесс загрузки:
1. **BIOS** загружает Stage1 (MBR) по адресу `0x7C00`
2. **Stage1** загружает Stage2 с диска в память `0x8000`
3. **Stage2** включает A20, настраивает GDT, загружает ядро
4. **Stage2** переходит в Protected Mode → Long Mode
5. **Kernel** запускается в 64-битном режиме по адресу `0x10000`

## 🛠️ Сборка и запуск

### Требования:
- Linux (протестировано на Ubuntu/WSL)
- NASM (Netwide Assembler)
- GCC (GNU Compiler Collection)
- GNU Binutils (ld, objcopy)
- QEMU (для эмуляции)

### Установка зависимостей:
```bash
# Ubuntu/Debian
sudo apt update
sudo apt install nasm gcc binutils qemu-system-x86 make

# Или используйте автоматическую установку:
make install-deps
```

### Сборка:
```bash
# Проверка зависимостей
make check-deps

# Полная сборка
make all

# Сборка и запуск
make run

# Отладка с GDB
make debug
```

### Структура файлов:
```
boxos/
├── Makefile              # Система сборки
├── start.sh              # Скрипт быстрого запуска
├── build/                # Выходные файлы
│   ├── stage1.bin       # Скомпилированный Stage1
│   ├── stage2.bin       # Скомпилированный Stage2  
│   ├── kernel.bin       # Скомпилированное ядро
│   └── boxos.img        # Загрузочный образ диска
├── src/
│   ├── boot/            # Загрузчики
│   │   ├── stage1/      # MBR загрузчик
│   │   └── stage2/      # Вторичный загрузчик
│   ├── kernel/          # Ядро системы
│   │   ├── kernel.c     # Основной код ядра
│   │   ├── kernel_entry.asm # Точка входа в ядро
│   │   └── linker.ld    # Скрипт компоновщика
│   └── lib/             # Библиотеки (будущее расширение)
└── docs/                # Документация
```

## 🎮 Использование

После запуска `make run` вы увидите:

```
BoxOS Stage1 Loading...
Jumping to Stage2...
BoxOS Stage2 Started
A20 line enabled
Loading kernel...
Kernel loaded
=================================
        BoxOS Kernel v1.0        
=================================

Kernel loaded successfully!
64-bit mode active
VGA text mode initialized

Testing output functions:
Decimal: 12345
Hexadecimal: 0x00000000DEADBEEF

Color changed to cyan!
Color changed to magenta!
Color changed to white!

Testing screen scrolling...
Line 1 - Testing screen scrolling functionality
Line 2 - Testing screen scrolling functionality
...
```

## 🔧 Технические детали

### Память:
- **0x7C00**: Stage1 (MBR)
- **0x8000**: Stage2 загрузчик  
- **0x10000**: Ядро системы
- **0x70000-0x77000**: Таблицы страниц для Long Mode
- **0x90000**: Стек системы

### Регистры и режимы:
- Переход: **Real Mode** → **Protected Mode** → **Long Mode**
- GDT с поддержкой 32-bit и 64-bit сегментов
- Страничная адресация с 2MB страницами

### VGA текстовый режим:
- Разрешение: 80x25 символов
- 16 цветов фона и текста
- Автоматическая прокрутка экрана

## 🚀 Планы развития

- [ ] **Прерывания** - обработка клавиатуры и таймера
- [ ] **Файловая система** - простая FS для загрузки программ
- [ ] **Многозадачность** - базовое переключение задач
- [ ] **Драйверы** - поддержка различных устройств
- [ ] **Системные вызовы** - интерфейс для пользовательских программ
- [ ] **GUI** - графический интерфейс пользователя

## 🤝 Вклад в проект

Проект открыт для вкладов! Если у вас есть идеи или исправления:

1. Сделайте Fork репозитория
2. Создайте ветку для ваших изменений
3. Внесите изменения и протестируйте
4. Создайте Pull Request

## 📚 Обучающие ресурсы

Если вы хотите изучить разработку ОС (отсюда брались данные для написания):
- [OSDev Wiki](https://wiki.osdev.org/) - отличный ресурс для начинающих
- [Intel x86-64 Manual](https://software.intel.com/content/www/us/en/develop/articles/intel-sdm.html)
- [NASM Documentation](https://nasm.us/docs.php)

## 📄 Лицензия

Этот проект распространяется под лицензией MIT. См. файл `LICENSE` для подробностей.

## 👨‍💻 Автор: skripsaha

Создано skripsaha с ❤️ и большим количеством кофе☕

---

**BoxOS** - это не просто код, это путешествие в мир низкоуровневого программирования! 🌟

*"В каждом программисте живет мечта создать свою операционную систему"*
