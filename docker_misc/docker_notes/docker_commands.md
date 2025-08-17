

## 🌐 **Chapter 1 — Connecting to Docker Hub on Ubuntu**

### 1. **Understanding Docker Hub** 📚

* Docker Hub is the default **image registry** for Docker 🗄️.
* It stores images publicly (free) or privately (paid) 🔓🔒.
* Every image you `docker pull` without specifying a registry is fetched from Docker Hub.


### 2. **Logging in from Ubuntu** 🔐

The CLI login process:

```bash
docker login
```

You'll enter:

* **Docker Hub username** 👤
* **Password or Personal Access Token** (recommended over raw password) 🔑

If login works, you'll see:

```
Login Succeeded ✅
```

Your login session is stored in:

```
~/.docker/config.json
```

So you don't need to log in every time 🔄.

---

### 3. **Pulling Images from Docker Hub** 📥

* **Public Image** 🌍

  ```bash
  docker pull ubuntu:22.04
  ```

  Anyone can pull public images.

* **Private Image** (requires login) 🔒

  ```bash
  docker pull yourusername/yourimage:tag
  ```

---

### 4. **Pushing Images to Docker Hub** 📤

* **Step 1: Tag the image** 🏷️
  Docker Hub images follow the format:

  ```
  <username>/<repo_name>:<tag>
  ```

  Example:

  ```bash
  docker tag mylocalimage:latest <username>/<repo>:tag 
  ```

* **Step 2: Push** 🚀

  ```bash
  docker push <username>/<repo>:tag 
  ```

---
```bash
docker pull ubuntu:25.04
25.04: Pulling from library/ubuntu
**********: Pull complete ✅
Digest: sha256:*********************************************** 
Status: Downloaded newer image for ubuntu:25.04
docker.io/library/ubuntu:25.04 


docker images
REPOSITORY   TAG       IMAGE ID       CREATED       SIZE
ubuntu       25.04     *********   4 weeks ago   77MB


docker tag ubuntu:25.04 <username>/<repo/img>:tag 
docker push <username>/<repo/img>:tag 
The push refers to repository [docker.io/<username>/<repo/img>:tag ]
aa1ebd8cd082: Mounted from library/ubuntu 📦
01.01: digest: sha256:***********************************************  size: 529


docker tag ubuntu:25.04 <username>/<repo/img>:tag 


docker push zeroisinfinity/test:01.01
The push refers to repository [docker.io/zeroisinfinity/test]
aa1ebd8cd082: Mounted from zeroisinfinity/pluckypuffin 📦
01.01: digest: sha256:*********************************************** size: 529


docker images
REPOSITORY                    TAG       IMAGE ID       CREATED       SIZE
ubuntu                        25.04     *********      4 weeks ago   77MB
        01.01     *********      4 weeks ago   77MB
<username>/<repo>             01.01     *********      4 weeks ago   77MB
```

Great observation! You've actually created 3 tags pointing to the SAME image, not 3 separate images 🎯.
Notice the IMAGE ID:
All three have the same IMAGE ID: 92-----a70c7 (you redacted the middle part, but they're identical)

Same Image Data (77MB) 📦
├── ubuntu:25.04                    ← Original pull
├── <username>/<repo/img> 1         ← Tagged copy  
└── <username>/<repo/img>           ← Tagged copy


```bash
docker system df 
TYPE            TOTAL     ACTIVE    SIZE      RECLAIMABLE
Images          1         0         77MB      77MB (100%)
Containers      0         0         0B        0B
Local Volumes   0         0         0B        0B
Build Cache     0         0         0B        0B
```

### 5. **Verifying Your Images on Docker Hub** ✅

* Go to [https://hub.docker.com/](https://hub.docker.com/) 🌐
* Log in and check under **Repositories** — your pushed image should appear 📂.

---

## **Next Logical Step** ➡️

Now that you can log in and interact with Docker Hub, the natural progression is:

1. **Write your first Dockerfile** 📝
2. **Build an image** 🏗️
3. **Push it to Docker Hub** 📤
4. **Run it anywhere** 🌍

That will complete your first "image lifecycle" from **code → image → container → registry → redeployment** 🔄.

---

Got it — you've already pulled some Ubuntu image (your "plucky puffin" is just Docker giving a random container name) 🐧.
Let's nail the **absolute basics** of Docker commands first, because without these, Dockerfile work will feel abstract.

---

## 💻 **Chapter 3 — Docker CLI Basics on Ubuntu**

We'll keep it to the *core commands you'll use 95% of the time*, applied to your pulled Ubuntu image.

---

### **1️⃣ See Your Images** 👀

```bash
docker images
```

* Shows all images you've downloaded 📊.
* Columns to note:

  * **REPOSITORY** → Image name (e.g., `ubuntu`) 📁
  * **TAG** → Version (e.g., `22.04`, `latest`) 🏷️
  * **IMAGE ID** → Unique identifier 🆔
  * **SIZE** → Disk usage 💾

---

### **2️⃣ Run a Container from an Image** 🚀

```bash
docker run -it ubuntu bash
```

* `-it` → interactive terminal (so you can type commands inside) 💻
* `ubuntu` → name of the image to run 📦
* `bash` → command to run inside container (here, a shell) 🐚

Inside, you're now in the Ubuntu container — isolated from your host OS 🏠.

To exit:

```bash
exit
```
## Postmortem of -t, -i, -it, sleep infinity, exec -it/-i/-t, -d command
```bash
docker run -t ubuntu:25.04 bash
root@d99f96a0aa05:/# ls
^C^C
root@d99f96a0aa05:/# mkdir dirr
^C^C
root@d99f96a0aa05:/# touch 1.txt
^C
got 3 SIGTERM/SIGINTs, forcefully exiting


docker run -i ubuntu:25.04 bash
ls
bin
boot
dev
etc
home
lib
lib64
media
mnt
opt
proc
root
run
sbin
srv
sys
tmp
usr
var
mkdir a
ls
a
bin
boot
dev
etc
home
lib
lib64
media
mnt
opt
proc
root
run
sbin
srv
sys
tmp
usr
var
cd a
ls
touch 1.txt 2.txt 3.txt 3.zip 4.pkl 5.py 
ls
1.txt
2.txt
3.txt
3.zip
4.pkl
5.py
^C^C^C
got 3 SIGTERM/SIGINTs, forcefully exiting


docker run -it ubuntu:25.04 bash
root@7ee973e4741e:/# ls
bin  boot  dev  etc  home  lib  lib64  media  mnt  opt  proc  root  run  sbin  srv  sys  tmp  usr  var
root@7ee973e4741e:/# mkdir a
root@7ee973e4741e:/# ls
a  bin  boot  dev  etc  home  lib  lib64  media  mnt  opt  proc  root  run  sbin  srv  sys  tmp  usr  var
root@7ee973e4741e:/# cd a
root@7ee973e4741e:/a# touch 1.txt 2.txt 3.txt 3.zip 4.pkl 5.py 
root@7ee973e4741e:/a# nano 1.txt
bash: nano: command not found
root@7ee973e4741e:/a# sudo apt install update
bash: sudo: command not found
root@7ee973e4741e:/a# ^C
root@7ee973e4741e:/a# exit
exit



docker run -d ubuntu:25.04 sleep infinity
686a0e9c65aea057544b947fe03c66afe28546e852f0bc13f8aff931b0ca919b


docker ps
CONTAINER ID   IMAGE          COMMAND            CREATED         STATUS         PORTS     NAMES
686a0e9c65ae   ubuntu:25.04   "sleep infinity"   4 seconds ago   Up 4 seconds             priceless_turing
d99f96a0aa05   ubuntu:25.04   "bash"             4 minutes ago   Up 4 minutes             affectionate_williamson
228890fe9575   ubuntu:25.04   "bash"             5 minutes ago   Up 5 minutes             quirky_mirzakhani
8dbdc8c7f1b7   ubuntu:25.04   "bash"             5 minutes ago   Up 5 minutes             focused_borg
4479c45530e3   ubuntu:25.04   "bash"             6 minutes ago   Up 6 minutes             modest_fermat


docker exec -it 686a0e9c65ae bash
root@686a0e9c65ae:/# ls
bin  boot  dev  etc  home  lib  lib64  media  mnt  opt  proc  root  run  sbin  srv  sys  tmp  usr  var
root@686a0e9c65ae:/# cd r
root/ run/  
root@686a0e9c65ae:/# cd root/
root@686a0e9c65ae:~# ls
root@686a0e9c65ae:~# sudo
bash: sudo: command not found
root@686a0e9c65ae:~# apt
apt 3.0.0 (amd64)
Usage: apt [options] command

apt is a commandline package manager and provides commands for
searching and managing as well as querying information about packages.
It provides the same functionality as the specialized APT tools,
like apt-get and apt-cache, but enables options more suitable for
interactive use by default.

Most used commands:
  list - list packages based on package names
  search - search in package descriptions
  show - show package details
  install - install packages
  reinstall - reinstall packages
  remove - remove packages
  autoremove - automatically remove all unused packages
  update - update list of available packages
  upgrade - upgrade the system by installing/upgrading packages
  full-upgrade - upgrade the system by removing/installing/upgrading packages
  edit-sources - edit the source information file
  modernize-sources - modernize .list files to .sources files
  satisfy - satisfy dependency strings

See apt(8) for more information about the available commands.
Configuration options and syntax is detailed in apt.conf(5).
Information about how to configure sources can be found in sources.list(5).
Package and version choices can be expressed via apt_preferences(5).
Security details are available in apt-secure(8).
                                        This APT has Super Cow Powers.
root@686a0e9c65ae:~# apt install nmap
Error: Unable to locate package nmap
root@686a0e9c65ae:~# apt install clamscan
Error: Unable to locate package clamscan
root@686a0e9c65ae:~# apt install update  
Error: Unable to locate package update
root@686a0e9c65ae:~# apt list
apt/now 3.0.0 amd64 [installed,local]
base-files/now 13.6ubuntu2 amd64 [installed,local]
base-passwd/now 3.6.6 amd64 [installed,local]
bash/now 5.2.37-1.1ubuntu1 amd64 [installed,local]
bsdutils/now 1:2.40.2-14ubuntu1.1 amd64 [installed,local]
coreutils/now 9.5-1ubuntu1.25.04.1 amd64 [installed,local]
dash/now 0.5.12-12ubuntu1 amd64 [installed,local]
debconf/now 1.5.87ubuntu1 all [installed,local]
debianutils/now 5.21 amd64 [installed,local]
diffutils/now 1:3.10-3 amd64 [installed,local]
dpkg/now 1.22.18ubuntu2 amd64 [installed,local]
e2fsprogs/now 1.47.2-1ubuntu1 amd64 [installed,local]
findutils/now 4.10.0-3 amd64 [installed,local]
gcc-14-base/now 14.2.0-19ubuntu2 amd64 [installed,local]
gcc-15-base/now 15-20250404-0ubuntu1 amd64 [installed,local]
gpgv/now 2.4.4-2ubuntu23.1 amd64 [installed,local]
grep/now 3.11-4build1 amd64 [installed,local]
gzip/now 1.13-1ubuntu3 amd64 [installed,local]
hostname/now 3.25 amd64 [installed,local]
init-system-helpers/now 1.68 all [installed,local]
libacl1/now 2.3.2-2 amd64 [installed,local]
libapt-pkg7.0/now 3.0.0 amd64 [installed,local]
libassuan9/now 3.0.2-2 amd64 [installed,local]
libattr1/now 1:2.5.2-3 amd64 [installed,local]
libaudit-common/now 1:4.0.2-2ubuntu2 all [installed,local]
libaudit1/now 1:4.0.2-2ubuntu2 amd64 [installed,local]
libblkid1/now 2.40.2-14ubuntu1.1 amd64 [installed,local]
libbsd0/now 0.12.2-2 amd64 [installed,local]
libbz2-1.0/now 1.0.8-6 amd64 [installed,local]
libc-bin/now 2.41-6ubuntu1.1 amd64 [installed,local]
libc6/now 2.41-6ubuntu1.1 amd64 [installed,local]
libcap-ng0/now 0.8.5-4build1 amd64 [installed,local]
libcap2/now 1:2.73-4ubuntu1 amd64 [installed,local]
libcom-err2/now 1.47.2-1ubuntu1 amd64 [installed,local]
libcrypt1/now 1:4.4.38-1 amd64 [installed,local]
libdb5.3t64/now 5.3.28+dfsg2-9 amd64 [installed,local]
libdebconfclient0/now 0.277ubuntu1 amd64 [installed,local]
libext2fs2t64/now 1.47.2-1ubuntu1 amd64 [installed,local]
libgcc-s1/now 15-20250404-0ubuntu1 amd64 [installed,local]
libgcrypt20/now 1.11.0-6ubuntu1 amd64 [installed,local]
libgmp10/now 2:6.3.0+dfsg-3ubuntu1 amd64 [installed,local]
libgpg-error0/now 1.51-3 amd64 [installed,local]
liblz4-1/now 1.10.0-4 amd64 [installed,local]
liblzma5/now 5.6.4-1ubuntu1 amd64 [installed,local]
libmd0/now 1.1.0-2build2 amd64 [installed,local]
libmount1/now 2.40.2-14ubuntu1.1 amd64 [installed,local]
libncursesw6/now 6.5+20250216-2 amd64 [installed,local]
libnpth0t64/now 1.8-2 amd64 [installed,local]
libpam-modules-bin/now 1.5.3-7ubuntu4.3 amd64 [installed,local]
libpam-modules/now 1.5.3-7ubuntu4.3 amd64 [installed,local]
libpam-runtime/now 1.5.3-7ubuntu4.3 all [installed,local]
libpam0g/now 1.5.3-7ubuntu4.3 amd64 [installed,local]
libpcre2-8-0/now 10.45-1 amd64 [installed,local]
libproc2-0/now 2:4.0.4-7ubuntu1 amd64 [installed,local]

root@686a0e9c65ae:~# apt update
Get:1 http://archive.ubuntu.com/ubuntu plucky InRelease [265 kB]
Get:2 http://security.ubuntu.com/ubuntu plucky-security InRelease [126 kB]
Get:3 http://security.ubuntu.com/ubuntu plucky-security/universe amd64 Packages [129 kB]
Get:4 http://archive.ubuntu.com/ubuntu plucky-updates InRelease [126 kB]
Get:5 http://security.ubuntu.com/ubuntu plucky-security/restricted amd64 Packages [163 kB]
Get:6 http://security.ubuntu.com/ubuntu plucky-security/main amd64 Packages [217 kB]
Get:7 http://archive.ubuntu.com/ubuntu plucky-backports InRelease [126 kB]  
Get:8 http://security.ubuntu.com/ubuntu plucky-security/multiverse amd64 Packages [18.8 kB]
Get:9 http://archive.ubuntu.com/ubuntu plucky/main amd64 Packages [1862 kB]     
Get:10 http://archive.ubuntu.com/ubuntu plucky/restricted amd64 Packages [66.2 kB]
Get:11 http://archive.ubuntu.com/ubuntu plucky/universe amd64 Packages [20.3 MB]
Get:12 http://archive.ubuntu.com/ubuntu plucky/multiverse amd64 Packages [322 kB]
Get:13 http://archive.ubuntu.com/ubuntu plucky-updates/restricted amd64 Packages [181 kB]
Get:14 http://archive.ubuntu.com/ubuntu plucky-updates/main amd64 Packages [334 kB]
Get:15 http://archive.ubuntu.com/ubuntu plucky-updates/multiverse amd64 Packages [34.8 kB]
Get:16 http://archive.ubuntu.com/ubuntu plucky-updates/universe amd64 Packages [233 kB]
Fetched 24.5 MB in 6s (3994 kB/s)                                                                                                  
1 package can be upgraded. Run 'apt list --upgradable' to see it.
root@686a0e9c65ae:~# apt install nmap
Installing:                     
  nmap

Installing dependencies:
  adduser   dbus-daemon              ibverbs-providers  libdbus-1-3  liblinear4   libnl-route-3-200  nmap-common
  dbus      dbus-session-bus-common  libapparmor1       libexpat1    liblua5.4-0  libpcap0.8t64
  dbus-bin  dbus-system-bus-common   libblas3           libibverbs1  libnl-3-200  libssh2-1t64

Suggested packages:
  liblocale-gettext-perl  cron   ecryptfs-utils            | dbus-session-bus  liblinear-dev  ndiff
  perl                    quota  default-dbus-session-bus  liblinear-tools     ncat           zenmap

Summary:
  Upgrading: 0, Installing: 20, Removing: 0, Not Upgrading: 1
  Download size: 8446 kB
  Space needed: 34.5 MB / 7442 MB available

Continue? [Y/n] n

```

````markdown
# 🐳 Docker Notes – Fun Guide

---

## 1️⃣ Running Containers & Bash Shell

* Run container with **bash**:

```bash
docker run ubuntu:25.04 bash
docker run -t ubuntu:25.04 bash       # -t → allocate TTY
docker run -i ubuntu:25.04 bash       # -i → keep STDIN open
docker run -it ubuntu:25.04 bash      # -it → interactive shell
````

* Inside container:

```bash
mkdir a
cd a
touch 1.txt 2.txt 3.txt 3.zip 4.pkl 5.py
```

💡 Files/folders exist **only inside this container**. Exiting and running a new container → fresh filesystem.

---

## 2️⃣ Minimal Ubuntu Image

* Official Ubuntu base is **barebones**: no `nano`, `sudo`, etc.
* Install packages:

```bash
apt update
apt install nmap
apt install clamscan
```

* Why `apt install` fails initially: **package index not updated**.

---

## 3️⃣ Detached Mode & Exec

* Run container in background:

```bash
docker run -d ubuntu:25.04 sleep infinity
```

* Check running containers:

```bash
docker ps
```

* Exec into running container:

```bash
docker exec -it <CONTAINER_ID> bash
```

---

## 4️⃣ Container Storage Impact on Host 💾

* Container filesystem = **OverlayFS** on host (`/var/lib/docker/overlay2/`).
* Inside container:

```
Space needed: 34.5 MB / 7442 MB available
```

* This shows **host’s free space**, not a pre-allocated container limit.

* Writable layer grows as you add files/apps:

```bash
# Install big app
apt install <7GB-app>
# Disk space used on host increases
```

* Delete container → space freed:

```bash
docker rm <CONTAINER_ID>
```

* Persistent storage with volumes:

```bash
docker run -v /host/path:/container/path ...
```

---

## 5️⃣ Limiting Container Storage ❌

* Attempted:

```bash
docker run --storage-opt size=1G ubuntu:25.04
```

* Error:

```
--storage-opt is supported only for overlay over xfs with 'pquota' mount option
```

* Fix: configure **XFS with pquota** on Docker storage directory.
* Without limit → container can use **host’s free disk space**.

---

## 6️⃣ Container Size vs Image Size / Copy-on-Write ✨

* Images = **read-only layers** (shared across containers).

  * Example: `ubuntu:25.04` → 77 MB.

* Containers = **writable layer** on top:

```bash
# tiny changes
touch 1.txt
mkdir a
```

* Only changes/additions count → container size small (\~39 MB in `docker system df`).

* Commands to check:

```bash
docker system df
```

* Install big apps → container layer grows → host disk used.
* Volumes are separate, persistent, and do **not grow container writable layer**.

---

## 7️⃣ Key Commands Summary 🔑

```bash
# Start interactive container
docker run -it ubuntu:25.04 bash

# Run detached
docker run -d ubuntu:25.04 sleep infinity

# Exec into running container
docker exec -it <CONTAINER_ID> bash

# Check running containers
docker ps

# Check storage usage
docker system df

# Install packages inside container
apt update
apt install nmap
```

---

🎯 **Fun analogy:**

* **Image** = blueprint 🏗
* **Container** = house with furniture 🛋
* **Writable layer** = what you actually change/add inside 🖼

> Containers don’t magically store data separately — **all disk usage hits your host** unless you set quotas or use volumes.

```

This includes **all your running commands, storage notes, COW explanation, and fun emojis**.  

If you want, I can **also add a cute diagram for image vs container vs writable layer** to make it visually clear.  

Do you want me to add that?
```
---
---

### **3️⃣ List Running Containers** 📋

```bash
docker ps
```

* Shows currently running containers ⚡.
* Columns to note:

  * **CONTAINER ID** 🆔
  * **NAMES** (Docker gives random names like `plucky_puffin` if you don't specify) 🎭

---

### **4️⃣ List All Containers (Including Stopped)** 📜

```bash
docker ps -a
```

* Useful to see containers that exited but still exist on disk 💾.

---

### **5️⃣ Start & Stop Containers** ⏯️

* Start:

  ```bash
  docker start <container_id_or_name>
  ```
* Stop:

  ```bash
  docker stop <container_id_or_name>
  ```

---

### **6️⃣ Remove Containers** 🗑️

```bash
docker rm <container_id_or_name>
```

* Deletes the container (not the image) ❌.

---

### **7️⃣ Remove Images** 🗑️

```bash
docker rmi <image_id_or_name>
```

* Deletes the image from your system 💥.

---

### **8️⃣ Pull an Image** 📥

```bash
docker pull ubuntu:22.04
```

* Gets image from Docker Hub 🌐.
* If you omit the tag, defaults to `latest` 🏷️.

---

### **9️⃣ Copy Files Between Host & Container** 📁

* **From host → container:**

  ```bash
  docker cp myfile.txt container_name:/root/
  ```
* **From container → host:**

  ```bash
  docker cp container_name:/root/myfile.txt .
  ```

---

### **🔟 See Container Logs** 📄

```bash
docker logs <container_id_or_name>
```

* Useful for apps running in background 🔍.

---

💡 **Mental Model:**

* **Images** 📸 = frozen templates (your `ubuntu` image).
* **Containers** 📦 = running instances of those images (like `plucky_puffin`).
* You can have multiple containers from the same image 🔄.

---

