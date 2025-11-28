# Лабораторная работа 3: Развертывание Nginx и Docker

## Описание

Данная лабораторная работа демонстрирует использование Ansible для автоматизированного развертывания веб-инфраструктуры с использованием Nginx как обратного прокси и Docker для контейнеризации Django-приложения.

## Структура файлов

```
lab3/
├── Vagrantfile           # Конфигурация виртуальных машин
├── ansible.cfg           # Настройки Ansible
├── inventory.yml         # Инвентарь хостов
├── playbook.yml          # Основной плейбук
└── roles/
    ├── nginx/            # Роль для настройки Nginx
    │   ├── defaults/     # Переменные по умолчанию
    │   ├── handlers/     # Обработчики событий
    │   ├── tasks/        # Задачи роли
    │   └── templates/    # Шаблоны конфигурации
    └── docker/           # Роль для установки Docker
        ├── defaults/     # Переменные по умолчанию
        └── tasks/        # Задачи роли
```

## Описание файлов

### Vagrantfile

Конфигурация для создания двух виртуальных машин с помощью Vagrant:

- **web** (`192.168.56.10`) — веб-сервер с Nginx
  - 1024 МБ ОЗУ, 1 CPU
  - Ubuntu Focal64
  
- **app** (`192.168.56.11`) — сервер приложений с Docker
  - 2048 МБ ОЗУ, 2 CPU
  - Ubuntu Focal64

### ansible.cfg

Файл конфигурации Ansible:
- Указывает на файл инвентаря `inventory.yml`
- Отключает проверку ключей хостов
- Настраивает SSH-подключение с использованием приватных ключей Vagrant

### inventory.yml

Файл инвентаря в формате INI, определяющий группы хостов:
- Группа `[web]` — веб-серверы с Nginx
- Группа `[app]` — серверы приложений с Docker

### playbook.yml

Основной плейбук с двумя play:
1. **Configure web servers with Nginx** — применяет роль `nginx` к группе `web`
2. **Configure app servers with Docker and Django** — применяет роль `docker` к группе `app`

### Роль nginx

**defaults/main.yml** — переменные по умолчанию:
- `static_files_path` — путь к статическим файлам
- `media_files_path` — путь к медиа файлам
- `django_host` и `django_port` — адрес Django-приложения

**tasks/main.yml** — задачи:
1. Обновление кэша apt
2. Установка Nginx
3. Включение и запуск сервиса Nginx
4. Удаление конфигурации сайта по умолчанию
5. Применение шаблона конфигурации для Django
6. Создание директорий для статических и медиа файлов

**handlers/main.yml** — обработчик для перезапуска Nginx при изменении конфигурации

**templates/site.conf.j2** — Jinja2-шаблон конфигурации Nginx:
- Настройка обратного прокси к Django-приложению
- Обслуживание статических и медиа файлов
- Настройка кэширования

### Роль docker

**defaults/main.yml** — переменные по умолчанию:
- `django_image` — Docker-образ Django-приложения
- `django_port` — порт приложения
- Названия томов для статики и медиа

**tasks/main.yml** — задачи:
1. Установка зависимостей для Docker
2. Добавление GPG-ключа и репозитория Docker
3. Установка Docker CE
4. Добавление пользователя в группу docker
5. Запуск сервиса Docker
6. Загрузка и запуск контейнера Django

## Использование

```bash
# Запуск виртуальных машин
cd lab3
vagrant up

# Применение плейбука
ansible-playbook playbook.yml
```

## Известные проблемы

### Контейнер Django не запускается

В файле `roles/docker/tasks/main.yml` используется условие с `ansible_facts.docker_containers`, которое не является стандартным фактом Ansible. Для корректной работы рекомендуется заменить задачу "Start Django container" на следующую:

```yaml
- name: Check if Django container exists
  shell: docker ps -a --filter "name=django_app" --format "{{ '{{' }}.Names{{ '}}' }}"
  register: django_container
  changed_when: false

- name: Start Django container
  shell: |
    docker run -d \
      --name django_app \
      -p {{ django_port }}:8000 \
      -v {{ static_volume }}:/home/django/static \
      -v {{ media_volume }}:/home/django/media \
      --restart unless-stopped \
      {{ django_image }}
  become: yes
  when: django_container.stdout == ""
```

Или использовать модуль `community.docker.docker_container` для более надежного управления контейнерами.

## Архитектура

```
┌─────────────────┐      ┌─────────────────┐
│   Web Server    │      │   App Server    │
│   (192.168.56.10)│      │   (192.168.56.11)│
│                 │      │                 │
│   ┌─────────┐   │      │   ┌─────────┐   │
│   │  Nginx  │──────────────│ Docker  │   │
│   └─────────┘   │:8000  │   └─────────┘   │
│                 │      │        │        │
│   /static/      │      │   ┌─────────┐   │
│   /media/       │      │   │ Django  │   │
└─────────────────┘      │   └─────────┘   │
                         └─────────────────┘
```
