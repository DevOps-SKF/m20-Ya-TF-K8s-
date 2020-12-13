# Module 20

## Задача

1. Установите Terraform.
2. Установите Kubectl.
3. Изучите документацию по работе с облаком Яндекса по ссылке.
4. Создайте Terraform скрипт, который развернет две виртуальные машины с внешними IP адресами.
5. Изучите документацию по этой ссылке.
6. Установите на обе ваши машины kubeadm, следуя инструкциям из документации.
7. Изучите документацию по этой ссылке.
8. Настройте с помощью kubeadm мастер ноду (можете выбрать любую из двух машин).
9. Скопируйте /etc/kubernetes/admin.conf с мастер ноды себе локально в папку $HOME/.kube/config
10. Настройте вторую машину как воркер ноду, используя kubeadm join.
11. Установите Kubernetes dashboard, выполнив  
kubectl apply -f  
https://raw.githubusercontent.com/kubernetes/dashboard/v2.0.0/aio/deploy/recommended.yaml
12. Выполните  
kubectl proxy
13. Выполните: откройте UI по ссылке.
14. Используйте файл $HOME/.kube/config для входа в UI.  

*Опциональная часть:*  
пункты 6-11 выполнить с помощью Ansible, можно использовать готовые плейбуки, но обязательно использование kubeadm

## branch master

### Remote terraform

remote backend: terraform cloud.  
Не устраивает, что выполняется в облаке Terraform и требует там же задания environment variables с ключами от Яндекс.Облака.  

### Remote Yandex

Не смог перевести remote backend на Yandex  

    backend "s3" {  
        endpoint   = "storage.yandexcloud.net"  
        bucket     = "bsys"  
        region     = "us-east-1"  
        key        = "tf/m20-ya-k8s.tfstate"  
        #access_key = var.yandex_keyid  
        #secret_key = var.yandex_key  
    # terraform init -backend-config "access_key=%TF_VAR_yandex_svcacc_keyid%" -backend-config "secret_key=%TF_VAR_yandex_svcacc_key%"  
        skip_region_validation      = true  
        skip_credentials_validation = true  
    }  

    Error: Error loading state:  
        InvalidBucketName: The specified bucket is not valid.  
            status code: 400, request id: 69a370f218550c2c, host id:  
    Terraform failed to load the default state from the "s3" backend.  
    State migration cannot occur unless the state can be loaded. Backend  
    modification and state migration has been aborted. The state in both the  
    source and the destination remain unmodified. Please resolve the  
    above error and try again.

### Remote AWS

Похоже, достаточно было просто удалить файл .terraform/.terraform.tfstate, чтобы remote backend в Yandex заработал.

Впрочем, все равно могли быть конфликты с переменными окружения для доступа к "настоящему" AWS, поскольку используется тот же `backend "s3"`. Так что теперь все state  будут в AWS.  

### Create VM

https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs

Узнать disk_id: `yc compute image list --folder-id standard-images`  
ubuntu-2004-lts: fd8vmcue7aajpmeo39kk

Создалась VM, по публичному IP можно на нее зайти.  
Теперь Destroy. Вернусь для развертывания Kubernetes.  

### Ansible stdprep

Ansible playbook для первоначальной подготовки хоста (hostname, timezone, ddns client...)
