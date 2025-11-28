# Лабораторная работа 6: Мониторинг с Prometheus, Grafana и Loki

## Описание

Данная лабораторная работа демонстрирует создание полноценного стека мониторинга с использованием Ansible. Включает развертывание Prometheus для сбора метрик, Grafana для визуализации и Loki для агрегации логов. В качестве примера приложения используется Spring Boot Demo.

## Структура файлов

```
lab6/
├── .gitignore              # Исключения для Git
├── Vagrantfile             # Конфигурация виртуальных машин
├── ansible.cfg             # Настройки Ansible
├── site.yml                # Основной плейбук
├── inventories/
│   └── dev.yml             # Инвентарь разработки
└── roles/
    ├── common/             # Общие задачи для всех серверов
    │   └── tasks/main.yml
    ├── docker/             # Установка Docker
    │   └── tasks/main.yml
    ├── prometheus/         # Развертывание Prometheus
    │   ├── tasks/main.yml
    │   └── templates/
    │       ├── prometheus.yml.j2
    │       └── prometheus.service.j2
    ├── grafana/            # Развертывание Grafana
    │   ├── handlers/main.yml
    │   ├── tasks/main.yml
    │   └── templates/
    │       └── grafana.ini.j2
    ├── loki/               # Развертывание Loki
    │   ├── tasks/main.yml
    │   └── templates/
    │       ├── loki-config.yml.j2
    │       └── loki.service.j2
    └── spring_app/         # Развертывание Spring Boot приложения
        ├── tasks/main.yml
        └── templates/
            └── spring-app.service.j2
```

## Описание файлов

### Vagrantfile

Создает две виртуальные машины:

- **app** (`192.168.56.10`) — сервер приложений
  - 2048 МБ ОЗУ, 2 CPU
  - Ubuntu Focal64
  
- **monitoring** (`192.168.56.11`) — сервер мониторинга
  - 3072 МБ ОЗУ, 2 CPU
  - Ubuntu Focal64

### ansible.cfg

Конфигурация Ansible:
- Инвентарь: `inventories/dev.yml`
- SSH pipelining для ускорения
- Таймаут подключения: 30 секунд

### site.yml

Основной плейбук с двумя play:

**1. Configure monitoring server:**
```yaml
hosts: monitoring
roles:
  - common
  - docker
  - prometheus
  - grafana
  - loki
```

**2. Configure application server:**
```yaml
hosts: app
roles:
  - common
  - docker
  - spring_app
```

### inventories/dev.yml

Инвентарь разработки в формате INI:
```ini
[app]
192.168.56.10

[monitoring]
192.168.56.11
```

### Роль common

**tasks/main.yml** — установка базовых пакетов:
- curl, wget, gnupg
- software-properties-common
- apt-transport-https, ca-certificates
- htop, tree, git

### Роль docker

**tasks/main.yml** — установка Docker:
1. Установка зависимостей
2. Добавление GPG-ключа и репозитория Docker
3. Установка docker-ce, docker-ce-cli, containerd.io
4. Запуск сервиса Docker
5. Добавление пользователя vagrant в группу docker

### Роль prometheus

**tasks/main.yml** — установка Prometheus:
1. Создание системного пользователя `prometheus`
2. Создание директорий `/etc/prometheus`, `/var/lib/prometheus`
3. Загрузка и распаковка Prometheus v2.47.0
4. Копирование бинарных файлов `prometheus`, `promtool`
5. Применение шаблона конфигурации
6. Создание systemd-сервиса
7. Запуск и включение сервиса

**templates/prometheus.yml.j2** — конфигурация сбора метрик:
```yaml
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']

  - job_name: 'spring-app'
    metrics_path: '/actuator/prometheus'
    static_configs:
      - targets: ['192.168.56.10:8080']
    scrape_interval: 5s

  - job_name: 'node-exporter'
    static_configs:
      - targets: ['localhost:9100']
```

**templates/prometheus.service.j2** — systemd unit:
```ini
[Unit]
Description=Prometheus
Wants=network-online.target
After=network-online.target

[Service]
User=prometheus
Type=simple
ExecStart=/usr/local/bin/prometheus \
    --config.file /etc/prometheus/prometheus.yml \
    --storage.tsdb.path /var/lib/prometheus/
```

### Роль grafana

**tasks/main.yml** — установка Grafana:
1. Установка из Ubuntu-репозитория
2. Применение шаблона конфигурации
3. Запуск и включение сервиса
4. Ожидание запуска на порту 3000

**templates/grafana.ini.j2** — конфигурация Grafana:
```ini
[server]
http_addr = 0.0.0.0
http_port = 3000

[security]
admin_user = admin
admin_password = admin

[auth.anonymous]
enabled = true
org_role = Viewer
```

**handlers/main.yml** — обработчик перезапуска:
```yaml
- name: restart grafana
  systemd:
    name: grafana-server
    state: restarted
```

### Роль loki

**tasks/main.yml** — установка Loki:
1. Создание системного пользователя `loki`
2. Создание директорий `/etc/loki`, `/var/lib/loki`
3. Загрузка и распаковка Loki v2.9.0
4. Применение шаблона конфигурации
5. Создание systemd-сервиса
6. Запуск сервиса

**templates/loki-config.yml.j2** — конфигурация Loki:
```yaml
auth_enabled: false

server:
  http_listen_port: 3100

common:
  path_prefix: /var/lib/loki
  storage:
    filesystem:
      chunks_directory: /var/lib/loki/chunks

schema_config:
  configs:
    - from: 2020-10-24
      store: boltdb-shipper
      object_store: filesystem
      schema: v11
```

**templates/loki.service.j2** — systemd unit:
```ini
[Unit]
Description=Loki log aggregation system
After=network.target

[Service]
Type=simple
User=loki
ExecStart=/usr/local/bin/loki-linux-amd64 -config.file /etc/loki/loki-config.yml
```

### Роль spring_app

**tasks/main.yml** — развертывание Spring Boot приложения:
1. Установка OpenJDK 11
2. Клонирование репозитория spring-boot-demo
3. Сборка приложения с Gradle
4. Создание systemd-сервиса
5. Запуск приложения

**templates/spring-app.service.j2** — systemd unit:
```ini
[Unit]
Description=Spring Boot Demo Application
After=network.target

[Service]
Type=simple
User=vagrant
WorkingDirectory=/opt/spring-boot-demo
ExecStart=/usr/bin/java -jar /opt/spring-boot-demo/build/libs/spring-boot-demo-0.0.1-SNAPSHOT.jar
Environment=JAVA_OPTS=-Dmanagement.endpoints.web.exposure.include=*
```

## Использование

```bash
cd lab6

# Запуск виртуальных машин
vagrant up

# Применение плейбука
ansible-playbook site.yml
```

## Доступ к сервисам

После развертывания доступны следующие сервисы:

| Сервис | URL | Учетные данные |
|--------|-----|----------------|
| Prometheus | http://192.168.56.11:9090 | — |
| Grafana | http://192.168.56.11:3000 | admin/admin |
| Loki | http://192.168.56.11:3100 | — |
| Spring App | http://192.168.56.10:8080 | — |
| Spring Metrics | http://192.168.56.10:8080/actuator/prometheus | — |

## Архитектура

```
┌─────────────────────────────────────────────────────────────────┐
│                   Monitoring Server (192.168.56.11)             │
│                                                                 │
│   ┌─────────────┐   ┌─────────────┐   ┌─────────────┐          │
│   │ Prometheus  │   │   Grafana   │   │    Loki     │          │
│   │   :9090     │   │   :3000     │   │   :3100     │          │
│   └──────┬──────┘   └──────┬──────┘   └──────┬──────┘          │
│          │                 │                 │                  │
│          └─────────────────┴─────────────────┘                  │
│                            │                                    │
└────────────────────────────│────────────────────────────────────┘
                             │
            Scrape Metrics   │   Query Data
                             │
┌────────────────────────────│────────────────────────────────────┐
│                   App Server (192.168.56.10)                    │
│                            │                                    │
│   ┌─────────────────────────────────────────────────────────┐  │
│   │              Spring Boot Application                     │  │
│   │                     :8080                                │  │
│   │                                                          │  │
│   │   /actuator/prometheus  ←───── Prometheus scrapes        │  │
│   │   /actuator/health      ←───── Health checks             │  │
│   └─────────────────────────────────────────────────────────┘  │
│                                                                 │
│   ┌─────────────┐                                              │
│   │   Docker    │  (для будущего использования)                │
│   └─────────────┘                                              │
└─────────────────────────────────────────────────────────────────┘
```

## Настройка Grafana

После первого входа в Grafana (admin/admin):

1. **Добавить источник данных Prometheus:**
   - Configuration → Data Sources → Add data source
   - URL: `http://localhost:9090`

2. **Добавить источник данных Loki:**
   - Configuration → Data Sources → Add data source
   - URL: `http://localhost:3100`

3. **Импортировать дашборды:**
   - JVM Dashboard: ID 4701
   - Spring Boot Dashboard: ID 11378

## Порты и протоколы

| Порт | Сервис | Протокол |
|------|--------|----------|
| 9090 | Prometheus | HTTP |
| 3000 | Grafana | HTTP |
| 3100 | Loki | HTTP |
| 9096 | Loki gRPC | gRPC |
| 8080 | Spring App | HTTP |

## Файл .gitignore

Исключает из Git:
- Директории `.vagrant/`, `.molecule/`
- Файлы логов `*.log`
- SSH-ключи `*private_key`, `*key`
- Виртуальные окружения Python
- Файлы IDE и ОС
