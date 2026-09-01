#!/usr/bin/env bash
# Pop!_OS 24.04 (COSMIC) + LUKS + LVM + btrfs subvolume kurulumu.
#
# Bu dosya bastan sona calistirilmak icin DEGIL, bolum bolum okunup
# calistirilmak icin. Adim 1 ve 2 grafik installer'da elle yapiliyor.
#
# Pop installer (distinst) sifreli kurulumda LUKS -> LVM -> tek LV dayatiyor
# ve btrfs'e format edebilse de subvolume olusturmuyor. Bu yuzden iki gecisli
# kurulum + chroot gerekiyor.

set -euo pipefail

################################################################################
# AYARLAR - kurulumdan once lsblk ile dogrula
################################################################################

DISK=/dev/nvme0n1
ESP=${DISK}p1              # installer'in olusturdugu EFI partition
LUKS_PART=${DISK}p3        # LUKS konteyneri
LV=/dev/mapper/data-root   # LUKS icindeki LVM logical volume

USERNAME=bulentk
UID_GID=1000:1000

# RAM 64 GB. Hibernate kapali oldugu icin swap sadece OOM sigortasi; 32 GB
# fazlasiyla yeter (e14 ile de tutarli). Hibernate isteseydin SWAP_GB=64
# yapman gerekirdi - ve model yuklu haldeyken 50+ GB RAM'i diske yazip geri
# okumak pratikte suspend-to-RAM'den cok daha kotu bir deneyim.
SWAP_GB=32
HIBERNATE=no               # yes: swapfile + resume_offset kernelstub'a eklenir

OPTS_COW="noatime,compress=zstd:1,ssd,discard=async,space_cache=v2"
OPTS_NOCOW="noatime,nodatacow,ssd,discard=async,space_cache=v2"

# subvolume:mountpoint
#
# Sadelestirildi. Snapshot politikasi seyrek (aylik + upgrade oncesi + otomatik
# boot/apt) oldugu icin @home-cache, @var-cache, @flatpak, @workspace ayirmalarinin
# teknik gerekcesi kalmadi - kisa omurlu snapshot onlari pinlemiyor.
# Kalanlarin her birinin bagimsiz gerekcesi var:
#   @ml       diskin buyuk kismi burada; unutulmus bir snapshot 80 GB pinlemesin
#   @nix      store 50-100 GB; snapshot'lanirsa nix-collect-garbage yer bosaltmaz
#   @var-log  rollback sonrasi "ne bozuldu" diye loglara bakabilmek icin
#   @docker   nodatacow; docker'in kendi katmanlari snapshot'ta felaket
#   @libvirt  sadece imajlar (/var/lib/libvirt/images); VM XML tanimlari
#             /etc/libvirt'te yani @ icinde kalir, rollback tutarli gider
#   @swap     swapfile snapshot'lanan subvolume'de duramaz (zorunlu)
#
# nodatacow NEDEN ayri subvolume gerektiriyor: btrfs'te NOCOW bir dosya
# snapshot'lanan bir subvolume'deyse garantisini kaybediyor - snapshot
# sonrasi her bloga ilk yazma yine CoW'lanir ("CoW once"). chattr +C tek
# basina yetmez, dosyanin snapshot disinda olmasi gerekir.
SUBVOLS=(
  "@:/"
  "@home:/home"
  "@ml:/home/${USERNAME}/ml"
  "@nix:/nix"
  "@var-log:/var/log"
  "@docker:/var/lib/docker"
  "@libvirt:/var/lib/libvirt/images"
  "@swap:/swap"
)

NOCOW_SUBVOLS="@docker @libvirt @swap"

################################################################################
# ADIM 1 - Installer, birinci gecis (GUI, elle)
################################################################################
#
# NVIDIA ISO ile boot et.
#   - "Clean Install" + "Encrypt Drive"
#   - Amac: LUKS + LVM iskeletini ve recovery partition'i installer'a kurdurmak.
#   - Kurulum bitince REBOOT ETME, installer'i kapat.
#
# lsblk -f ile su yapiyi dogrula ve yukaridaki degiskenleri duzelt:
#   nvme0n1p1  vfat   ESP
#   nvme0n1p2  vfat   recovery      <- SILME. btrfs rollback'te kurtarma ortamin.
#   nvme0n1p3  crypto_LUKS          -> VG "data" -> LV "root"

################################################################################
# ADIM 2 - Installer, ikinci gecis (GUI, elle)
################################################################################
#
# Installer'i tekrar baslat, "Custom (Advanced)":
#   - LUKS'u ac, data/root LV'sini sec
#   - format = btrfs, mount = /
#   - p1 -> /boot/efi , p2 -> /recovery
#   - Installer'in kurdugu swap partition'a HICBIR SEY atama (mount/format yok).
#     Swap'i @swap icindeki btrfs swapfile'dan aliyoruz; sifreli swap partition
#     her boot'ta rastgele anahtar aldigi icin hibernate'i imkansiz kiliyor.
#     Istersen o partition'i tamamen silip yeri bos birakabilirsin.
#   - Kur. Bitince yine REBOOT ETME.

################################################################################
# ADIM 3 - Subvolume'lari olustur
################################################################################

step3_subvolumes() {
  sudo cryptsetup status cryptdata >/dev/null 2>&1 || \
    sudo cryptsetup open "$LUKS_PART" cryptdata
  sudo vgchange -ay data

  sudo mount "$LV" /mnt
  cd /mnt

  sudo btrfs subvolume create @
  # kurulmus sistemin tamamini @ icine tasi
  sudo find . -maxdepth 1 -mindepth 1 ! -name '@' -exec mv -t @ {} +

  for entry in "${SUBVOLS[@]}"; do
    sv=${entry%%:*}
    [ "$sv" = "@" ] && continue
    sudo btrfs subvolume create "$sv"
  done

  # nodatacow, subvolume bosken set edilmeli
  sudo chattr +C $NOCOW_SUBVOLS

  # mevcut icerigi ilgili subvolume'lere tasi (bos olanlar sorun degil)
  sudo mv @/var/log/. @var-log/ 2>/dev/null || true

  cd /
  sudo umount /mnt
}

################################################################################
# ADIM 4 - Mount + chroot
################################################################################

mount_all() {
  local target=$1
  for entry in "${SUBVOLS[@]}"; do
    local sv=${entry%%:*} mp=${entry#*:}
    local opts=$OPTS_COW
    [[ " $NOCOW_SUBVOLS " == *" $sv "* ]] && opts=$OPTS_NOCOW
    sudo mkdir -p "${target}${mp}"
    sudo mount -o "${opts},subvol=${sv}" "$LV" "${target}${mp}"
  done

  sudo mkdir -p "${target}/boot/efi"
  sudo mount "$ESP" "${target}/boot/efi"
  for d in dev proc sys run; do sudo mount --rbind "/$d" "${target}/$d"; done
}

step4_chroot() {
  mount_all /mnt
  # home altindaki mount noktalari ilk boot'tan once dogru sahiplikte olmali;
  # first-boot sihirbazinda AYNI kullanici adini vermelisin.
  sudo chown "$UID_GID" "/mnt/home/${USERNAME}" "/mnt/home/${USERNAME}/ml"
  sudo chroot /mnt /bin/bash
}

################################################################################
# ADIM 5 - CHROOT ICINDE calistir
################################################################################

step5_in_chroot() {
  local fsuuid
  fsuuid=$(blkid -s UUID -o value "$LV")

  cp /etc/fstab /etc/fstab.bak
  # installer'in yazdigi / satirini ve swap partition satirini yorumla
  awk '(($2=="/") || ($3=="swap")) && $0 !~ /^#/ {print "#"$0; next} {print}' \
    /etc/fstab.bak > /etc/fstab

  # sifreli swap partition eslemesini kaldir - swap artik @swap/swapfile
  sed -i '/swap/d' /etc/crypttab

  {
    echo ""
    echo "# btrfs subvolumes"
    for entry in "${SUBVOLS[@]}"; do
      local sv=${entry%%:*} mp=${entry#*:}
      local opts=$OPTS_COW
      [[ " $NOCOW_SUBVOLS " == *" $sv "* ]] && opts=$OPTS_NOCOW
      printf 'UUID=%s  %s  btrfs  defaults,%s,subvol=%s  0 0\n' \
        "$fsuuid" "$mp" "$opts" "$sv"
    done
  } >> /etc/fstab

  # TRIM: Pop guvenlik gerekcesiyle discard koymuyor. fstrim'in LUKS'tan
  # gecebilmesi icin gerekli. Istemiyorsan bu satiri atla.
  sed -i 's/\(^cryptdata\s\+\S\+\s\+\S\+\s\+\)\(.*\)/\1\2,discard/' /etc/crypttab
  grep -q discard /etc/crypttab || echo "UYARI: crypttab'a discard eklenemedi, elle bak"

  # BU SATIR OLMAZSA SISTEM BOOT ETMEZ
  kernelstub -a "rootflags=subvol=@"

  # swap
  mkdir -p /swap
  btrfs filesystem mkswapfile --size "${SWAP_GB}g" --uuid clear /swap/swapfile
  echo "/swap/swapfile  none  swap  defaults  0 0" >> /etc/fstab

  if [ "$HIBERNATE" = "yes" ]; then
    local off
    off=$(btrfs inspect-internal map-swapfile -r /swap/swapfile)
    kernelstub -a "resume=UUID=${fsuuid} resume_offset=${off}"
  fi

  update-initramfs -c -k all
  kernelstub

  echo "--- dogrula: asagida rootflags=subvol=@ gorunmeli ---"
  cat /boot/efi/loader/entries/Pop_OS-current.conf
  cat /etc/fstab
}

################################################################################
# ADIM 6 - Ilk boot sonrasi
################################################################################

step6_post_install() {
  sudo apt install -y timeshift btrfs-progs
  sudo systemctl enable --now fstrim.timer

  # Timeshift: btrfs modu, @ ve @home dahil.
  # GUI'den: Snapshot Type = BTRFS, Include @home = yes
  #   Monthly 2 / Boot 5 / Hourly-Daily-Weekly KAPALI

  # apt oncesi otomatik snapshot. Planli upgrade'i zaten sen dusunuyorsun;
  # bu, "yanlislikla dependency'leri de sildim" senaryosuna karsi olan tek koruma.
  # PPA yok, GitHub'dan kuruluyor:
  git clone https://github.com/wmutschl/timeshift-autosnap-apt.git /tmp/tsa
  ( cd /tmp/tsa && sudo make install )
  # /etc/timeshift-autosnap-apt.conf icinde MUTLAKA:
  #   updateGrub=false     <- Pop systemd-boot/kernelstub kullaniyor, GRUB yok
  #   maxSnapshots=3
  sudo sed -i 's/^updateGrub=.*/updateGrub=false/' /etc/timeshift-autosnap-apt.conf
  grep updateGrub /etc/timeshift-autosnap-apt.conf
  # apt oncesi otomatik snapshot icin timeshift-autosnap-apt kur.
  #
  # ML isini container'da yap; @docker snapshot disinda, host temiz kalir:
  #   sudo apt install -y docker.io nvidia-container-toolkit

  # btrfs bakimi - ext4/XFS'te olmayan, btrfs'te gereken kisim.
  # Diski %85'in ustunde surekli dolu tutma; btrfs df bos gosterirken
  # metadata tukenmesi yuzunden ENOSPC verebiliyor.
  sudo apt install -y btrfsmaintenance
  # /etc/default/btrfsmaintenance icinde:
  #   BTRFS_BALANCE_PERIOD="monthly"
  #   BTRFS_BALANCE_MOUNTPOINTS="/"
  #   BTRFS_SCRUB_PERIOD="monthly"
  #   BTRFS_SCRUB_MOUNTPOINTS="/"
  # Elle karsiligi:
  #   btrfs balance start -dusage=50 -musage=50 /
  #   btrfs scrub start /
  #   btrfs filesystem usage /        <- gercek doluluk, df degil
}

################################################################################
# ADIM 7 - Nix (opsiyonel, dev toolchain icin)
################################################################################
#
# SINIR: Nix'i CLI/dev toolchain icin kullan. GPU'ya dokunan hicbir seyi
# Nix'ten kurma (CUDA, torch, GL kullanan GUI uygulamalari) - Nix'in mesa'si
# host'un NVIDIA surucusuyle eslesmez. Onlar apt veya container.

step7_nix() {
  # /nix zaten ayri subvolume, snapshot disinda.
  sh <(curl -L https://nixos.org/nix/install) --daemon
  # alternatif: Determinate Systems installer'i temiz uninstall veriyor
  #   curl -sSf -L https://install.determinate.systems/nix | sh -s -- install

  sudo mkdir -p /etc/nix
  echo "experimental-features = nix-command flakes" | \
    sudo tee -a /etc/nix/nix.conf

  # devshell akisi
  nix profile install nixpkgs#direnv nixpkgs#nix-direnv

  # home-manager (standalone, flake):
  #   home.nix icinde MUTLAKA:
  #       targets.genericLinux.enable = true;
  #   yoksa XDG_DATA_DIRS ayarlanmaz, uygulamalar COSMIC launcher'da gorunmez.
  #   nix run home-manager/master -- switch --flake .#${USERNAME}

  # duzenli GC - store arastirma makinesinde hizli sisiyor
  #   nix-collect-garbage --delete-older-than 30d
  #   nix store optimise
}

################################################################################
# ROLLBACK TUZAGI
################################################################################
#
# ESP snapshot'a dahil DEGIL. Kernel guncellemesini kapsayan bir rollback
# yaparsan ESP'de yeni vmlinuz kalir, modulleri @'de yoktur -> boot etmez.
# Restore sonrasi recovery'den chroot'layip:
#   update-initramfs -u -k all && kernelstub
#
# Nix kurduysan: /nix snapshot disinda, kendi icinde tutarli kalir. Ama @'yi
# Nix kurulumundan ONCEYE geri alirsan /etc/nix, nix-daemon unit'i ve nixbld
# kullanicilari kaybolur (store durur). Duzeltmesi: installer'i tekrar calistir.
#
# Elle rollback (recovery ortamindan, top-level mount ile):
#   mv @ @.broken
#   btrfs subvolume snapshot timeshift-btrfs/snapshots/<tarih>/@ @

case "${1:-}" in
  3|subvolumes)  step3_subvolumes ;;
  4|chroot)      step4_chroot ;;
  5|in-chroot)   step5_in_chroot ;;
  6|post)        step6_post_install ;;
  7|nix)         step7_nix ;;
  *) echo "kullanim: $0 {3|4|5|6|7}  -- once dosyayi oku, adim 1-2 GUI'de elle" ;;
esac
