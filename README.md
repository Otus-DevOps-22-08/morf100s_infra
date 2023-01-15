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

# Использование Packer для создания кастомных образов
Packer позволяет создавать образы дисков виртуальных машин с заданными в конфигурационном файле параметрами.

Файлы для использования Packer хранятся в каталоге `packer`

## Подготовка для билда
Для использования packer требуется подготовить:
 - сервисный аккаунт
 - файл шаблона
 - файл с параметрами

#### Сервисный аккаунт

Получите ваш `folder-id` - ID каталога в Yandex.Cloud:
```
$ yc config list
```
Создайте сервисный аккаунт:
```
$ SVC_ACCT="<придумайте имя>"
$ FOLDER_ID="<замените на собственный>"
$ yc iam service-account create --name $SVC_ACCT --folder-id $FOLDER_ID
```

Выдайте права аккаунту:
```
$ ACCT_ID=$(yc iam service-account get $SVC_ACCT | \
grep ^id | \
awk '{print $2}')
$ yc resource-manager folder add-access-binding --id $FOLDER_ID \
--role editor \
--service-account-id $ACCT_ID
```
Создайте IAM key и экспортируйте его в файл. Помните, что
файлы, содержащие секреты, необходимо хранить за пределами
вашего репозитория.
```
$ yc iam key create --service-account-id $ACCT_ID --output <вставьте свой путь>/key.json
```
#### Шаблон
Внутри директории packer распологается файл `ubuntu16.json`. Это Packer шаблон, содержащий описание образа VM,
который мы хотим создать. Для нашего приложения мы
соберем образ VM с предустановленными Ruby и MongoDB,так
называемый baked-образ.

В каталоге `scripts`, размещаются скрипты которые будут использованы в секции `provisioners`. Эти скрипты установят Ruby и MongoDB.

#### Параметры
Для придания гибкости билду используется файл параметров `variables.json`, пример такого файла в `variables.json.example`.
В файле можно вынести все параметры которые отличаются в зависимости от зоны, организации сети и сервисных аккаунтов.

## Билд через PAcker
После настройки файлов и параметров билда можно проверить корректность с помощью команды:
```
packer validate -var-file=variables.json ./ubuntu16.json
```
Если все в порядке, можно приступать к билду:
```
packer build -var-file=variables.json ubuntu16.json
```

Список кастомных образов для ВМ можно посмотреть на странице:
`https://console.cloud.yandex.ru/folders/<id каталога>/compute/images`

Или с помощью утилиты `yc`:
```
yc compute image list
```

# Практика IaC с использованием Terraform
В этом разделе мы будем использовать Terraform для развертывания инфраструктуры в Yandex Cloud. Используемая версия Terraform v1.3.5

## Подготовка
### Provider
Для использования terraform с yandex cloud необходимо установить  провайдера:
https://developer.hashicorp.com/terraform/downloads

Для доступа к облаку необходимо указать cloud-id, folder-id, zone и token/service_account.
Для получение можно использовать команду:
```
yc config list
```

### Service account
Более правильным вариантом будет использование сервисного аккаунта. Получить его можно следующим образом:
https://cloud.yandex.com/en/docs/iam/operations/iam-token/create-for-sa#keys-create

Для использования файла с ключом необходимо указать имя файлы или полный путь к файлу.

### Инициализация

## Использование
Поставка состоит из:
 - `files` - каталог с файлами для конфигурирования ВМ
 - `key.json.example` - примера файла с ключом service_account
 - `lb.tf` - создание ресурсов балансировщика и таргет группы
 - `main.tf` - основной файл, создание ресурсов ВМ
 - `outputs.tf` - файл вывода выходных переменных
 - `terraform.tfvars.example` - примера файла с перемеными дл terraform
 - `variables.tf` - файл определяющий переменные

Для использования применяются следующие комманды:
 - Показать текущие ресурсы, "состояние": `terraform show`
 - Проверка конфигурации на валидность: `terraform validate`
 - Форматирование файлов *.tf: `terraform fmt`
 - Построение плана изменений: `terraform plan`
 - Применение конфигурации всех ресурсов: `terraform apply -auto-approve`
 - Удаление всех ресурсов: `terraform destroy`

## Описание
Файлы terraform описывают создание 2-х вирутальных машин, из образа подготовленного в прошлом разделе. Поскольку ВМ может быть более одной, для балансировки трафика используется "Yandex Network Load Balancer". При добавленни инстансов, чтобы не копировать много кода, используется "универсальная" установка, это снижеет риск ошибки и минимизирует код. Колличество истансов виртуальных машин задается в переменой `count_instance` в файле `terraform.tfvars`. Образ ВМ в можно также указать в этом файле через его id, пути к приватному и публичному ключам ssh, через переменные `private_key_path` и `public_key_path` соответственно. Инсталляцию можно запустить командой описанной выше. В конце инсталляции будут показаны IP адреса ВМ и балансировщика. Пример вывода:
```
...
Outputs:

external_ip_address_balancer = [
    [
        "51.250.2.182",
    ],
]
instance_external_ip = [
    "51.250.7.42",
    "51.250.90.176",
]

```

# Принципы организации инфраструктурного кода и работа над инфраструктурой в команде на примере Terraform

Раздел базируется на предыдущем. В нем будет пошена гибкость за счет использование модулей, бэкенда s3 для хранения состояния terraform и разделение на среды.


## Подготовка
Файлы terraform разбиты по каталогам `prod` и `stage` для разделения по средам. Общий код для каждой среды вынесен в модули. Поэтому, для использования новой структуры файлов необходимо файлы `backend.tf.example`, `key.json.example` и `terraform.tfvars.example` скопировать в каталоги `prod` и `stage` поменяв фейковые реквизиты на реальные.

Для использования бэкенда terraform необходимо настроит создать s3 бакет (-ы) и настроить доступ к ним в файлах `backend.tf`. 
Как создать бакет (-ы) описано в оф.документации:
https://cloud.yandex.ru/docs/storage/operations/buckets/create
Создание реквизитов доступа в бакет:
https://cloud.yandex.ru/docs/iam/operations/sa/create-access-key

## Описание
После настройки файлов `backend.tf.example`, `key.json.example` и `terraform.tfvars` необходимо в каталогах `prod` и `stage` запустить `terraform init` для конфигурирования s3 как backend для terraform, для каждой их сред.
Далее, каждая из сред может быть развернута с помощью команды:
```
terraform apply -auto-approve
```
Подробности см. в предыдущем разделе.