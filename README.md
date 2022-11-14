# Bastion хост
Данный раздел описывает различное использование подлючений через bastion хост. Использование bastion хоста уменьшает площадь атаки на инфраструктуру и дает возможность жесткого логирования подлючений, за счет использования единой точки входа.

###

### Подключения к хосту за bastion-ом в одну команду

Для подключения в одну команду, следует использовать функционал SSH Jump сервера (ProxyJump) на bastion хосте.

```
ssh -J <bastion-host> <remote-host>
```

Если у целевого и bastion хостов отличаются имена пользователей, следует указать их в команде:
```
ssh -J user1@<bastion:port> user2@<target:port>
```

### Использование алиасов подключений

Для удобства использования существует возможность создать "сет" параметров ssh подключения через bastion хост. Для этого требуется в файле `~/.ssh/config` создать блок кода описывающий подключение. Например:
```
### The Remote Host
Host remote-host-nickname
  HostName appuser@remote-hostname
  ProxyJump jumpuser@bastion-host-nickname
```

Теперь, при выполнении команды `ssh remote-host-nickname` произойдет её "прозрачное" преобразование в `ssh appuser@remote-hostname jumpuser@bastion-host-nickname`, что приведет к простому подлючению по ssh к целевому серверу через bastion хост.

Например, для существующей инсталляции:
```
[zcar@20sl morf100s_infra]$ cat ~/.ssh/config
Host someinternalhost
  HostName 10.128.0.15
  User appuser
  IdentityFile ~/.ssh/id_rsa
  Port 22
  ProxyJump appuser@51.250.13.176
[zcar@20sl morf100s_infra]$ ssh someinternalhost
Welcome to Ubuntu 20.04.4 LTS (GNU/Linux 5.4.0-124-generic x86_64)

 * Documentation:  https://help.ubuntu.com
 * Management:     https://landscape.canonical.com
 * Support:        https://ubuntu.com/advantage
Failed to connect to https://changelogs.ubuntu.com/meta-release-lts. Check your Internet connection or proxy settings

Last login: Thu Oct  6 09:53:52 2022 from 10.128.0.14
appuser@someinternalhost:~$ hostname
someinternalhost
appuser@someinternalhost:~$
```

 - Дополнительную информацию можно найти в официальной документации вашего ssh клиента, для OpenSSH клиента это:
https://man.openbsd.org/ssh_config


### Использование VPN подключения

На bastion хосте может быть развернут VPN сервер, через который также возможно подключение к хосту в закрытом контуре. Ниже описано подключение к существующей инсталляции.

```
bastion_IP = 51.250.13.176
someinternalhost_IP = 10.128.0.15
```

С помощью сервисов https://sslip.io/ и https://letsencrypt.org/ соединение к web интерфейсу зашифровано TLS.

# Деплой тестового приложения
Данный раздел описывает создание виртуальной машины (ВМ) в Yandex Cloud и деплой тестового приложения на данную машину.


### Создание ВМ

Для создание ВМ можно воспользоваться CLI или web интерфейсом Yandex Cloud.

#### CLI
Для создания ВМ выполните команду:

```
yc compute instance create --name reddit-app --hostname reddit-app --memory=4 --core-fraction 20 --create-boot-disk image-folder-id=standard-images,image-family=ubuntu-1604-lts,size=10GB --network-interface subnet-name=default-ru-central1-a,nat-ip-version=ipv4 --metadata serial-port-enable=1 --ssh-key /home/zcar/.ssh/id_rsa.pub
```

Где `/home/zcar/.ssh/id_rsa.pub` пусть в вашему публичному ключ.
> Внимание: в данной команде создается ВМ с гарантированной долей vCPU в 20%, если вам требуется другое значение укажите его или опустите ключ `--core-fraction` для использование 100%

Результатом команды будет yaml с характеристиками созданной ВМ.

#### Web
Для создания ВМ с помощью web интерефейса можно воспользоваться документацией Yandex Cloud:
https://cloud.yandex.ru/docs/compute/quickstart/quick-create-linux

### Подготовка и деплой приложения
Деплой приложения разделен на 3 части:
 - подготовка ВМ
 - установка БД
 - деплой приложения

Для выполнения данных шагов, последовательно запустите скрипты:
 - install_ruby.sh
 - install_mongodb.sh
 - deploy.sh

> Внимание: перед запуском скриптов укажите значение переменной SSH_HOST, переменная содержит IP адрес ВМ соданный в предыдущем шаге (содержится в yaml, путь `network_interfaces.primary_v4_address.one_to_one_nat.address`).

### Реквизиты тестового приложения

```
testapp_IP = 158.160.43.108
testapp_port = 9292
```
