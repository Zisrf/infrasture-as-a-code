# Lab 1: Ansible Deployment of Django Application

## Цель работы
Запустить приложение при помощи Ansible, научиться писать плейбуки и пользоваться group vars.

## Установка необходимых инструментов

### 1. Установка Ansible
Следуйте инструкциям: https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html

```bash
# Для Ubuntu/Debian
sudo apt update
sudo apt install ansible

# Для macOS
brew install ansible
```

### 2. Установка Vagrant
Следуйте инструкциям: https://developer.hashicorp.com/vagrant/downloads

### 3. Запуск Vagrant хостов
Используйте Vagrantfile из предоставленной ссылки и запустите:
```bash
vagrant up
```

## Структура проекта

```
.
├── README.md              # Данный файл с инструкциями
├── inventory.ini          # Inventory-файл с описанием хостов
├── install_docker.yml     # Плейбук для установки Docker
├── deploy_app.yml         # Плейбук для развертывания Django приложения
├── site.yml              # Главный плейбук
└── group_vars/           # Переменные для групп хостов
    ├── all.yml          # Переменные для всех хостов
    └── app.yml          # Переменные для группы [app]
```

## Описание файлов

### inventory.ini
Содержит описание хостов с группами:
- `[app]` - хосты для приложения
- `[db]` - хосты для базы данных

### install_docker.yml
Плейбук для установки Docker на всех хостах:
- Обновление кэша пакетов
- Установка зависимостей
- Добавление GPG ключа Docker
- Добавление репозитория Docker
- Установка Docker
- Запуск и включение сервиса Docker
- Добавление пользователя vagrant в группу docker

### deploy_app.yml
Плейбук для развертывания Django приложения на хостах группы [app]:
- Установка git
- Клонирование репозитория https://github.com/mdn/django-locallibrary-tutorial
- Загрузка Docker-образа timurbabs/django
- Запуск контейнера с приложением

### group_vars/
Директория с переменными для групп:
- `all.yml` - переменные для всех хостов
- `app.yml` - переменные для группы [app] (URL репозитория, образ Docker, порты)

## Использование

### Запуск всех плейбуков
```bash
ansible-playbook -i inventory.ini site.yml
```

### Запуск отдельных плейбуков

#### Установка Docker
```bash
ansible-playbook -i inventory.ini install_docker.yml
```

#### Развертывание приложения
```bash
ansible-playbook -i inventory.ini deploy_app.yml
```

### Проверка подключения к хостам
```bash
ansible -i inventory.ini all -m ping
```

### Проверка хостов группы [app]
```bash
ansible -i inventory.ini app -m ping
```

## Проверка работы приложения

После успешного выполнения плейбуков, Django приложение будет доступно:
- На хосте app1: http://192.168.56.10:8000

## Примечания

- Убедитесь, что Vagrant хосты запущены перед выполнением плейбуков
- SSH ключи для подключения к хостам находятся в `.vagrant/machines/`
- Приложение запускается в Docker контейнере с автоматическим перезапуском
- Репозиторий клонируется в `/opt/django-locallibrary-tutorial`

## Docker-образ
https://hub.docker.com/repository/docker/timurbabs/django

## Исходный репозиторий Django приложения
https://github.com/mdn/django-locallibrary-tutorial
