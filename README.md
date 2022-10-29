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