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

#### Автоматизация при помощи Ansible в контейнере

https://www.golinuxcloud.com/ansible-architecture/

Под Windows ansible отсутствует, использую docker: microsoft/ansible  
Для вызова нужно передать рабочую директорию и кучу параметров (использовать python3, автоматически принять ssh fingerprint...)

*Проверочный запуск из Powershell*  
`$p=$(pwd).Path; docker run -it -v "${p}/.ssh:/root/.ssh" -v "${p}:/workdir" --workdir "/workdir" --rm microsoft/ansible:latest ansible --ssh-common-args='-o StrictHostKeyChecking=no' --version -e 'ansible_python_interpreter=/usr/bin/python3' -u ubuntu -i hosts all -m ping`  
> ansible 2.7.0  
>   config file = /workdir/ansible.cfg  
>   configured module search path = [u'/root/.ansible/plugins/modules', u'/usr/share/ansible/plugins/modules']  
>   ansible python module location = /usr/lib/python2.7/dist-packages/ansible  
>   executable location = /usr/bin/ansible  
> python version = 2.7.12 (default, Dec  4 2017, 14:50:18) [GCC 5.4.0 20160609]  

Указать версию python3 в ansible.cfg не получилось, пришлось разбить параметры по файлам:  
**ansible.cfg**  
>[defaults]  
>host_key_checking = False  

**hosts**  
>30.x.xx.xx  
>[all:vars]  
>ansible_python_interpreter=/usr/bin/python3  

Поскольку inventory мне не требуется, запускать буду с переменными (IP и hostname укажу прямо в командной строке). Но и версию python тогда тоже приходится.  
*Важно: при указании хоста вместо инвентори после него необходима запятая.*  
`$p=$(pwd).Path; docker run -it -v "${p}/.ssh:/root/.ssh" -v "${p}:/workdir" --workdir "/workdir" --rm microsoft/ansible:latest ansible-playbook --become -e "ansible_python_interpreter=/usr/bin/python3" -u ubuntu -i 18.156.114.157, --extra-vars "hostname=testaws" stdprep.yml`  

**ansiplay.ps1**  
> $p=$(pwd).Path; docker run -it -v "${p}/.ssh:/root/.ssh" -v "${p}:/workdir" --workdir "/workdir" --rm microsoft/ansible:latest ansible-playbook --become -e "ansible_python_interpreter=/usr/bin/python3" -u ubuntu -i $args[0], --extra-vars "$args[1]" $args[2] $args[3] $args[4] $args[5] $args[6] #  --extra-vars "hostname=testaws" stdprep.yml  

`ansiplay.ps1 18.156.114.157 hostname=testaws stdprep.yml`  

При ошибке *ERROR! the playbook: hostname=testaws could not be found* может потребоваться:  
`$p=$(pwd).Path; docker run -it -v "${p}/.ssh:/root/.ssh" -v "${p}:/workdir" --workdir "/workdir" --rm microsoft/ansible:latest chmod 775 .`

*Важно: Копируемые конфигурационные файлы должны быть сохранены в Unix формате (LF), а не CR/LF.*  

## Kubernetes installation

## Prep packages

**k8s.yml**: Устанавливаются необходимые пакеты через скрипт k8s_install.sh (kubelet kubeadm kubectl docker.io)  

## k8s 

**k8s.yml**  

`sudo kubeadm init`  
Для Master вручную, ибо это единоразовое действие.  
Также вручную можно установить требуемый CNI.  
Например, для flannel:  
`kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml`  

Для worker можно раскомментировать строки с secret token, если нужно создать их несколько, поскольку token общий для всех добавляемых worker nodes.  

    To start using your cluster, you need to run the following as a regular user:  
      
      mkdir -p $HOME/.kube  
      sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config  
      sudo chown $(id -u):$(id -g) $HOME/.kube/config  
      
    Alternatively, if you are the root user, you can run:  
      
      export KUBECONFIG=/etc/kubernetes/admin.conf  
      
    You should now deploy a pod network to the cluster.  
    Run "kubectl apply -f [podnetwork].yaml" with one of the options listed at:  
      https://kubernetes.io/docs/concepts/cluster-administration/addons/  
    
    Then you can join any number of worker nodes by running the following on each as root:  
      
    kubeadm join 172.19.0.11:6443 --token cxvly5.d5uwv2myuwifippp \  
        --discovery-token-ca-cert-hash sha256:282039669f63854ae6b3ebaa4c268303328221e05c4506452742d9b294ddbfff  

Для flannel в *kubeadm init* нужно передать параметр *--pod-network-cidr=10.244.0.0/16*  
Если это не было сделано, и у подов kube-flannel статус CrashLoopBackOff, это можно полечить командами:  
`kubectl patch node vmmaster -p '{"spec":{"podCIDR":"10.244.0.0/24"}}'`  
`kubectl patch node vmworker -p '{"spec":{"podCIDR":"10.244.0.0/24"}}'`  
Имена нод видны в обычном `kubectl get no -o wide` (причем они ready даже при проблемах с CNI).  

## Yandex k8s

`sudo swapoff -a`  // после рестарта тоже?  
`sudo kubeadm --pod-network-cidr=10.244.0.0/16 init`  
`kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml`  


`kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.0.0/aio/deploy/recommended.yaml`

    cat <<EOF | kubectl apply -f -
    apiVersion: v1
    kind: ServiceAccount
    metadata:
      name: admin-user
      namespace: kubernetes-dashboard
    EOF

    cat <<EOF | kubectl apply -f -
    apiVersion: rbac.authorization.k8s.io/v1
    kind: ClusterRoleBinding
    metadata:
      name: admin-user
    roleRef:
      apiGroup: rbac.authorization.k8s.io
      kind: ClusterRole
      name: cluster-admin
    subjects:
    - kind: ServiceAccount
      name: admin-user
      namespace: kubernetes-dashboard
    EOF

    kubectl -n kubernetes-dashboard describe secret $(kubectl -n kubernetes-dashboard get secret | grep admin-user | awk '{print $1}')

Вероятно не нужно добавлять пользователей. Проблема была с попыткой доступа через публичный IP.  

Пробовал `kubectl proxy --address 0.0.0.0 --accept-hosts '.*'` и обращение по публичному адресу. После ввода token ничего не происходило. 
Так и задумано, подключаться можно лишь с локального хоста. Поэтому пробросил порт через ssh.  
`ssh -L 8001:localhost:8001 ubuntu@vmmaster.arlab.pw -i C:\Users\arazumov\.ssh\K8s_key.pem`  
`http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/`  
