#!/usr/bin/env bash
# Pop!_OS 24.04 (COSMIC) + LUKS + LVM + btrfs subvolume kurulumu.
#
# Bu dosya bastan sona calistirilmak icin DEGIL, bolum bolum okunup
# calistirilmak icin. Adim 1 ve 2 grafik installer'da elle yapiliyor.
#
# Pop installer (distinst) sifreli kurulumda LUKS -> LVM -> tek LV dayatiyor
# ve btrfs'e format edebilse de subvolume olusturmuyor. Bu yuzden iki gecisli
# kurulum + chroot gerekiyor.
#
################################################################################
# AKIS OZETI - "gecis" REBOOT DEGIL, installer uygulamasini calistirma sayisi.
# Iki gecis de AYNI canli USB oturumunda olur. Aralarinda reboot YOK.
################################################################################
#
#  USB'den boot, canli masaustu
#    |
#    +-- [1. GECIS] "Install Pop!_OS" uygulamasi: Clean Install + Encrypt
#    |      bitince "Restart Device" cikar -> TIKLAMA, pencereyi kapat
#    |
#    +-- terminal:  ./install.sh 0          diski tespit et, AYARLAR'i dogrula
#    |
#    +-- [2. GECIS] AYNI uygulamayi tekrar ac: Custom (Advanced), LV -> btrfs
#    |      bitince yine "Restart Device" -> TIKLAMA, pencereyi kapat
#    |
#    +-- terminal:  ./install.sh 3          subvolume'lar
#    +-- terminal:  ./install.sh 4          mount + chroot'a gir
#    +-- chroot:    /root/install.sh 5      fstab/kernelstub/initramfs/swap
#    +-- chroot:    exit
#    +-- terminal:  sudo umount -R /mnt && sudo reboot
#           |
#           `---> ILK VE TEK REBOOT. USB'yi cikar.
#
#  Diskten boot
#    |
#    +-- LUKS parolasi -> Pop first-boot sihirbazi (kullaniciyi burada olustur,
#    |   AYNI kullanici adiyla: $USERNAME)
#    +-- terminal:  ./install.sh 6          timeshift + apt-hook + bakim + trim
#    +-- terminal:  ./install.sh 7          nix (opsiyonel)
#
################################################################################

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
# AMAC: Kendimiz kurmak yerine installer'a LUKS konteynerini, LVM'i ve recovery
# partition'i kurdurmak. Bu gecisin urunu olan ext4 sistemi ikinci gecis zaten
# silecek - burada onemli olan tek sey partition/LVM iskeleti.
#
# ISO: system76.com'dan Pop!_OS 24.04 LTS *NVIDIA* ISO'su. (Intel/AMD ISO'sunu
#      indirirsen NVIDIA surucusu gelmez, sonradan kurmak Pop'un olayini bozar.)
#
# 1. USB'den boot et, "Try or Install".
# 2. Dil / klavye.
# 3. Installation type: "Clean Install".
# 4. Hedef diski sec. DIKKAT: diskteki her sey silinir.
# 5. Sifreleme ekraninda "Encrypt Drive"i sec ve parolayi belirle.
#      - Bu LUKS parolasi. Her boot'ta bunu yazacaksin.
#      - Kaybedersen disk gider; kurtarma yok.
# 6. Kurulum bitince ekran "Restart Device" diyecek. *** REBOOT ETME. ***
#      Kapatma sekli: dock'taki "Install Pop!_OS" ikonuna SAG TIK -> Quit.
#      Canli masaustunde kal.
#
# 7. Terminal ac, yapiyi not al:
#      lsblk -f
#
#    Beklenen (isimler makineye gore kayabilir - GORDUGUN neyse o gecerli):
#      nvme0n1p1  vfat         ESP        -> dosyanin basindaki ESP
#      nvme0n1p2  vfat         recovery   -> SILME, rollback'te kurtarma ortamin
#      nvme0n1p3  crypto_LUKS             -> dosyanin basindaki LUKS_PART
#                   `- cryptdata (LVM PV)
#                        `- VG "data" / LV "root"  -> dosyanin basindaki LV
#      nvme0n1p4  swap                    -> ADIM 2'de kullanilmayacak
#
#    Bu dort degeri (DISK / ESP / LUKS_PART / LV) dosyanin basindaki AYARLAR
#    bolumune yaz. Scriptin geri kalani tamamen bunlara bagli.

################################################################################
# ADIM 2 - Installer, ikinci gecis (GUI, elle)
################################################################################
#
# AMAC: Ayni logical volume'u bu sefer btrfs olarak formatlatmak. Installer
# btrfs'e format edebiliyor ama subvolume olusturmuyor; onu ADIM 3'te biz
# yapacagiz.
#
# 1. Canli masaustunden installer'i tekrar baslat ("Install Pop!_OS").
# 2. Installation type: "Custom (Advanced)".
# 3. Partition ekraninda LUKS partition'ini (p3) sec ve ADIM 1'de belirledigin
#    parolayla ac. Acilinca VG "data" ve icindeki LV "root" ayri bir cihaz
#    olarak listede belirir.
# 4. LV "root" (data/root):
#      Use partition : evet
#      Format        : evet
#      Filesystem    : btrfs        <- bu adimin tek sebebi bu
#      Mount point   : /
# 5. p1 (ESP):
#      Use partition : evet
#      Mount point   : /boot/efi
#      Format        : gerekmiyor (ADIM 1'de zaten olusturuldu)
# 6. p2 (recovery):
#      Use partition : evet
#      Mount point   : /recovery
#      Not: Bu partition'i tutuyoruz. btrfs rollback'i gerektiginde ya da
#      sistem boot etmedigi zaman chroot'lamak icin buradan boot edeceksin.
#      Silersen her seferinde USB aramak zorunda kalirsin.
# 7. p4 (swap): HICBIR SEY ATAMA. Use/format/mount hepsi bos kalsin.
#      Neden: swap'i @swap subvolume'undeki btrfs swapfile'dan aliyoruz.
#      Installer'in sifreli swap partition'i her boot'ta rastgele anahtar
#      aliyor - hem gereksiz, hem hibernate'i imkansiz kiliyor.
#      Istersen bu partition'i tamamen silip yeri bos birakabilirsin.
# 8. Kur. Bitince yine *** REBOOT ETME ***, dock ikonuna sag tik -> Quit.
#
# 9. Kontrol - / gercekten btrfs mi:
#      lsblk -f | grep -i btrfs
#
# Bundan sonrasi ADIM 3, artik script calisiyor:
#      ./install.sh 3

################################################################################
# ADIM 0 - Diskteki yapiyi tespit et  ->  ./install.sh 0
################################################################################
#
# ADIM 1'den sonra calistir. DISK / ESP / LUKS_PART / LV degerlerini bulur.
# LUKS kapaliysa LVM gorunmez; bu adim onu da acar.

step0_inspect() {
  echo "=== Sistemdeki diskler ==="
  lsblk -dno NAME,SIZE,MODEL | sed 's|^|  /dev/|'
  echo
  echo "AYARLAR'daki DISK=$DISK"
  [ -b "$DISK" ] || { echo "HATA: $DISK diye bir blok cihaz yok. DISK'i duzelt."; return 1; }

  echo
  echo "=== $DISK uzerindeki bolumler ==="
  lsblk -o NAME,SIZE,FSTYPE,PARTTYPENAME,LABEL,MOUNTPOINT "$DISK"

  # Diskten oku. AYARLAR'daki degerlere GUVENME - dogrulanacak olan onlar.
  local d_luks d_esp
  d_luks=$(lsblk -rno NAME,FSTYPE "$DISK" | awk '$2=="crypto_LUKS"{print "/dev/"$1}')
  d_esp=$(lsblk -rno NAME,PARTTYPE "$DISK" \
          | awk '$2=="c12a7328-f81f-11d2-ba4b-00a0c93ec93b"{print "/dev/"$1}')

  echo
  echo "=== Diskte bulunanlar ==="
  printf '  ESP        : %s\n' "${d_esp:-BULUNAMADI}"
  printf '  LUKS_PART  : %s\n' "${d_luks:-BULUNAMADI}"

  [ -n "$d_luks" ] || {
    echo "HATA: crypto_LUKS bolumu yok. ADIM 1'de 'Encrypt Drive' sectin mi?"
    return 1
  }

  # LUKS'u TESPIT EDILEN bolumden ac, AYARLAR'dakinden degil.
  local holder
  holder=$(ls "/sys/class/block/$(basename "$d_luks")/holders" 2>/dev/null | head -1)
  if [ -z "$holder" ]; then
    echo
    echo ">>> LUKS kapali, aciliyor (ADIM 1'de belirledigin parola):"
    sudo cryptsetup open "$d_luks" cryptdata
    holder=cryptdata
  fi
  echo "  LUKS mapper: /dev/mapper/${holder}"
  sudo vgchange -ay >/dev/null 2>&1 || true

  echo
  echo "=== LVM ==="
  sudo lvs -o vg_name,lv_name,lv_size

  echo
  echo "=== AYARLAR bolumune yazilacak degerler ==="
  echo "DISK=$DISK"
  echo "ESP=${d_esp}"
  echo "LUKS_PART=${d_luks}"
  sudo lvs --noheadings -o vg_name,lv_name 2>/dev/null | while read -r vg lv; do
    echo "LV=/dev/mapper/${vg}-${lv}"
  done

  echo
  echo "=== Senin ayarlarinla karsilastirma ==="
  [ "$ESP" = "$d_esp" ] \
    && echo "  ESP        OK" \
    || echo "  ESP        FARKLI -> ayar=$ESP  disk=$d_esp"
  [ "$LUKS_PART" = "$d_luks" ] \
    && echo "  LUKS_PART  OK" \
    || echo "  LUKS_PART  FARKLI -> ayar=$LUKS_PART  disk=$d_luks"
  [ -b "$LV" ] \
    && echo "  LV         OK" \
    || echo "  LV         YOK/FARKLI -> ayar=$LV (yukaridaki LV= satirini kullan)"

  echo
  echo "Hepsi OK degilse AYARLAR bolumunu duzelt ve bu adimi tekrar calistir."
}

################################################################################
# ADIM 3 - Subvolume'lari olustur
################################################################################

step3_subvolumes() {
  # LUKS zaten acik olabilir (installer birakmis olabilir); ismi ondan al,
  # yeni isim uydurup "device already in use" hatasi alma.
  if [ -z "$(ls "/sys/class/block/$(basename "$LUKS_PART")/holders" 2>/dev/null)" ]; then
    sudo cryptsetup open "$LUKS_PART" cryptdata
  fi
  sudo vgchange -ay
  [ -b "$LV" ] || { echo "HATA: $LV yok. once ./install.sh 0 calistir."; exit 1; }

  # subvolid=5 = top-level. Acikca belirt; default subvol degisirse yanlis
  # yere yazmayasin.
  sudo mount -o subvolid=5 "$LV" /mnt
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
  # 'mv dir/. dst/' calismiyor (Device or resource busy) - find ile tasi.
  # Gizli dosyalar dahil.
  if [ -d @/var/log ] && [ -n "$(sudo ls -A @/var/log 2>/dev/null)" ]; then
    sudo find @/var/log -mindepth 1 -maxdepth 1 -exec mv -t @var-log/ {} +
  fi

  echo
  echo "=== dogrulama ==="
  sudo btrfs subvolume list /mnt
  echo
  echo "--- @ icinde sistem olmali (bin, etc, usr, var gorunsun) ---"
  sudo ls /mnt/@
  echo
  echo "Yukarida 8 subvolume ve @ icinde dolu bir sistem goruyorsan:  ./install.sh 4"

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

  # scripti chroot'un icine kopyala, yoksa adim 5'i calistiramazsin
  sudo cp "$(realpath "$0")" /mnt/root/install.sh
  echo "chroot'a giriliyor. icerde:  /root/install.sh 5"
  sudo chroot /mnt /bin/bash
}

################################################################################
# ADIM 5 - CHROOT ICINDE calistir
################################################################################

step5_in_chroot() {
  # mkswapfile icin gerekli; Pop'un btrfs kurulumunda genelde var ama garanti degil
  command -v btrfs >/dev/null || apt install -y btrfs-progs

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

  # LVM katmani da TRIM'i gecirsin (crypttab'daki discard tek basina yetmiyor)
  sed -i 's/^\([[:space:]]*\)issue_discards = 0/\1issue_discards = 1/' /etc/lvm/lvm.conf

  update-initramfs -c -k all
  kernelstub

  # kernelstub loader entry'yi her zaman yeniden yazmiyor. Yazmadiysa elle ekle,
  # yine olmazsa DUR - bu satir olmadan sistem boot etmez.
  local conf=/boot/efi/loader/entries/Pop_OS-current.conf
  grep -q 'rootflags=subvol=@' "$conf" || \
    sed -i 's/splash/splash rootflags=subvol=@/' "$conf"
  grep -q 'rootflags=subvol=@' "$conf" || {
    echo "HATA: $conf icine rootflags=subvol=@ eklenemedi. Elle ekle, yoksa boot etmez."
    exit 1
  }

  echo "--- dogrulama ---"
  cat "$conf"
  cat /etc/fstab
  cat /etc/crypttab
}

################################################################################
# ADIM 6 - Ilk boot sonrasi
################################################################################

step6_post_install() {
  sudo apt update
  sudo apt install -y git timeshift btrfs-progs btrfsmaintenance
  sudo systemctl enable --now fstrim.timer

  # Timeshift: btrfs modu, @ ve @home dahil.
  # GUI'den: Snapshot Type = BTRFS, Include @home = yes
  #   Monthly 2 / Boot 5 / Hourly-Daily-Weekly KAPALI

  # apt oncesi otomatik snapshot. Planli upgrade'i zaten sen dusunuyorsun;
  # bu, "yanlislikla dependency'leri de sildim" senaryosuna karsi olan tek koruma.
  # PPA yok, GitHub'dan kuruluyor:
  rm -rf /tmp/tsa
  git clone https://github.com/wmutschl/timeshift-autosnap-apt.git /tmp/tsa
  ( cd /tmp/tsa && sudo make install )
  # updateGrub=false SART - Pop systemd-boot/kernelstub kullaniyor, GRUB yok;
  # true kalirsa her apt cagrisinda hata basar. (maxSnapshots varsayilani 3.)
  sudo sed -i 's/^updateGrub=.*/updateGrub=false/' /etc/timeshift-autosnap-apt.conf
  grep updateGrub /etc/timeshift-autosnap-apt.conf

  # btrfs bakimi - ext4/XFS'te olmayan, btrfs'te gereken kisim.
  # Diski %85'in ustunde surekli dolu tutma; btrfs df bos gosterirken
  # metadata tukenmesi yuzunden ENOSPC verebiliyor.
  sudo sed -i 's|^BTRFS_BALANCE_PERIOD=.*|BTRFS_BALANCE_PERIOD="monthly"|'     /etc/default/btrfsmaintenance
  sudo sed -i 's|^BTRFS_BALANCE_MOUNTPOINTS=.*|BTRFS_BALANCE_MOUNTPOINTS="/"|' /etc/default/btrfsmaintenance
  sudo sed -i 's|^BTRFS_SCRUB_PERIOD=.*|BTRFS_SCRUB_PERIOD="monthly"|'         /etc/default/btrfsmaintenance
  sudo sed -i 's|^BTRFS_SCRUB_MOUNTPOINTS=.*|BTRFS_SCRUB_MOUNTPOINTS="/"|'     /etc/default/btrfsmaintenance
  sudo systemctl restart btrfsmaintenance-refresh.service

  # Elle bakim/kontrol:
  #   btrfs filesystem usage /        <- gercek doluluk, df degil
  #
  # ML isini container'da yap; @docker snapshot disinda, host temiz kalir:
  #   sudo apt install -y docker.io nvidia-container-toolkit
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
  sudo systemctl restart nix-daemon

  # installer PATH'i ancak YENI shell'de gunceller; bu oturum icin elle yukle
  set +u
  . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
  set -u

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
  0|check)       step0_inspect ;;
  3|subvolumes)  step3_subvolumes ;;
  4|chroot)      step4_chroot ;;
  5|in-chroot)   step5_in_chroot ;;
  6|post)        step6_post_install ;;
  7|nix)         step7_nix ;;
  *) cat <<'USAGE'
kullanim: ./install.sh <adim>

  (adim 1-2 grafik installer'da elle - dosyanin basindaki notlari oku)

  CANLI USB'DE (script sudo'yu kendi cagiriyor, root olman gerekmiyor):
    ./install.sh 0        diski incele, LV/ESP/LUKS_PART degerlerini soyle
    ./install.sh 3        subvolume'lari olustur
    ./install.sh 4        mount et + chroot'a gir
                          (script /root/install.sh olarak iceri kopyalanir)

  CHROOT ICINDE:
    /root/install.sh 5    fstab/crypttab/kernelstub/swap + initramfs
    exit; umount -R /mnt; reboot

  KURULU SISTEMDE (ilk boot sonrasi, normal kullanici):
    ./install.sh 6        timeshift + apt-hook + btrfs bakimi + trim
    ./install.sh 7        nix (opsiyonel, dev toolchain icin)

ONCE: lsblk -f ile DISK / ESP / LUKS_PART / LV degiskenlerini dogrula.
USAGE
     ;;
esac
