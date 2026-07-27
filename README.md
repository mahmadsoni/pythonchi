# 🐍 Pythonchi

**Аз сифр то сатҳи касбӣ** — барномаи мобилии омӯзиши Python барои Android ва iOS, сохта бо Flutter.

![Platform](https://img.shields.io/badge/platform-Android%20%7C%20iOS-blue)
![Flutter](https://img.shields.io/badge/Flutter-3.24-02569B)
![License](https://img.shields.io/badge/license-MIT-green)

---

## 📖 Мундариҷа

1. [Дар бораи барнома](#дар-бораи-барнома)
2. [Функсияҳо](#функсияҳо)
3. [Сохтори лоиҳа](#сохтори-лоиҳа)
4. [Истифода (Насб ва иҷро)](#истифода-насб-ва-иҷро)
5. [GitHub Actions — CI/CD худкор](#github-actions--cicd-худкор)
6. [Build APK (дастӣ)](#build-apk-дастӣ)
7. [Build AAB (дастӣ)](#build-aab-дастӣ)
8. [Release — нашри барнома](#release--нашри-барнома)
9. [Бор кардани лоиҳа аз Termux ба GitHub — қадам ба қадам](#бор-кардани-лоиҳа-аз-termux-ба-github--қадам-ба-қадам)
10. [Илова кардани дарсҳои нав](#илова-кардани-дарсҳои-нав)
11. [Саволҳои маъмул](#саволҳои-маъмул)

---

## Дар бораи барнома

**Pythonchi** барномаест, ки Python-ро аз сифр то сатҳи касбӣ, бо забони тоҷикӣ (ва русӣ, англисӣ) меомӯзонад. Он пурра **offline-first** аст — пас аз насб, дарсҳо бе интернет кор мекунанд. Пешрафти шумо (XP, дараҷа, streak, дарсҳои анҷомёфта) дар дастгоҳи худи шумо, дар маълумотгоҳи маҳаллӣ (SQLite) нигоҳ дошта мешавад.

### Меъмории техникӣ

| Қисм | Технология |
|---|---|
| Забони барномасозӣ | Dart / Flutter 3.24+ |
| State management | Riverpod |
| Маълумотгоҳи маҳаллӣ | Drift (SQLite) |
| Навигатсия | GoRouter |
| Локализатсия | flutter_localizations + ARB (tg/ru/en) |
| Меъморӣ | Clean Architecture (data / domain / presentation) |
| AI | Anthropic Claude API (ихтиёрӣ, бо калиди худи корбар) |
| CI/CD | GitHub Actions |

---

## Функсияҳо

- ✅ 100+ дарси интерактивӣ (модели JSON-и васеъшаванда — дар версияи ҳозира модули "Асосҳои Python" бо 8 дарси пурра тайёр аст, боқимонда бо ҳамин сохтор илова карда мешаванд)
- ✅ Машқҳои амалии коднависӣ бо санҷиши худкор
- ✅ Python Playground (муҳаррири код + иҷрокунандаи offline)
- ✅ Системаи XP, Дараҷа, Daily Streak, Дастовардҳо (Achievements)
- ✅ Рейтинги беҳтаринҳо (Leaderboard)
- ✅ Санҷишҳо (Quiz) бо шарҳи ҳар савол
- ✅ Сертификати анҷомдиҳии курс (бо имконияти мубодила)
- ✅ Ёвари AI: шарҳи код, ислоҳи хато, пешниҳоди беҳтарсозӣ, тавлиди санҷиш
- ✅ Dark Mode / Light Mode — автоматӣ (мисли системаи дастгоҳ) ё дастӣ
- ✅ 3 забон: Тоҷикӣ, Русӣ, English
- ✅ Пурра Offline (ба ғайр аз функсияи AI, ки интернет металабад)

---

## Сохтори лоиҳа

```
pythonchi/
├── android/                    # Конфигуратсияи Android (Gradle)
├── ios/                        # Конфигуратсияи iOS
├── assets/
│   └── lessons/                 # Муҳтавои дарсҳо — JSON (осон барои иловакунӣ)
│       ├── modules.json         # Рӯйхати модулҳо/курсҳо
│       ├── python_basics.json   # Дарсҳои модули "Асосҳо"
│       └── quizzes/             # Санҷишҳо барои ҳар дарс
├── lib/
│   ├── main.dart                # Нуқтаи оғози барнома
│   ├── core/                    # Theme, router, l10n, providers-и умумӣ
│   ├── data/                    # Маълумотгоҳ (Drift) ва repository-ҳо
│   ├── domain/                  # Entity-ҳо ва интерфейсҳои repository
│   └── features/                # Ҳар функсия — папкаи худ (dashboard, lesson, quiz, playground, ...)
├── .github/workflows/           # GitHub Actions — build ва release худкор
├── pubspec.yaml                 # Dependency-ҳо
└── README.md                    # Ин файл
```

---

## Истифода (Насб ва иҷро)

### Талабот
- Flutter SDK 3.24 ё навтар — https://docs.flutter.dev/get-started/install
- Android Studio ё VS Code (барои муҳаррир)
- Барои iOS: Mac бо Xcode

### Қадамҳо

```bash
# 1. Ба папкаи лоиҳа дароед
cd pythonchi

# 2. Dependency-ҳоро насб кунед
flutter pub get

# 3. Файлҳои локализатсияро тавлид кунед (AppLocalizations аз ARB)
flutter gen-l10n

# 4. Файлҳои коди автоматиро тавлид кунед (Drift, Riverpod)
dart run build_runner build --delete-conflicting-outputs

# 5. Барномаро иҷро кунед (дастгоҳ/эмулятор пайваст бошад)
flutter run
```

> ⚠️ **Муҳим:** Қадамҳои 3 ва 4 ҳатмист! Бе онҳо барнома компилятсия намешавад, зеро файлҳои `app_localizations.dart` ва `*.g.dart` (масалан `app_database.g.dart`) худкор тавлид мешаванд ва дар Git захира намешаванд (ба `.gitignore` нигаред).

---

## GitHub Actions — CI/CD худкор

Дар папкаи `.github/workflows/build_and_release.yml` як workflow-и пурра омода аст, ки:

1. Ҳангоми **push ба branch-и `main`** ба таври худкор оғоз мешавад.
2. Flutter ва Java-ро насб мекунад.
3. Dependency-ҳоро мегирад ва коди автоматиро тавлид мекунад.
4. **APK** месозад (`app-release.apk`).
5. **AAB** месозад (`app-release.aab`).
6. Як **GitHub Release** нав эҷод мекунад бо номи версия (масалан `v1.0.5`).
7. Ҳарду файл (APK ва AAB) -ро ба он Release худкор бор мекунад.

Шумо ҳеҷ коре лозим намекунед — танҳо кофист, ки коди худро ба GitHub push кунед!

### Барои имзои расмии Play Store (ихтиёрӣ)

Агар хоҳед, ки APK/AAB бо имзои шахсии худ (на debug-key) сохта шавад, дар GitHub репозиторӣ → **Settings → Secrets and variables → Actions** ин 4 Secret-ро илова кунед:

| Номи Secret | Тавзеҳ |
|---|---|
| `ANDROID_KEYSTORE_BASE64` | Файли keystore-и шумо, дар формати base64 |
| `ANDROID_KEYSTORE_PASSWORD` | Пароли keystore |
| `ANDROID_KEY_ALIAS` | Ном (alias) -и калид |
| `ANDROID_KEY_PASSWORD` | Пароли калид |

Агар ин Secrets-ро танзим накунед — ҳеҷ гап не, workflow бо debug-key кор мекунад ва APK/AAB боз ҳам сохта мешаванд (барои санҷиш комилан кофист).

---

## Build APK (дастӣ)

Агар хоҳед APK-ро дар компютери худ (ё Termux) бидуни GitHub Actions созед:

```bash
flutter build apk --release
```

Файли натиҷа дар ин ҷо пайдо мешавад:
```
build/app/outputs/flutter-apk/app-release.apk
```

---

## Build AAB (дастӣ)

Android App Bundle барои боркунӣ ба Google Play Console истифода мешавад:

```bash
flutter build appbundle --release
```

Файли натиҷа дар ин ҷо пайдо мешавад:
```
build/app/outputs/bundle/release/app-release.aab
```

---

## Release — нашри барнома

Ҳар push ба `main` як Release нав дар саҳифаи **"Releases"**-и репозиторийи шумо эҷод мекунад (тарафи рости саҳифаи асосии GitHub, ё `github.com/Mahmadsoni/<repo>/releases`). Дар он ҷо APK ва AAB омодаанд, то шумо ё корбарони дигар онҳоро мустақим боргирӣ кунанд.

Барои сохтани Release дастӣ (бе push), метавонед аз таби **Actions** → **Build & Release Pythonchi** → **Run workflow** истифода баред.

---

## Бор кардани лоиҳа аз Termux ба GitHub — қадам ба қадам

Ин қисм барои шумо, ки танҳо телефони Android доред, хеле оддӣ шарҳ дода шудааст.

### Қадами 1: Насби Termux ва абзорҳо

```bash
pkg update && pkg upgrade -y
pkg install git -y
```

### Қадами 2: Танзими Git (як маротиба)

```bash
git config --global user.name "Mahmadsoni"
git config --global user.email "email-и_шумо@example.com"
```

### Қадами 3: Сохтани репозиторӣ дар GitHub

1. Ба сайти github.com дароед (тавассути browser-и телефон).
2. Тугмаи **"New repository"**-ро пахш кунед.
3. Номи репозиторӣ гузоред, масалан: `pythonchi`.
4. Онро **Public** ё **Private** гузоред (ихтиёрист).
5. Тугмаи **"Create repository"**-ро пахш кунед.
6. GitHub ба шумо линки репозиториро нишон медиҳад, масалан:
   `https://github.com/Mahmadsoni/pythonchi.git`

### Қадами 4: Сохтани Personal Access Token (барои воридшавӣ)

GitHub дигар парол қабул намекунад — шумо ба "Token" ниёз доред:

1. GitHub → аксри профил (тарафи рост боло) → **Settings**
2. Поёнтар → **Developer settings**
3. **Personal access tokens** → **Tokens (classic)**
4. **Generate new token (classic)**
5. Доираи (scope) `repo`-ро интихоб кунед
6. **Generate token**-ро пахш кунед ва токенро **нусхабардорӣ** кунед (онро дигар бор нишон намедиҳанд!)

### Қадами 5: Кушодани файли ZIP дар Termux

Файли ZIP-и лоиҳаро (ки аз ин чат гирифтед) ба папкаи Download-и телефон интиқол диҳед, баъд:

```bash
# Дастрасӣ ба storage-и телефон аз Termux
termux-setup-storage

# Ба папкаи Download рафтан
cd ~/storage/downloads

# ZIP-ро кушодан (агар "unzip" набошад, аввал онро насб кунед: pkg install unzip -y)
unzip pythonchi.zip -d ~/pythonchi
cd ~/pythonchi
```

### Қадами 6: Бор кардани лоиҳа ба GitHub

```bash
git init
git add .
git commit -m "Аввалин нашри Pythonchi"
git branch -M main
git remote add origin https://github.com/Mahmadsoni/pythonchi.git
git push -u origin main
```

Ҳангоми пурсидани **username**, номи GitHub-и худро (`Mahmadsoni`) нависед.
Ҳангоми пурсидани **password**, ба ҷои парол, **Token**-и қадами 4-ро гузоред.

### Қадами 7: Тамошои сохтани барнома

1. Ба репозиторийи худ дар GitHub дароед.
2. Таби **"Actions"**-ро пахш кунед.
3. Шумо мебинед, ки workflow-и **"Build & Release Pythonchi"** ба таври худкор оғоз шудааст.
4. Тахминан 5-10 дақиқа сабр кунед.
5. Пас аз анҷом, ба таби **"Releases"** гузаред — APK ва AAB-и шумо дар он ҷо омодаанд!

🎉 Табрик! Барномаи шумо ба таври пурра худкор сохта шуд.

---

## Илова кардани дарсҳои нав

Азбаски муҳтавои дарсҳо ҳамчун JSON захира мешавад, шумо метавонед дарсҳои нав илова кунед **бе тағйири коди Dart**:

1. Файли нав дар `assets/lessons/<module_id>.json` созед (масалан `data_structures.json`), бо сохтори мисли `python_basics.json`.
2. `module_id`-ро ба `assets/lessons/modules.json` илова кунед (агар модул нав бошад).
3. Барои санҷиш, файли `assets/lessons/quizzes/<lesson_id>.json` созед.
4. `flutter pub get` ва `flutter run` — тайёр!

Модулҳои зерин дар `modules.json` аллакай сабт шудаанд, аммо ҳоло танҳо "Асосҳои Python" пурра пур карда шудааст — боқимонда (Сохторҳои маълумот, OOP, Сатҳи пешрафта) ҳамчун "ба зудӣ" нишон дода мешаванд, то шумо онҳоро бо ҳамин формат пур кунед.

---

## Саволҳои маъмул

**С: Playground воқеан Python-и пурраро иҷро мекунад?**
Ҷ: Не — барои кор кардани офлайн (бе сервер), барнома як "интерпретатори сабуки" худ дорад, ки зерсоҳаи Python-ро (print, тағйирёбандаҳо, шартҳо, даврҳо, функсияҳо, рӯйхатҳо) дастгирӣ мекунад — маҳз он чизе, ки дар дарсҳо омӯзонда мешавад. Барои дастгирии пурраи Python дар оянда, метавон онро ба як runtime-и воқеӣ (масалан тавассути backend API ё WASM) иваз кард — меъмории коди барнома барои ин тағйирот аллакай омода аст (ниг. `PythonExecutionEngine`).

**С: Функсияи AI бе интернет кор мекунад?**
Ҷ: Не, барои AI (шарҳи код, ислоҳ, тавлиди санҷиш) пайвасти интернет ва калиди API-и Anthropic лозим аст (дар Танзимот ворид карда мешавад). Ҳамаи қисматҳои дигари барнома (дарсҳо, Playground, XP, achievements) пурра offline кор мекунанд.

**С: Чӣ тавр номи барнома/логоро тағйир диҳам?**
Ҷ: Номро дар `pubspec.yaml` (`name:`) ва `android/app/build.gradle` (`applicationId`) тағйир диҳед. Логоро дар `assets/images/logo/app_icon.png` иваз кунед ва фармони зеринро иҷро кунед:
```bash
dart run flutter_launcher_icons
```

---

Бо ❤️ барои омӯзандагони тоҷикзабон сохта шудааст.
