# Лабораторная работа №6: Мониторинг серверных приложений

## Описание

Эта лабораторная работа демонстрирует настройку полноценной системы мониторинга для Spring Boot приложения с использованием Prometheus, Grafana, Loki и Alertmanager.

## Архитектура

- **app (192.168.56.30)**: Виртуальная машина с Spring Boot приложением
  - Spring Boot Demo приложение
  - Экспорт метрик через /actuator/prometheus
  
- **monitoring (192.168.56.31)**: Виртуальная машина с системой мониторинга
  - Prometheus (порт 9090) - сбор метрик
  - Grafana (порт 3000) - визуализация метрик
  - Loki (порт 3100) - агрегация логов
  - Alertmanager (порт 9093) - управление алертами и отправка email уведомлений

## Компоненты

### Ansible роли

Все роли разработаны с поддержкой Molecule для тестирования:

1. **prometheus** - Установка и настройка Prometheus
   - Сбор метрик с приложения
   - Настройка правил алертинга
   - Интеграция с Alertmanager

2. **alertmanager** - Установка и настройка Alertmanager
   - Управление алертами
   - **Отправка email уведомлений**
   - Группировка и фильтрация алертов

3. **grafana** - Установка и настройка Grafana
   - Автоматическая настройка источников данных (Prometheus, Loki)
   - Предустановленные дашборды
   - Визуализация метрик Spring Boot

4. **loki** - Установка и настройка Loki
   - Агрегация логов
   - Интеграция с Grafana

5. **spring_boot_app** - Развертывание Spring Boot приложения
   - Клонирование и сборка приложения
   - Настройка экспорта метрик Prometheus
   - Настройка логирования

## Быстрый старт

### 1. Запуск виртуальных машин

```bash
cd lab6
vagrant up
```

### 2. Развертывание системы мониторинга и приложения

```bash
ansible-playbook -i inventories/hosts.ini deploy.yml
```

### 3. Доступ к сервисам

После успешного развертывания доступны следующие сервисы:

- **Spring Boot приложение**: http://192.168.56.30:8080
- **Метрики приложения**: http://192.168.56.30:8080/actuator/prometheus
- **Prometheus**: http://192.168.56.31:9090
- **Grafana**: http://192.168.56.31:3000 (admin/admin)
- **Alertmanager**: http://192.168.56.31:9093
- **Loki**: http://192.168.56.31:3100

## Настройка Email алертинга

Для настройки отправки email уведомлений отредактируйте файл `group_vars/all.yml`:

```yaml
smtp_host: "smtp.gmail.com"
smtp_port: 587
smtp_from: "your-email@gmail.com"
smtp_to: "recipient@example.com"
smtp_username: "your-email@gmail.com"
smtp_password: "your-app-password"
```

**Важно**: Для Gmail необходимо создать App Password в настройках безопасности аккаунта.

## Тестирование ролей с Molecule

Каждая роль может быть протестирована отдельно с помощью Molecule:

```bash
# Установка Molecule (если не установлен)
pip install molecule molecule-docker

# Тестирование роли Prometheus
cd roles/prometheus
molecule test

# Тестирование роли Grafana
cd roles/grafana
molecule test

# Тестирование роли Alertmanager
cd roles/alertmanager
molecule test

# Тестирование роли Loki
cd roles/loki
molecule test

# Тестирование роли Spring Boot
cd roles/spring_boot_app
molecule test
```

## Дашборды Grafana

После развертывания в Grafana автоматически настраивается дашборд "Spring Boot Application Metrics" со следующими панелями:

- HTTP Request Rate - частота HTTP запросов
- HTTP Response Time - время ответа
- JVM Heap Memory - использование памяти JVM
- CPU Usage - использование процессора
- JVM Threads - количество потоков JVM

## Алерты

Настроены следующие правила алертинга:

1. **InstanceDown** (Critical) - сервис недоступен более 2 минут
2. **HighMemoryUsage** (Warning) - использование памяти выше 85%
3. **HighCPUUsage** (Warning) - использование CPU выше 80%
4. **ApplicationResponseTimeHigh** (Warning) - время ответа выше 1 секунды
5. **ApplicationErrorRateHigh** (Critical) - частота ошибок выше 5%

При срабатывании алертов отправляются email уведомления с подробной информацией.

## Структура проекта

```
lab6/
├── Vagrantfile                 # Конфигурация виртуальных машин
├── ansible.cfg                 # Конфигурация Ansible
├── deploy.yml                  # Главный playbook
├── inventories/
│   └── hosts.ini              # Инвентарь хостов
├── group_vars/
│   └── all.yml                # Общие переменные
└── roles/
    ├── prometheus/            # Роль Prometheus
    ├── alertmanager/          # Роль Alertmanager
    ├── grafana/               # Роль Grafana
    ├── loki/                  # Роль Loki
    └── spring_boot_app/       # Роль Spring Boot приложения
```

## Требования

- Vagrant
- VirtualBox
- Ansible 2.9+
- Python 3
- Molecule (для тестирования ролей)
- Docker (для тестирования Molecule)

**Важно для пользователей Windows:**
- Рекомендуется использовать WSL2 (Windows Subsystem for Linux) для запуска Ansible
- При использовании Git Bash могут возникать проблемы с Python/Ansible
- Альтернатива: запускать команды Ansible вручную (см. QUICK_START.md)

## Очистка

```bash
# Остановка и удаление виртуальных машин
vagrant destroy -f

# Очистка Molecule тестов
cd roles/<role_name>
molecule destroy
```

## Полезные команды

```bash
# Проверка статуса виртуальных машин
vagrant status

# SSH доступ к виртуальным машинам
vagrant ssh app
vagrant ssh monitoring

# Повторное развертывание только определенной роли
ansible-playbook -i inventories/hosts.ini deploy.yml --tags prometheus

# Проверка доступности хостов
ansible -i inventories/hosts.ini all -m ping
```
