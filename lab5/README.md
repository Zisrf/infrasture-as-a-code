# Lab 5 - Развертывание PostgreSQL с репликацией с помощью Ansible

## Описание

Эта лабораторная работа демонстрирует развертывание PostgreSQL сервера с поддержкой репликации. Включает полностью настраиваемую Ansible роль с тестами Molecule.

## Структура файлов

```
lab5/
├── Vagrantfile              # Конфигурация виртуальных машин
├── ansible.cfg              # Настройки Ansible
├── deploy_postgresql.yml    # Главный плейбук развертывания
├── setup_python.yml         # Плейбук установки Python 3.9
├── group_vars/
│   └── postgresql_servers.yml  # Групповые переменные
├── inventories/
│   └── production.yml       # Продакшн инвентарь
└── roles/
    └── postgresql/          # Роль PostgreSQL
        ├── defaults/main.yml    # Переменные по умолчанию
        ├── handlers/main.yml    # Обработчики событий
        ├── meta/main.yml        # Метаданные роли (Galaxy)
        ├── tasks/main.yml       # Основные задачи
        ├── templates/
        │   ├── postgresql.conf.j2  # Шаблон конфигурации
        │   └── pg_hba.conf.j2      # Шаблон аутентификации
        └── molecule/
            └── default/         # Тесты Molecule
                ├── molecule.yml
                ├── converge.yml
                ├── create.yml
                ├── destroy.yml
                └── verify.yml
```

## Описание файлов

### Vagrantfile
Создает две виртуальные машины:
- **app** - Ubuntu 22.04, 1GB RAM, IP: 192.168.56.20
- **db** - Ubuntu 22.04, 2GB RAM, IP: 192.168.56.21

### ansible.cfg
Конфигурация Ansible с отключенной проверкой SSH-ключей.

### deploy_postgresql.yml
Главный плейбук:
1. Развертывает PostgreSQL на группе `postgresql_servers`
2. Настраивает app-сервер с клиентом PostgreSQL

### setup_python.yml
Вспомогательный плейбук для установки Python 3.9:
- Добавление PPA deadsnakes
- Установка python3.9

### group_vars/postgresql_servers.yml
Конфигурация PostgreSQL:
- **Версия:** PostgreSQL 14
- **База данных:** app_db
- **Пользователь:** app_user
- **Репликация:** включена
- **Сеть:** прослушивание на 192.168.56.21
- **pg_hba:** правила аутентификации

### inventories/production.yml
Структура инвентаря:
- `all.children.app` - серверы приложений
- `all.children.postgresql_servers` - серверы БД
- `postgresql_master` - мастер-сервер
- `postgresql_replicas` - реплики (пустая группа)

## Роль PostgreSQL

### defaults/main.yml
Переменные по умолчанию:
| Переменная | Значение | Описание |
|------------|----------|----------|
| postgresql_version | 14 | Версия PostgreSQL |
| postgresql_port | 5432 | Порт сервера |
| postgresql_max_connections | 100 | Лимит соединений |
| postgresql_replication | false | Флаг репликации |
| postgresql_wal_level | replica | Уровень WAL |

### tasks/main.yml
Последовательность задач:
1. Установка репозитория PostgreSQL
2. Установка пакетов postgresql-14
3. Генерация postgresql.conf из шаблона
4. Генерация pg_hba.conf из шаблона
5. Запуск сервиса PostgreSQL
6. Создание баз данных и пользователей

### handlers/main.yml
Обработчики:
- `restart postgresql` - полный перезапуск
- `reload postgresql` - перезагрузка конфигурации

### templates/postgresql.conf.j2
Шаблон основной конфигурации:
- Настройки подключений (listen_addresses, port)
- Ресурсы (shared_buffers, work_mem)
- WAL и репликация (wal_level, max_wal_senders)
- Логирование (log_directory, log_filename)

### templates/pg_hba.conf.j2
Шаблон правил аутентификации:
- local соединения через peer
- host соединения через md5
- репликация с определенных адресов

### meta/main.yml
Метаданные для Ansible Galaxy:
- Автор, лицензия
- Поддерживаемые платформы (Ubuntu, Debian)
- Теги: database, postgresql, replication

## Тестирование с Molecule

### molecule/default/molecule.yml
Конфигурация тестов:
- Драйвер: Docker
- Платформа: ubuntu:20.04
- Тесты: create → converge → verify → destroy

### molecule/default/converge.yml
Плейбук сходимости - применяет роль с тестовыми переменными.

## Запуск

```bash
cd lab5

# Запуск виртуальных машин
vagrant up

# Развертывание PostgreSQL
ansible-playbook -i inventories/production.yml deploy_postgresql.yml

# Тестирование роли с Molecule
cd roles/postgresql
molecule test
```

## Результат

После выполнения:
- PostgreSQL 14 работает на 192.168.56.21:5432
- База данных `app_db` создана
- Пользователь `app_user` настроен
- Репликация готова к использованию
