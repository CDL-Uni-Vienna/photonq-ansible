# Setup and Management

### Basic Configuration
#### Set Language and Time
```bash
echo 'photonq' > /etc/hostname
localectl set-locale LANG=en_US.UTF-8
ln -sfn /usr/share/zoneinfo/UTC /etc/localtime
```

#### Add Extra Packages for Enterprise Linux
```bash
dnf distro-sync -y
dnf install epel-release -y
dnf install epel-release -y
```

### User Setup
#### ansible
User with sudo
#### podman
User for unprivileged container management
### Podman Setup
 
### Systemd Setup
 
## Podman Management
##### List all Container
 ```bash
podman ps -a
```
##### Stop all Container
```bash
podman stop -a
```
##### Remove all Container
```bash
podman rm -a
```
##### Remove all Images
```bash
podman rmi -a
```
### Ansible Management
### Vault

### Scripts
#### Deploy
```bash
deploy.sh
```
#### Enable SSH
```bash
enable_ssh_pass.sh
```
#### Setup Local und Remote
```bash
setup.sh
```
#### Get Service Status
```bash
status.sh
```
#### Get Detailed Service Status
```bash
status_detailed.sh
```


