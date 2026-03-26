
sudo cryptsetup luksFormat --type luks2 --align-payload=8192 -s 256 -c aes-xts-plain64 /dev/disk/by-partlabel/crypthml
sudo cryptsetup open /dev/disk/by-partlabel/crypthml hammal

# BTRFS Dosya Sistemi
sudo mkfs.btrfs --label hammal /dev/mapper/hammal

sudo mkdir /mnt/hammal
sudo mount LABEL=hammal /mnt/hammal

sudo btrfs subvolume create /mnt/hammal/@home
sudo btrfs subvolume create /mnt/hammal/@var

sudo umount -R /mnt/nixos

sudo mount -t btrfs -o subvol=@home,rw,noatime,compress=zstd:1,ssd,discard=async,space_cache=v2,autodefrag LABEL=hammal /mnt/hammal/home
sudo mount -t btrfs -o subvol=@var,rw,noatime,compress=zstd:1,ssd,discard=async,space_cache=v2,autodefrag LABEL=hammal /mnt/hammal/var

mkdir bulentk
cd bulentk
mkdir temp
mkdir Android
mkdir -p .config/.android
mkdir .ollama
mkdir 'VirtualBox VMs'

sudo chattr +C temp
sudo chattr +C Android
sudo chattr +C .config/.android
sudo chattr +C .ollama
sudo chattr +C 'VirtualBox VMs'
sudo chattr +C '.var/app'


sudo rsync -avPHAX --info=progress2 \
  --exclude='workspace/' \
  /home/bulentk/ /mnt/hammal/home/bulentk/



sudo umount /mnt/hammal

sudo mkdir -p /mnt/system
sudo mount -o subvolid=5 /dev/mapper/system /mnt/system
sudo btrfs subvolume create /@workspace

sudo umount /mnt/system


mkdir -p /mnt/system/workspace
sudo mount -t btrfs -o subvol=@workspace,rw,noatime,compress=zstd:1,ssd,discard=async,space_cache=v2,autodefrag LABEL=system /mnt/system/workspace

sudo rsync -aPHAX --info=progress2 \
  --exclude='temp/' \
  /home/bulentk/workspace/ /mnt/system/workspace/

sudo rsync -aPHAX --info=progress2 \
  /home/bulentk/workspace/temp/ /mnt/hammal/home/bulentk/temp

cd /mnt/hammal/var
sudo mkdir -p lib/docker
sudo mkdir -p lib/libvirt

sudo mkdir -p log

sudo chattr +C lib/docker
sudo chattr +C lib/libvirt
sudo chattr +C log


# Docker ve bağlı her şeyi durdur
sudo systemctl stop docker docker.socket containerd

# Log yazımını minimize et (Opsiyonel ama temiz olur)
sudo systemctl stop systemd-journald.socket systemd-journald

sudo rsync -aPHAX --info=progress2 \
  /var/ /mnt/hammal/var/

