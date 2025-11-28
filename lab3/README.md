# Lab 3 - Развертывание Nginx + Docker + Django с помощью Ansible

## Описание

Эта лабораторная работа демонстрирует развертывание многоуровневого веб-приложения с использованием Ansible ролей. Система состоит из:
- **Web-сервер** (Nginx) - проксирование запросов к Django-приложению
- **App-сервер** (Docker + Django) - контейнеризированное Django-приложение

## Структура файлов

```
lab3/
├── Vagrantfile          # Конфигурация виртуальных машин
├── ansible.cfg          # Настройки Ansible
├── inventory.yml        # Инвентарь хостов
├── playbook.yml         # Главный плейбук
└── roles/
    ├── docker/          # Роль для установки Docker и запуска Django
    │   ├── defaults/main.yml   # Переменные по умолчанию
    │   └── tasks/main.yml      # Задачи установки Docker
    └── nginx/           # Роль для настройки Nginx
        ├── defaults/main.yml   # Переменные по умолчанию
        ├── handlers/main.yml   # Обработчики событий
        ├── tasks/main.yml      # Задачи установки Nginx
        └── templates/
            └── site.conf.j2    # Шаблон конфигурации Nginx
```

## Описание файлов

### Vagrantfile
Создает две виртуальные машины:
- **web** - Ubuntu 20.04, 1GB RAM, IP: 192.168.56.10
- **app** - Ubuntu 20.04, 2GB RAM, IP: 192.168.56.11

### ansible.cfg
Конфигурация Ansible:
- Отключена проверка SSH-ключей хоста
- Указан путь к приватным ключам Vagrant
- Включен pipelining для ускорения выполнения

### inventory.yml
Определяет группы хостов:
- `[web]` - веб-серверы с настройками Nginx
- `[app]` - серверы приложений с настройками Docker

### playbook.yml
Главный плейбук, который:
1. Применяет роль `nginx` к группе `web`
2. Применяет роль `docker` к группе `app`

### roles/docker/
**defaults/main.yml** - переменные:
- `django_image` - Docker-образ Django
- `django_port` - порт приложения
- `static_volume`, `media_volume` - тома для файлов

**tasks/main.yml** - выполняет:
- Установку Docker CE
- Добавление пользователя в группу docker
- Загрузку и запуск Django-контейнера

### roles/nginx/
**defaults/main.yml** - переменные:
- `static_files_path` - путь к статике
- `django_host`, `django_port` - адрес backend-сервера

**handlers/main.yml** - обработчик перезапуска Nginx

**tasks/main.yml** - выполняет:
- Установку Nginx
- Создание директорий для статики
- Применение шаблона конфигурации

**templates/site.conf.j2** - шаблон Nginx:
- Проксирование запросов к Django
- Раздача статических и медиа файлов
- Настройка заголовков и кэширования

## Запуск

```bash
cd lab3
vagrant up
ansible-playbook playbook.yml
```

## Результат

После выполнения:
- Nginx доступен на http://192.168.56.10
- Запросы проксируются к Django на 192.168.56.11:8000
- Статика раздается напрямую через Nginx
