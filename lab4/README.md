# Лабораторная работа 4: Развертывание OpenVPN-сервера

## Описание

Данная лабораторная работа демонстрирует создание Ansible-роли для автоматизированного развертывания OpenVPN-сервера с полной настройкой PKI-инфраструктуры и генерацией клиентских конфигураций. Включает тестирование с помощью Molecule.

## Структура файлов

```
lab4/
├── inventory.ini          # Инвентарь хостов
├── openvpn_final.yml      # Основной плейбук
└── openvpn_role/          # Ansible-роль OpenVPN
    ├── .ansible-lint      # Конфигурация линтера
    ├── client1.ovpn       # Пример клиентского конфига
    ├── defaults/
    │   └── main.yml       # Переменные по умолчанию
    ├── handlers/
    │   └── main.yml       # Обработчики событий
    ├── meta/
    │   └── main.yml       # Метаданные роли
    ├── molecule/
    │   └── default/       # Конфигурация тестов Molecule
    │       ├── converge.yml
    │       ├── molecule.yml
    │       └── verify.yml
    ├── tasks/
    │   └── main.yml       # Основные задачи
    └── templates/
        └── server.conf.j2 # Шаблон конфигурации сервера
```

## Описание файлов

### inventory.ini

Файл инвентаря для подключения к Docker-контейнеру:
```ini
[openvpn_servers]
openvpn-test ansible_connection=docker
```

### openvpn_final.yml

Основной плейбук для развертывания OpenVPN на localhost:
- Применяет роль `openvpn_role`
- Задает адрес сервера и путь для выходных файлов

### Роль openvpn_role

#### defaults/main.yml

Переменные по умолчанию:

**Настройки OpenVPN:**
- `openvpn_port: 1194` — порт сервера
- `openvpn_protocol: udp` — протокол
- `openvpn_network: 10.8.0.0` — VPN-сеть
- `openvpn_netmask: 255.255.255.0` — маска сети

**Настройки EasyRSA (PKI):**
- `easyrsa_country`, `easyrsa_province`, `easyrsa_city` — данные сертификата
- `easyrsa_key_size: 2048` — размер ключа
- `easyrsa_ca_expire: 3650` — срок действия CA (10 лет)
- `easyrsa_cert_expire: 365` — срок действия сертификатов (1 год)

#### tasks/main.yml

Основные задачи роли:

1. **Подготовка системы:**
   - Обновление кэша apt
   - Добавление репозиториев universe и multiverse
   - Установка OpenVPN, Easy-RSA, OpenSSL

2. **Настройка PKI-инфраструктуры:**
   - Создание директорий `/etc/openvpn/pki`, `/etc/openvpn/server`, `/etc/openvpn/client`
   - Копирование файла переменных EasyRSA
   - Инициализация PKI (`easyrsa init-pki`)
   - Генерация CA-сертификата (`easyrsa build-ca nopass`)

3. **Генерация серверных сертификатов:**
   - Создание запроса сертификата сервера
   - Подпись сертификата сервера
   - Генерация параметров Diffie-Hellman

4. **Генерация клиентских сертификатов:**
   - Создание запроса клиентского сертификата
   - Подпись клиентского сертификата
   - Сборка файла `.ovpn` со встроенными сертификатами

5. **Настройка сервера:**
   - Применение шаблона конфигурации `server.conf.j2`
   - Включение IP-forwarding
   - Запуск OpenVPN-сервера

#### templates/server.conf.j2

Jinja2-шаблон конфигурации сервера:
```
port {{ openvpn_port }}
proto {{ openvpn_protocol }}
dev tun
ca /etc/openvpn/pki/ca.crt
cert /etc/openvpn/pki/issued/server.crt
key /etc/openvpn/pki/private/server.key
dh /etc/openvpn/pki/dh.pem
server {{ openvpn_network }} {{ openvpn_netmask }}
push "redirect-gateway def1 bypass-dhcp"
push "dhcp-option DNS 8.8.8.8"
keepalive 10 120
cipher AES-256-CBC
```

#### meta/main.yml

Метаданные роли для Ansible Galaxy:
- Автор, описание, лицензия
- Минимальная версия Ansible: 2.9
- Поддерживаемые платформы: Ubuntu

### Тестирование с Molecule

#### molecule/default/molecule.yml

Конфигурация тестового окружения:
- Драйвер: Docker
- Платформа: Ubuntu 20.04
- Провиженер: Ansible

#### molecule/default/converge.yml

Плейбук для тестовой сходимости — импортирует задачи роли с тестовыми переменными.

#### molecule/default/verify.yml

Тесты верификации:
1. Проверка установки OpenVPN
2. Проверка существования файла `.ovpn`
3. Проверка запуска процесса OpenVPN
4. Проверка включения IP-forwarding
5. Проверка существования конфигурации сервера
6. Проверка всех сертификатов

## Использование

```bash
cd lab4

# Запуск роли локально
ansible-playbook openvpn_final.yml

# Запуск тестов Molecule
cd openvpn_role
molecule test
```

## Архитектура

```
┌─────────────────────────────────────────────┐
│              OpenVPN Server                 │
│                                             │
│   ┌─────────────┐    ┌─────────────────┐   │
│   │   EasyRSA   │───│       PKI        │   │
│   │   (CA)      │    │  - ca.crt       │   │
│   └─────────────┘    │  - server.crt   │   │
│                      │  - server.key   │   │
│                      │  - client1.crt  │   │
│                      │  - client1.key  │   │
│                      │  - dh.pem       │   │
│                      └─────────────────┘   │
│                              │              │
│                      ┌───────▼───────┐     │
│                      │ OpenVPN Server│     │
│                      │  :1194/UDP    │     │
│                      └───────────────┘     │
└─────────────────────────────────────────────┘
              │
              │ VPN Tunnel (10.8.0.0/24)
              ▼
┌─────────────────────────────────────────────┐
│           VPN Client (client1.ovpn)         │
└─────────────────────────────────────────────┘
```

## Генерируемые файлы

После выполнения роли создаются:
- `/etc/openvpn/server.conf` — конфигурация сервера
- `/etc/openvpn/pki/` — PKI-инфраструктура
- `client1.ovpn` — готовый файл для подключения клиента
