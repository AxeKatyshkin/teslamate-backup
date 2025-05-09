# TeslaMate Backup

Автоматическое резервное копирование базы данных PostgreSQL для TeslaMate с помощью Docker и `cron`.

---

## 🔧 Особенности

- 🕒 Ежедневный `pg_dump` в 03:00 по серверному времени
- 💾 Сохраняет дампы в `./backups/`
- ♻️ Удаляет резервные копии старше 7 дней
- 📋 Логи `cron` сохраняются в `./backups/logs/cron.log`

---

## 📁 Структура проекта

```
teslamate-backup/
├── Dockerfile.backup         # Образ на базе postgres + cron
├── backup-cron               # Планировщик задач (cron)
├── docker-compose.yml        # Конфигурация Compose
├── entrypoint.sh             # Запуск cron внутри контейнера
├── backups/                  # Папка для резервных копий
│   └── logs/                 # Логи cron
```

---

## 🚀 Установка

```bash
git clone https://github.com/AxeKatyshkin/teslamate-backup.git
cd teslamate-backup

# Создание структуры для логов
mkdir -p backups/logs

# Сборка и запуск
docker-compose build backup
docker-compose up -d backup
```

---

## 🔍 Проверка

```bash
# Проверить, что контейнер работает
docker ps | grep backup

# Посмотреть логи cron
docker logs -f teslamate-backup

# Проверить наличие файлов бэкапа
ls -lh backups/
```

---

## 🧹 Автоматическое удаление

Удаление бэкапов старше 7 дней встроено в `cron`:

```cron
0 3 * * * pg_dump -U teslamate -h database -d teslamate > /backups/teslamate_$(date +\%F_\%H-\%M-\%S).sql && find /backups -type f -name "*.sql" -mtime +7 -delete >> /backups/logs/cron.log 2>&1
```

---

## 📌 Примечания

- Контейнер работает от имени `root` для доступа к `cron`, логам и `pg_dump`.
- Все `.sql` файлы и логи находятся в `.gitignore`.
- Используется стандартный образ `postgres` с установленным `cron`.

---

🛡️ Проект для безопасной, автоматизированной и автономной работы TeslaMate.
