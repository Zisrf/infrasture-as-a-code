# Лабораторная работа 5: Развертывание PostgreSQL с репликацией

## Описание

Данная лабораторная работа демонстрирует использование Ansible для автоматизированного развертывания PostgreSQL-сервера с поддержкой репликации (master/replica). Включает настройку базы данных, пользователей и тестирование с помощью Molecule.

## Структура файлов

```
lab5/
├── Vagrantfile                # Конфигурация виртуальных машин
├── ansible.cfg                # Настройки Ansible
├── deploy_postgresql.yml      # Основной плейбук
├── setup_python.yml           # Плейбук для установки Python
├── ssh_config                 # SSH-конфигурация для подключения
├── group_vars/
│   └── postgresql_servers.yml # Переменные группы PostgreSQL
├── inventories/
│   └── production.yml         # Продакшн-инвентарь
├── final_inventory.yml        # Финальный инвентарь
├── working_inventory.yml      # Рабочий инвентарь
├── wsl_inventory.yml          # Инвентарь для WSL
└── roles/
    └── postgresql/            # Роль PostgreSQL
        ├── defaults/
        │   └── main.yml       # Переменные по умолчанию
        ├── handlers/
        │   └── main.yml       # Обработчики событий
        ├── meta/
        │   └── main.yml       # Метаданные роли
        ├── molecule/
        │   └── default/       # Тесты Molecule
        ├── tasks/
        │   ├── main.yml       # Основные задачи
        │   ├── database_setup.yml
        │   └── replication.yml
        ├── templates/
        │   ├── postgresql.conf.j2
        │   └── pg_hba.conf.j2
        └── vars/
            └── debian.yml     # Переменные для Debian/Ubuntu
```

## Описание файлов

### Vagrantfile

Создает две виртуальные машины:

- **app** (`192.168.56.20`) — сервер приложений
  - 1024 МБ ОЗУ, 1 CPU
  - Ubuntu Jammy64
  
- **db** (`192.168.56.21`) — сервер базы данных
  - 2048 МБ ОЗУ, 2 CPU
  - Ubuntu Jammy64
  - Настроен как master для репликации

### ansible.cfg

Конфигурация Ansible:
- Отключение проверки ключей хостов
- Использование пользователя `vagrant`
- SSH-подключение с ControlMaster

### deploy_postgresql.yml

Основной плейбук:
1. **Deploy PostgreSQL database server** — применяет роль `postgresql` к группе `postgresql_servers`
2. **Deploy application** — устанавливает зависимости на сервер приложений

### group_vars/postgresql_servers.yml

Переменные для группы PostgreSQL-серверов:

**Базовая конфигурация:**
```yaml
postgresql_version: "14"
postgresql_port: 5432
```

**Базы данных и пользователи:**
```yaml
postgresql_databases:
  - name: app_db
    owner: app_user
    encoding: "UTF8"

postgresql_users:
  - name: app_user
    password: "app_password123"
    databases: ["app_db"]
    privileges: ["ALL"]
```

**Репликация:**
```yaml
postgresql_replication: true
postgresql_replication_user: "replicator"
postgresql_replication_password: "replication_pass123"
```

**Аутентификация (pg_hba.conf):**
```yaml
postgresql_pg_hba_entries:
  - { type: local, database: all, user: postgres, method: peer }
  - { type: host, database: all, user: all, address: 192.168.56.0/24, method: md5 }
```

### Роль postgresql

#### defaults/main.yml

Переменные по умолчанию:
- Версия PostgreSQL: 14
- Максимум соединений: 100
- Размер shared_buffers: 128MB
- WAL-уровень: replica
- Максимум WAL-отправителей: 10

#### tasks/main.yml

Основные задачи:
1. Подключение OS-специфичных переменных
2. Добавление GPG-ключа и репозитория PostgreSQL
3. Установка PostgreSQL-сервера и клиента
4. Применение шаблонов `postgresql.conf` и `pg_hba.conf`
5. Запуск и включение сервиса PostgreSQL
6. Настройка баз данных и пользователей
7. Конфигурация репликации (если включена)

#### tasks/database_setup.yml

Создание пользователей и баз данных:
```yaml
- name: Create PostgreSQL users
  community.postgresql.postgresql_user:
    name: "{{ item.name }}"
    password: "{{ item.password }}"

- name: Create PostgreSQL databases
  community.postgresql.postgresql_db:
    name: "{{ item.name }}"
    owner: "{{ item.owner }}"
```

#### tasks/replication.yml

Настройка репликации:
- Создание пользователя репликации с атрибутом `REPLICATION`
- Создание слота репликации

#### templates/postgresql.conf.j2

Шаблон конфигурации PostgreSQL:
- Настройки подключений (listen_addresses, port, max_connections)
- Настройки ресурсов (shared_buffers, work_mem)
- Настройки WAL (wal_level, max_wal_senders)
- Настройки репликации (для master и replica)
- Настройки логирования

#### templates/pg_hba.conf.j2

Шаблон аутентификации клиентов:
```
{% for entry in postgresql_pg_hba_entries %}
{{ entry.type }}  {{ entry.database }}  {{ entry.user }}  {{ entry.address }}  {{ entry.method }}
{% endfor %}
```

#### handlers/main.yml

Обработчики:
- `restart postgresql` — перезапуск сервиса
- `reload postgresql` — перезагрузка конфигурации

### Файлы инвентаря

Проект содержит несколько вариантов инвентаря для разных сред:
- `final_inventory.yml` — с SSH-ключами Vagrant
- `working_inventory.yml` — с паролями
- `wsl_inventory.yml` — для WSL-окружения
- `inventories/production.yml` — продакшн-инвентарь

### Тестирование с Molecule

#### molecule/default/molecule.yml

```yaml
driver:
  name: docker
platforms:
  - name: postgresql-test
    image: ubuntu:20.04
    privileged: true
```

#### molecule/default/verify.yml

Тесты верификации:
1. Проверка запуска сервиса PostgreSQL
2. Проверка прослушивания порта 5432
3. Проверка процесса postgres
4. Проверка директории данных
5. Проверка доступности баз данных

## Использование

```bash
cd lab5

# Запуск виртуальных машин
vagrant up

# Применение плейбука
ansible-playbook -i final_inventory.yml deploy_postgresql.yml

# Запуск тестов Molecule
cd roles/postgresql
molecule test
```

## Архитектура

```
┌─────────────────────────────────────────────┐
│            App Server (192.168.56.20)       │
│                                             │
│   ┌─────────────────────────────────────┐   │
│   │         Python + PostgreSQL Client  │   │
│   └─────────────────────────────────────┘   │
│                      │                      │
└──────────────────────│──────────────────────┘
                       │ TCP/5432
                       ▼
┌─────────────────────────────────────────────┐
│           DB Server (192.168.56.21)         │
│                                             │
│   ┌─────────────────────────────────────┐   │
│   │          PostgreSQL 14 (Master)     │   │
│   │                                     │   │
│   │   Database: app_db                  │   │
│   │   User: app_user                    │   │
│   │   Replication User: replicator      │   │
│   └─────────────────────────────────────┘   │
│                      │                      │
│              Streaming Replication          │
│                      ▼                      │
│   ┌─────────────────────────────────────┐   │
│   │         (Replica - optional)        │   │
│   └─────────────────────────────────────┘   │
└─────────────────────────────────────────────┘
```

## Переменные окружения

| Переменная | Описание | По умолчанию |
|------------|----------|--------------|
| `postgresql_version` | Версия PostgreSQL | 14 |
| `postgresql_port` | Порт сервера | 5432 |
| `postgresql_max_connections` | Макс. соединений | 100 |
| `postgresql_replication` | Включить репликацию | false |
| `postgresql_role` | Роль (master/replica) | master |
