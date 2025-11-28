# Infrastructure as Code

Репозиторий с лабораторными работами по теме "Инфраструктура как код" (Infrastructure as Code) с использованием Ansible, Vagrant и Molecule.

## Содержание

- [Лабораторная работа 3: Nginx + Docker](#лабораторная-работа-3)
- [Лабораторная работа 4: OpenVPN](#лабораторная-работа-4)
- [Лабораторная работа 5: PostgreSQL](#лабораторная-работа-5)
- [Лабораторная работа 6: Мониторинг](#лабораторная-работа-6)

## Требования

- [Vagrant](https://www.vagrantup.com/) >= 2.3
- [VirtualBox](https://www.virtualbox.org/) >= 6.1
- [Ansible](https://www.ansible.com/) >= 2.9
- [Python](https://www.python.org/) >= 3.8

## Лабораторная работа 3

**Тема:** Развертывание Nginx и Docker

**Цель:** Автоматизация развертывания веб-инфраструктуры с использованием Nginx как обратного прокси и Docker для контейнеризации Django-приложения.

**Компоненты:**
- Nginx (обратный прокси, статические файлы)
- Docker (контейнеризация)
- Django-приложение

[Подробная документация →](lab3/README.md)

## Лабораторная работа 4

**Тема:** Развертывание OpenVPN-сервера

**Цель:** Создание Ansible-роли для автоматизированного развертывания OpenVPN-сервера с полной настройкой PKI-инфраструктуры.

**Компоненты:**
- OpenVPN-сервер
- Easy-RSA (PKI)
- Генерация клиентских конфигураций
- Тестирование с Molecule

[Подробная документация →](lab4/README.md)

## Лабораторная работа 5

**Тема:** Развертывание PostgreSQL с репликацией

**Цель:** Автоматизация развертывания PostgreSQL-сервера с поддержкой репликации (master/replica).

**Компоненты:**
- PostgreSQL 14
- Streaming Replication
- Управление пользователями и базами данных
- Тестирование с Molecule

[Подробная документация →](lab5/README.md)

## Лабораторная работа 6

**Тема:** Мониторинг с Prometheus, Grafana и Loki

**Цель:** Создание полноценного стека мониторинга для сбора метрик и агрегации логов.

**Компоненты:**
- Prometheus (сбор метрик)
- Grafana (визуализация)
- Loki (агрегация логов)
- Spring Boot Demo (пример приложения)

[Подробная документация →](lab6/README.md)

## Структура проекта

```
.
├── README.md
├── Vagrantfile              # Корневой Vagrantfile
├── requirements.yml         # Зависимости Ansible Galaxy
├── group_vars/              # Глобальные переменные
├── roles/                   # Общие роли
├── lab3/                    # Nginx + Docker
├── lab4/                    # OpenVPN
├── lab5/                    # PostgreSQL
└── lab6/                    # Мониторинг
```

## Быстрый старт

```bash
# Клонирование репозитория
git clone https://github.com/Zisrf/infrasture-as-a-code.git
cd infrasture-as-a-code

# Установка зависимостей Ansible
ansible-galaxy install -r requirements.yml

# Переход к нужной лабораторной работе
cd lab3  # или lab4, lab5, lab6

# Запуск виртуальных машин
vagrant up

# Применение плейбука (если необходимо)
ansible-playbook playbook.yml  # или site.yml, deploy_postgresql.yml
```

## Лицензия

MIT
