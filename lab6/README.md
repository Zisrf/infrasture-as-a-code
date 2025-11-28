# Lab 6 - Стек мониторинга: Prometheus + Grafana + Loki + Spring Boot

## Описание

Эта лабораторная работа демонстрирует развертывание полноценного стека мониторинга и сбора логов для Spring Boot приложения. Система состоит из:
- **Prometheus** - сбор и хранение метрик
- **Grafana** - визуализация метрик и логов
- **Loki** - агрегация логов
- **Spring Boot Demo** - демонстрационное приложение с метриками

## Структура файлов

```
lab6/
├── .gitignore            # Исключения для Git
├── Vagrantfile           # Конфигурация виртуальных машин
├── ansible.cfg           # Настройки Ansible
├── site.yml              # Главный плейбук
├── inventories/
│   └── dev.yml           # Инвентарь разработки
└── roles/
    ├── common/           # Общие настройки
    │   └── tasks/main.yml
    ├── docker/           # Установка Docker
    │   └── tasks/main.yml
    ├── prometheus/       # Мониторинг метрик
    │   ├── tasks/main.yml
    │   └── templates/
    │       ├── prometheus.yml.j2
    │       └── prometheus.service.j2
    ├── grafana/          # Визуализация
    │   ├── handlers/main.yml
    │   ├── tasks/main.yml
    │   └── templates/
    │       └── grafana.ini.j2
    ├── loki/             # Агрегация логов
    │   ├── tasks/main.yml
    │   └── templates/
    │       ├── loki-config.yml.j2
    │       └── loki.service.j2
    └── spring_app/       # Демо приложение
        ├── tasks/main.yml
        └── templates/
            └── spring-app.service.j2
```

## Описание файлов

### .gitignore
Исключения:
- `.vagrant/` - файлы Vagrant
- `*.retry` - файлы повторов Ansible
- `*private_key` - приватные ключи
- IDE файлы (.vscode, .idea)

### Vagrantfile
Создает две виртуальные машины:
- **app** - Ubuntu 20.04, 2GB RAM, IP: 192.168.56.10
- **monitoring** - Ubuntu 20.04, 3GB RAM, IP: 192.168.56.11

### ansible.cfg
Конфигурация Ansible:
- Инвентарь по умолчанию: `inventories/dev.yml`
- Pipelining включен для ускорения
- Таймаут соединения: 30 секунд

### site.yml
Главный плейбук с двумя плеями:

**1. Configure monitoring server** (monitoring):
- common - базовые пакеты
- docker - контейнеризация
- prometheus - сбор метрик
- grafana - визуализация
- loki - логи

**2. Configure application server** (app):
- common - базовые пакеты
- docker - контейнеризация
- spring_app - демо приложение

### inventories/dev.yml
Инвентарь:
- `[app]` - 192.168.56.10
- `[monitoring]` - 192.168.56.11

## Роли

### roles/common/
Установка базовых пакетов: curl, wget, gnupg, htop, tree, git

### roles/docker/
Установка Docker CE:
1. Добавление GPG ключа Docker
2. Добавление репозитория Docker
3. Установка docker-ce, containerd.io
4. Запуск сервиса Docker

### roles/prometheus/

**tasks/main.yml:**
1. Создание пользователя prometheus
2. Создание директорий `/etc/prometheus`, `/var/lib/prometheus`
3. Загрузка Prometheus 2.47.0
4. Копирование бинарных файлов
5. Применение конфигурации
6. Создание systemd сервиса

**templates/prometheus.yml.j2:**
```yaml
scrape_configs:
  - job_name: 'prometheus'      # Самомониторинг
  - job_name: 'spring-app'      # Метрики Spring Boot
    metrics_path: '/actuator/prometheus'
  - job_name: 'node-exporter'   # Системные метрики
```

**templates/prometheus.service.j2:**
Systemd unit для запуска Prometheus с нужными параметрами.

### roles/grafana/

**tasks/main.yml:**
1. Установка Grafana из репозитория
2. Применение конфигурации
3. Запуск на порту 3000

**templates/grafana.ini.j2:**
- Порт: 3000
- Учетные данные: admin/admin
- Анонимный доступ: включен (Viewer)

**handlers/main.yml:**
Обработчик перезапуска grafana-server.

### roles/loki/

**tasks/main.yml:**
1. Создание пользователя loki
2. Загрузка Loki 2.9.0
3. Конфигурация и запуск сервиса

**templates/loki-config.yml.j2:**
- Порт HTTP: 3100
- Хранилище: filesystem
- Кэш: embedded (100MB)
- Схема: boltdb-shipper + v11

**templates/loki.service.j2:**
Systemd unit для Loki.

### roles/spring_app/

**tasks/main.yml:**
1. Установка OpenJDK 11
2. Клонирование Spring Boot Demo
3. Сборка с Gradle
4. Создание systemd сервиса

**templates/spring-app.service.j2:**
- Запуск JAR файла
- Экспорт всех actuator endpoints
- Автоматический перезапуск

## Запуск

```bash
cd lab6

# Запуск виртуальных машин
vagrant up

# Развертывание стека мониторинга
ansible-playbook site.yml
```

## Доступ к сервисам

| Сервис | URL | Порт |
|--------|-----|------|
| Prometheus | http://192.168.56.11:9090 | 9090 |
| Grafana | http://192.168.56.11:3000 | 3000 |
| Loki | http://192.168.56.11:3100 | 3100 |
| Spring App | http://192.168.56.10:8080 | 8080 |
| Actuator | http://192.168.56.10:8080/actuator/prometheus | 8080 |

## Результат

После выполнения:
- Spring Boot приложение экспортирует метрики через Actuator
- Prometheus собирает метрики каждые 5-15 секунд
- Grafana визуализирует данные
- Loki готов принимать логи
- Доступ к Grafana: admin/admin
