# Структура проекта Lab 6

Этот документ детально описывает структуру файлов и директорий проекта Lab 6, а также назначение каждого компонента.

## Обзор структуры

```
lab6/
├── Документация
│   ├── README.md                      # Основная документация
│   ├── STRUCTURE.md                   # Этот файл - описание структуры
│   ├── QUICK_START.md                 # Краткое руководство по запуску
│   └── IMPLEMENTATION_SUMMARY.md      # Полное описание реализации
│
├── Конфигурация инфраструктуры
│   ├── Vagrantfile                    # Определение виртуальных машин
│   ├── ansible.cfg                    # Конфигурация Ansible
│   ├── deploy.yml                     # Главный playbook для развертывания
│   ├── deploy.sh                      # Скрипт автоматического развертывания
│   └── requirements.yml               # Зависимости Ansible ролей
│
├── Переменные и инвентарь
│   ├── group_vars/
│   │   └── all.yml                    # Общие переменные для всех хостов
│   └── inventories/
│       └── hosts.ini                  # Инвентарь хостов
│
└── Ansible роли
    ├── alertmanager/                  # Роль для Alertmanager
    ├── grafana/                       # Роль для Grafana
    ├── loki/                          # Роль для Loki
    ├── prometheus/                    # Роль для Prometheus
    └── spring_boot_app/               # Роль для Spring Boot приложения
```

## Корневые файлы

### Vagrantfile
**Назначение**: Определяет конфигурацию виртуальных машин для VirtualBox через Vagrant.

**Содержимое**:
- Определение VM `app` (192.168.56.30) - 2GB RAM, 2 CPU
- Определение VM `monitoring` (192.168.56.31) - 4GB RAM, 2 CPU
- Базовый образ: Ubuntu 22.04 (Jammy)
- Настройка приватной сети

**Использование**:
```bash
vagrant up           # Запустить обе VM
vagrant halt         # Остановить VM
vagrant destroy -f   # Удалить VM
```

### ansible.cfg
**Назначение**: Конфигурационный файл Ansible для управления поведением развертывания.

**Параметры**:
- `inventory`: Путь к файлу инвентаря
- `roles_path`: Путь к директории с ролями
- `host_key_checking`: Отключена проверка SSH ключей
- `retry_files_enabled`: Отключены retry файлы
- `become`: Настройки повышения привилегий (sudo)

### deploy.yml
**Назначение**: Главный Ansible playbook, который оркестрирует развертывание всех компонентов.

**Структура**:
```yaml
# Развертывание приложения на app сервере
- hosts: app
  roles:
    - spring_boot_app

# Развертывание мониторинга на monitoring сервере
- hosts: monitoring
  roles:
    - prometheus
    - alertmanager
    - grafana
    - loki
```

**Использование**:
```bash
ansible-playbook -i inventories/hosts.ini deploy.yml
```

### deploy.sh
**Назначение**: Автоматизированный скрипт для полного развертывания инфраструктуры.

**Функциональность**:
1. Проверка наличия Vagrant и Ansible
2. Запуск виртуальных машин
3. Проверка подключения к VM
4. Запуск Ansible playbook
5. Вывод информации о доступе к сервисам

**Использование**:
```bash
./deploy.sh
```

### requirements.yml
**Назначение**: Определяет зависимости Ansible ролей для Ansible Galaxy.

**Содержимое**: Список локальных ролей, которые могут быть опубликованы в Galaxy.

## Директория group_vars/

### all.yml
**Назначение**: Централизованное хранение переменных, используемых всеми хостами.

**Основные переменные**:
- **Версии компонентов**:
  - `prometheus_version`: Версия Prometheus
  - `grafana_version`: Версия Grafana
  - `loki_version`: Версия Loki
  - `alertmanager_version`: Версия Alertmanager

- **Настройки портов**:
  - `prometheus_port`: 9090
  - `grafana_port`: 3000
  - `loki_port`: 3100
  - `alertmanager_port`: 9093
  - `app_port`: 8080

- **SMTP конфигурация для email алертов**:
  - `smtp_host`: SMTP сервер
  - `smtp_port`: SMTP порт
  - `smtp_from`: Email отправителя
  - `smtp_to`: Email получателя
  - `smtp_username`: Имя пользователя SMTP
  - `smtp_password`: Пароль SMTP

**Важно**: Перед развертыванием необходимо изменить SMTP настройки на реальные.

## Директория inventories/

### hosts.ini
**Назначение**: Файл инвентаря Ansible, определяющий целевые хосты для развертывания.

**Структура**:
```ini
[app]
app-server ansible_host=192.168.56.30 ansible_user=vagrant ansible_ssh_private_key_file=...

[monitoring]
monitoring-server ansible_host=192.168.56.31 ansible_user=vagrant ansible_ssh_private_key_file=...

[all:vars]
ansible_python_interpreter=/usr/bin/python3
```

**Группы хостов**:
- `app`: Сервер приложения
- `monitoring`: Сервер мониторинга
- `all:vars`: Общие переменные для всех хостов

## Структура Ansible ролей

Каждая роль имеет стандартную структуру Ansible:

```
role_name/
├── README.md           # Документация роли
├── defaults/
│   └── main.yml        # Переменные по умолчанию
├── handlers/
│   └── main.yml        # Обработчики событий (перезапуск сервисов)
├── meta/
│   └── main.yml        # Метаданные для Ansible Galaxy
├── molecule/
│   └── default/        # Тесты Molecule
│       ├── molecule.yml    # Конфигурация Molecule
│       ├── converge.yml    # Playbook для тестирования
│       └── verify.yml      # Проверки после развертывания
├── tasks/
│   └── main.yml        # Основные задачи роли
├── templates/          # Jinja2 шаблоны конфигурационных файлов
└── vars/              # Переменные (опционально)
```

## Роль: prometheus

**Путь**: `roles/prometheus/`

**Назначение**: Установка и настройка Prometheus для сбора метрик.

### Ключевые файлы:

#### defaults/main.yml
Определяет:
- Версию Prometheus
- Пути установки (`/opt/prometheus`, `/etc/prometheus`)
- Порт (9090)
- Время хранения данных (15 дней)
- Конфигурацию целей для сбора метрик (scrape targets)

#### tasks/main.yml
Выполняет:
1. Создание пользователя и группы `prometheus`
2. Создание необходимых директорий
3. Загрузку и установку бинарного файла Prometheus
4. Копирование конфигурационных файлов
5. Настройку systemd сервиса
6. Запуск Prometheus

#### templates/prometheus.yml.j2
**Назначение**: Главный конфигурационный файл Prometheus.

**Содержит**:
- Глобальные настройки сбора метрик
- Конфигурацию Alertmanager
- Правила алертинга
- Цели для сбора метрик (scrape_configs):
  - `prometheus` - сам Prometheus
  - `spring-boot-app` - приложение на `/actuator/prometheus`

#### templates/alert_rules.yml.j2
**Назначение**: Определение правил алертинга.

**Алерты**:
1. **InstanceDown** (Critical) - сервис недоступен более 2 минут
2. **HighMemoryUsage** (Warning) - использование JVM heap > 85%
3. **HighCPUUsage** (Warning) - использование CPU > 80%
4. **ApplicationResponseTimeHigh** (Warning) - время ответа > 1 секунды
5. **ApplicationErrorRateHigh** (Critical) - частота ошибок > 5%

#### templates/prometheus.service.j2
**Назначение**: Systemd unit файл для запуска Prometheus как сервиса.

## Роль: alertmanager

**Путь**: `roles/alertmanager/`

**Назначение**: Установка и настройка Alertmanager для управления алертами и отправки email уведомлений.

### Ключевые файлы:

#### defaults/main.yml
Определяет:
- Версию Alertmanager
- Пути установки (`/opt/alertmanager`, `/etc/alertmanager`)
- Порт (9093)
- **SMTP конфигурацию для email**

#### templates/alertmanager.yml.j2
**Назначение**: Конфигурационный файл Alertmanager.

**Содержит**:
- **global**: SMTP настройки для email уведомлений
- **route**: Правила маршрутизации алертов
  - Группировка по `alertname`, `cluster`, `service`
  - Разные интервалы повторения для critical и warning
- **receivers**: Получатели уведомлений
  - `email-notifications`: Email конфигурация с HTML шаблоном
- **inhibit_rules**: Правила подавления алертов

**HTML шаблон email**:
- Цветовая маркировка по severity (critical - красный, warning - желтый)
- Отображение summary и description
- Время начала алерта

#### templates/alertmanager.service.j2
**Назначение**: Systemd unit файл для Alertmanager.

## Роль: grafana

**Путь**: `roles/grafana/`

**Назначение**: Установка и настройка Grafana для визуализации метрик.

### Ключевые файлы:

#### defaults/main.yml
Определяет:
- Версию Grafana
- Порт (3000)
- Учетные данные администратора
- URL источников данных (Prometheus, Loki)

#### tasks/main.yml
Выполняет:
1. Установку репозитория Grafana
2. Установку пакета Grafana
3. Создание директорий для provisioning
4. Копирование конфигурационных файлов
5. Настройку автоматического добавления источников данных
6. Установку дашбордов

#### templates/grafana.ini.j2
**Назначение**: Главный конфигурационный файл Grafana.

**Настройки**:
- Сервер: порт, адрес, домен
- Безопасность: admin пользователь и пароль
- Пользователи: отключена регистрация
- База данных: SQLite
- Аналитика: отключена

#### templates/datasources.yml.j2
**Назначение**: Автоматическое добавление источников данных.

**Источники данных**:
1. **Prometheus** - основной источник метрик (по умолчанию)
2. **Loki** - источник логов

#### templates/dashboards.yml.j2
**Назначение**: Настройка автоматической загрузки дашбордов.

#### templates/dashboards/spring-boot-dashboard.json.j2
**Назначение**: Предустановленный дашборд для Spring Boot приложения.

**Панели**:
1. **HTTP Request Rate** - частота HTTP запросов
2. **HTTP Response Time** - время ответа
3. **JVM Heap Memory** - использование памяти (gauge)
4. **CPU Usage** - использование CPU (gauge)
5. **JVM Threads** - количество потоков

**Особенности**:
- Автообновление каждые 10 секунд
- Данные за последний час
- Использует Prometheus datasource

## Роль: loki

**Путь**: `roles/loki/`

**Назначение**: Установка и настройка Loki для агрегации логов.

### Ключевые файлы:

#### defaults/main.yml
Определяет:
- Версию Loki
- Пути установки и хранения данных
- Порт (3100)

#### tasks/main.yml
Выполняет:
1. Создание пользователя и группы `loki`
2. Создание директорий для данных и индексов
3. Загрузку бинарного файла Loki
4. Копирование конфигурации
5. Настройку systemd сервиса

#### templates/loki.yml.j2
**Назначение**: Конфигурационный файл Loki.

**Настройки**:
- Порты HTTP (3100) и gRPC (9096)
- Хранилище: filesystem (BoltDB + файловая система)
- Schema config: определение схемы индексов
- Интеграция с Alertmanager
- Лимиты ingestion

#### templates/loki.service.j2
**Назначение**: Systemd unit файл для Loki.

## Роль: spring_boot_app

**Путь**: `roles/spring_boot_app/`

**Назначение**: Развертывание Spring Boot Demo приложения с экспортом метрик Prometheus.

### Ключевые файлы:

#### defaults/main.yml
Определяет:
- Имя приложения: `spring-boot-demo`
- Порт: 8080
- Путь установки: `/opt/spring-boot-app`
- URL Git репозитория: `https://github.com/grafana/spring-boot-demo.git`
- Версия Java: 17

#### tasks/main.yml
Выполняет:
1. Установку Java 17 и Maven
2. Создание пользователя `springboot`
3. Клонирование репозитория приложения
4. Сборку приложения через Maven
5. Создание директории для логов
6. Копирование JAR файла
7. Настройку конфигурации приложения
8. Создание systemd сервиса
9. Запуск приложения

#### templates/application.yml.j2
**Назначение**: Конфигурационный файл Spring Boot приложения.

**Настройки**:
- Порт сервера (8080)
- **Management endpoints**: включены health, info, metrics, prometheus
- **Prometheus endpoint**: `/actuator/prometheus`
- Логирование: уровень INFO, файл логов

#### templates/spring-boot-app.service.j2
**Назначение**: Systemd unit файл для Spring Boot приложения.

**Особенности**:
- Запуск от пользователя `springboot`
- Автоматический перезапуск при падении
- Передача пути к конфигурационному файлу

## Molecule тесты

Каждая роль содержит директорию `molecule/default/` с тестами:

### molecule.yml
**Назначение**: Конфигурация Molecule для тестирования роли.

**Параметры**:
- `driver: docker` - использование Docker для тестов
- `platforms`: Ubuntu 22.04 образ для тестирования
- `provisioner: ansible` - использование Ansible для provisioning

### converge.yml
**Назначение**: Playbook, который применяет роль для тестирования.

```yaml
- hosts: all
  become: yes
  roles:
    - role: role_name
```

### verify.yml
**Назначение**: Проверки после применения роли.

**Типичные проверки**:
1. Существование бинарных файлов
2. Статус systemd сервиса (active)
3. Существование конфигурационных файлов
4. Доступность web-интерфейсов (проверка HTTP endpoints)

**Запуск тестов**:
```bash
cd roles/role_name
molecule test
```

## Документация

### README.md
**Назначение**: Основная документация проекта на русском языке.

**Содержимое**:
- Описание архитектуры
- Список компонентов
- Инструкции по быстрому старту
- Настройка email алертинга
- Информация о тестировании
- Описание дашбордов и алертов

### QUICK_START.md
**Назначение**: Краткое руководство по развертыванию.

**Содержимое**:
- Команда одностроч ного развертывания
- Пошаговые инструкции
- Информация о доступе к сервисам
- Настройка email
- Тестирование алертов
- Общие команды
- Troubleshooting

### IMPLEMENTATION_SUMMARY.md
**Назначение**: Полное техническое описание реализации.

**Содержимое**:
- Обзор всех функций
- Детальное описание компонентов
- Статистика проекта
- Выполнение требований
- Технологический стек
- Сетевая архитектура
- Поток данных
- Рекомендации по безопасности
- Возможные улучшения

### STRUCTURE.md (этот файл)
**Назначение**: Детальное описание структуры файлов и их назначения.

### Роль READMEs
Каждая роль содержит свой README.md с описанием:
- Требований
- Переменных роли
- Зависимостей
- Примеров использования
- Инструкций по тестированию

## Файлы конфигурации

### .gitignore
**Назначение**: Исключение временных и генерируемых файлов из Git.

**Исключения**:
- `.vagrant/` - директория Vagrant
- `*.retry` - retry файлы Ansible
- `.molecule/` - кеш Molecule
- Файлы ОС и IDE

## Потоки данных

### Метрики (Prometheus)
```
Spring Boot App (:8080/actuator/prometheus)
    ↓ (scrape каждые 15 секунд)
Prometheus (:9090)
    ↓ (query API)
Grafana (:3000)
```

### Алерты
```
Prometheus (:9090)
    ↓ (оценка правил алертинга)
Alertmanager (:9093)
    ↓ (группировка и маршрутизация)
Email (SMTP)
```

### Логи (готово к интеграции)
```
Spring Boot App (logs)
    ↓ (future: Promtail)
Loki (:3100)
    ↓ (query API)
Grafana (:3000)
```

## Порядок развертывания

1. **Vagrantfile** создает VM
2. **ansible.cfg** настраивает Ansible
3. **inventories/hosts.ini** определяет целевые хосты
4. **group_vars/all.yml** загружает переменные
5. **deploy.yml** выполняет playbook:
   - На `app` сервере: применяется роль `spring_boot_app`
   - На `monitoring` сервере: применяются роли `prometheus`, `alertmanager`, `grafana`, `loki`
6. Сервисы запускаются через systemd
7. Grafana автоматически настраивает datasources и dashboards

## Зависимости между компонентами

```
Spring Boot App
    └── предоставляет метрики → Prometheus
                                    ├── отправляет алерты → Alertmanager
                                    │                           └── отправляет email
                                    └── предоставляет данные → Grafana
Loki
    └── предоставляет логи → Grafana
```

## Переменные окружения и параметризация

Все основные параметры централизованно хранятся в:
1. `group_vars/all.yml` - общие переменные
2. `roles/*/defaults/main.yml` - переменные по умолчанию для каждой роли

Это позволяет легко изменять:
- Версии компонентов
- Порты
- Пути установки
- SMTP настройки
- Учетные данные

## Безопасность

⚠️ **Важно**: Перед production использованием необходимо изменить:

1. **Пароли**:
   - Grafana admin пароль в `group_vars/all.yml`
   - SMTP пароль (использовать Ansible Vault)

2. **Сетевая безопасность**:
   - Настроить файрвол
   - Ограничить доступ к портам

3. **SSL/TLS**:
   - Настроить HTTPS для Grafana
   - Использовать TLS для SMTP

## Заключение

Эта структура обеспечивает:
- ✅ Модульность (независимые роли)
- ✅ Переиспользуемость (роли могут быть опубликованы в Galaxy)
- ✅ Тестируемость (Molecule тесты)
- ✅ Документированность (README для каждого компонента)
- ✅ Гибкость (параметризация через переменные)
- ✅ Автоматизацию (deploy.sh для быстрого развертывания)

Для дополнительной информации см. другие файлы документации:
- `README.md` - основная документация
- `QUICK_START.md` - быстрый старт
- `IMPLEMENTATION_SUMMARY.md` - детали реализации
