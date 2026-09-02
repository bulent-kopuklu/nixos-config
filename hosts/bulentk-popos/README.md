# Pop!_OS 24.04 + LUKS + btrfs — ASUS ProArt P16

Her adımda **kopyalanacak komut** var. Hiçbir yerde "şunu yap" yazmıyor,
"şu komutu çalıştır" yazıyor. Araştırman gereken hiçbir şey yok.

Her bölümde iki yol var:
- **KISA YOL** — `install.sh` ile
- **UZUN YOL** — komutları tek tek yapıştır

İkisi de aynı şeyi yapıyor. İstediğini seç, karıştırabilirsin de.

---

## 0. Bu dosyayı laptopta aç

Telefondan komut yazma. Canlı oturumda tarayıcı ve terminal var.

**0.1** Canlı USB'den boot et → **Try Demo Mode** (kurulumu başlatma).

**0.2** Wi-Fi'ye bağlan. Üst bardan yapabilirsin, ya da terminalden:

```bash
nmcli device wifi list
```

```bash
sudo nmcli device wifi connect "SSID_BURAYA" password "PAROLA_BURAYA"
```

**0.3** Bağlantıyı doğrula:

```bash
ping -c2 github.com
```

**0.4** Firefox'u aç, adres çubuğuna **elle yazacağın tek şey** bu:

```
github.com/bulent-kopuklu/nixos-config/blob/master/hosts/bulentk-popos/README.md
```

Bundan sonra her komutu buradan kopyala, terminale yapıştır.

**0.5** Script'i de istiyorsan indir:

```bash
sudo apt update && sudo apt install -y git
```

```bash
git clone https://github.com/bulent-kopuklu/nixos-config.git
cd nixos-config/hosts/bulentk-popos
```

> **Ofise gitmeden önce repoyu push et.** Push edilmemişse 0.4'teki adres 404
> verir ve gerçekten telefondan yazmak zorunda kalırsın.

Yanına al: **LUKS parolası**. Her boot'ta yazacaksın, kaybedersen disk gider.

---

## Silmeden önce — Windows hâlâ kuruluyken (10 dk)

Bunlar Windows varken kolay, silindikten sonra eziyet:

1. **Donanımı muayene et** (iade penceresi): ekranda ölü piksel, iki USB-C
   portu, klavye, kamera, hoparlör. Kusur varsa Windows'lu haliyle iade et.
2. **BIOS'u güncelle**: MyASUS → Customer Support → Live Update. Yeni modelde
   firmware düzeltmeleri Linux'ta suspend/USB4/ekran davranışını da düzeltir.
3. İstersen lisans anahtarını not al (firmware'de zaten gömülü, silinince de
   kalır — bu sadece sigorta). PowerShell'de:

   ```powershell
   (Get-WmiObject -query 'select * from SoftwareLicensingService').OA3xOriginalProductKey
   ```

BitLocker açıksa umursama — installer diski komple siliyor, çözmene gerek yok.

## 1. BIOS

Açılışta `F2` → **Secure Boot: Disabled** → kaydet, çık.

> **Canlı USB açılmıyorsa (siyah ekran / donmuş logo):** ilk şüpheli ISO'nun
> yanlış varyantı olması. İndirilen dosyanın adında `nvidia` geçmeli —
> standart ISO'da NVIDIA sürücüsü yok ve RTX 5070'te masaüstü gelmeyebilir.
> NVIDIA ISO'yla da olmuyorsa BIOS'ta GPU modunu **Hybrid**'e al.
>
> **Deneme yaparken:** installer'da disk seçiminden sonrasına TIKLAMA —
> "Clean Install" onayladığın anda diski yazmaya başlar, Windows gider.

---

## 2. Akış özeti

"Geçiş" = **installer uygulamasını çalıştırma**, reboot değil.
İki geçiş de aynı canlı oturumda.

```
Canlı USB
  ├── 3.  1. GEÇİŞ   installer: Clean Install + Encrypt   → Restart'a BASMA
  ├── 4.  Diski tespit et
  ├── 5.  2. GEÇİŞ   installer: Custom (Advanced), btrfs  → Restart'a BASMA
  ├── 6.  Subvolume'lar
  ├── 7.  Mount + chroot
  ├── 8.  Chroot içi ayarlar
  └── 9.  reboot  ← İLK VE TEK REBOOT
Diskten boot
  ├── 10. İlk açılış
  ├── 11. Snapshot + bakım
  └── 12. Nix (opsiyonel)
```

---

## 3. Birinci geçiş — installer

**Amaç:** LUKS + LVM + recovery iskeletini installer'a kurdurmak. Bu geçişin
kurduğu ext4 sistem 5. adımda silinecek, önemli değil.

1. Masaüstünden **Install Pop!_OS**
2. Dil, klavye
3. **Clean Install**
4. Diski seç — *diskteki her şey silinir, Windows dahil*
5. **Encrypt Drive** → parolayı belirle
6. Bitince ekranda **Restart Device** çıkacak

> ### ⛔ RESTART'A BASMA
> Dock'taki **Install Pop!_OS** ikonuna **sağ tık → Quit**.
> Basarsan canlı ortamı kaybedersin, baştan başlarsın.

---

## 4. Diski tespit et

### KISA YOL

```bash
./install.sh 0
```

Diski okur, LUKS'u açar, `LV=` satırını sana basar, `AYARLAR` bölümündeki
değerlerle karşılaştırır. Hepsi `OK` olana kadar dosyanın başındaki
`AYARLAR` bölümünü düzelt ve tekrar çalıştır.

### UZUN YOL

**4.1** Bölümlere bak:

```bash
lsblk -o NAME,SIZE,FSTYPE,PARTTYPENAME,LABEL
```

Beklenen (isimler kayabilir — **gördüğün geçerli**):

```
nvme0n1
├─nvme0n1p1   1G     vfat          EFI System         ← ESP
├─nvme0n1p2   4G     vfat                             ← recovery, DOKUNMA
├─nvme0n1p3  ~1.9T   crypto_LUKS                      ← LUKS
└─nvme0n1p4   4G     swap                             ← kullanmayacağız
```

**4.2** Değişkenleri ayarla. Sonraki tüm komutlar bunları kullanıyor, bir kere
doğru yaz gerisini düşünme:

```bash
export DISK=/dev/nvme0n1
export ESP=/dev/nvme0n1p1
export LUKS=/dev/nvme0n1p3
export USER_NAME=bulentk
```

**4.3** LUKS'u aç:

```bash
sudo cryptsetup open $LUKS cryptdata
```

> `Device cryptdata already exists` derse sorun yok, installer açık bırakmış.
> Devam et.

**4.4** LVM'i aktive et ve bak:

```bash
sudo vgchange -ay
sudo lvs
```

`VG=data`, `LV=root` görmelisin.

**4.5** LV yolunu ayarla ve doğrula:

```bash
export LV=/dev/mapper/data-root
ls -l $LV
```

`ls` bir cihaz gösteriyorsa tamam. Göstermiyorsa `lvs` çıktısındaki gerçek
isimleri kullan: `/dev/mapper/<vg>-<lv>`.

> **`data-root` nereden geliyor?** Pop'un şifreli kurulumu volume group'u
> `data`, logical volume'u `root` olarak adlandırıyor; LVM de her LV'ye
> `/dev/mapper/<vg>-<lv>` yolunu veriyor. Yani bu bir **varsayılan**, kural
> değil. Doğrusu her zaman 4.4'teki `lvs` çıktısıdır — orada başka bir isim
> görürsen onu kullan.
>
> Aynı cihazın `/dev/<vg>/<lv>` symlink'i de var (`/dev/data/root`). VG veya LV
> adında tire varsa `mapper` yolunda tire ikiye katlanır (`vg--adi-lv`); o
> durumda symlink hâlini kullanmak daha az kafa karıştırır.

---

## 5. İkinci geçiş — installer

**Amaç:** Aynı LV'yi bu sefer **btrfs** olarak formatlatmak.

1. Masaüstünden **Install Pop!_OS**'u tekrar aç
2. **Custom (Advanced)**
3. LUKS bölümünü (p3) seç, **parolayla aç**. `data` VG'si ve `root` LV'si
   listede ayrı cihaz olarak belirir.
4. **`data/root`** LV'si:
   - Use partition: **evet**
   - Format: **evet**
   - Filesystem: **btrfs**   ← bu adımın tek sebebi
   - Mount point: **`/`**
5. **p1 (ESP, 1 GB)**: Use evet, Mount point **`/boot/efi`**, format gerekmiyor
6. **p2 (recovery, 4 GB)**: Use evet, Mount point **`/recovery`**
   *Tutuyoruz — sistem boot etmediğinde buradan kurtaracaksın*
7. **p4 (swap)**: **HİÇBİR ŞEY ATAMA**, hepsi boş kalsın
8. Kur

> ### ⛔ YİNE RESTART'A BASMA
> Yine dock ikonuna **sağ tık → Quit**.

**5.1** Kök gerçekten btrfs mi:

```bash
lsblk -f | grep -i btrfs
```

Bir satır görmelisin. Görmüyorsan filesystem seçimi tutmamış, 5'i tekrar yap.

---

## 6. Subvolume'lar

> Terminali kapattıysan 4.2 ve 4.5'teki `export` satırlarını tekrar çalıştır.

### KISA YOL

```bash
./install.sh 3
```

### UZUN YOL

**6.1** Top-level'ı mount et:

```bash
sudo mount -o subvolid=5 $LV /mnt
cd /mnt
```

**6.2** `@` oluştur, kurulu sistemin tamamını içine taşı:

```bash
sudo btrfs subvolume create @
sudo find . -maxdepth 1 -mindepth 1 ! -name '@' -exec mv -t @ {} +
```

**6.3** Diğerleri:

```bash
sudo btrfs subvolume create @home
sudo btrfs subvolume create @ml
sudo btrfs subvolume create @nix
sudo btrfs subvolume create @var-log
sudo btrfs subvolume create @docker
sudo btrfs subvolume create @libvirt
sudo btrfs subvolume create @swap
```

**6.4** `nodatacow` — subvolume **boşken** set edilmeli, sonra olmuyor:

```bash
sudo chattr +C @docker @libvirt @swap
```

**6.5** Logları taşı:

```bash
sudo find @/var/log -mindepth 1 -maxdepth 1 -exec mv -t @var-log/ {} +
```

**6.6** Kontrol:

```bash
sudo btrfs subvolume list /mnt
sudo ls /mnt/@
```

- **8 subvolume**: `@ @home @ml @nix @var-log @docker @libvirt @swap`
- `@` içinde **dolu sistem**: `bin boot etc home lib usr var ...`

`@` boşsa **DUR**, devam edersen boş sisteme kurulum yaparsın.

**6.7** Çöz:

```bash
cd /
sudo umount /mnt
```

---

## 7. Mount + chroot

### KISA YOL

```bash
./install.sh 4
```

Mount eder, script'i `/mnt/root/install.sh`'e kopyalar, chroot'a bırakır.

### UZUN YOL

**7.1** Mount opsiyonları:

```bash
export COW="noatime,compress=zstd:1,ssd,discard=async,space_cache=v2"
export NOCOW="noatime,nodatacow,ssd,discard=async,space_cache=v2"
```

**7.2** Sırayla mount et — **sıra önemli**, `@home` bağlanmadan altına bir şey
bağlayamazsın:

```bash
sudo mount -o $COW,subvol=@ $LV /mnt
```

```bash
sudo mkdir -p /mnt/home /mnt/nix /mnt/var/log /mnt/var/lib/docker \
              /mnt/var/lib/libvirt/images /mnt/swap /mnt/boot/efi
```

```bash
sudo mount -o $COW,subvol=@home     $LV /mnt/home
sudo mkdir -p /mnt/home/$USER_NAME/ml
sudo mount -o $COW,subvol=@ml       $LV /mnt/home/$USER_NAME/ml
sudo mount -o $COW,subvol=@nix      $LV /mnt/nix
sudo mount -o $COW,subvol=@var-log  $LV /mnt/var/log
sudo mount -o $NOCOW,subvol=@docker  $LV /mnt/var/lib/docker
sudo mount -o $NOCOW,subvol=@libvirt $LV /mnt/var/lib/libvirt/images
sudo mount -o $NOCOW,subvol=@swap    $LV /mnt/swap
sudo mount $ESP /mnt/boot/efi
```

**7.3** Home sahipliği — **10. adımdaki sihirbazda aynı kullanıcı adını
vereceksin**, yoksa UID tutmaz:

```bash
sudo chown 1000:1000 /mnt/home/$USER_NAME /mnt/home/$USER_NAME/ml
```

**7.4** Kontrol — 9 satır görmelisin (8 subvolume + ESP):

```bash
findmnt -R /mnt
```

**7.5** Script'i chroot'a kopyala (KISA YOL'u 8'de kullanacaksan şart,
uzun yolda da işine yarayabilir):

```bash
sudo cp ~/nixos-config/hosts/bulentk-popos/install.sh /mnt/root/
```

> Repoyu klonlamadıysan (0.5'i atladıysan) bu dosya yok — sorun değil,
> 8'de UZUN YOL'u kullan.

**7.6** Chroot:

```bash
for i in /dev /dev/pts /proc /sys /run; do
  sudo mount -B $i /mnt$i
  sudo mount --make-slave /mnt$i
done
sudo chroot /mnt
```

> `--make-slave` şart: yoksa 9. adımdaki `umount`, canlı sistemin kendi
> `/dev/pts`'ini de söker ve sudo "unable to allocate pty" demeye başlar.

Prompt değişti mi? İçerdesin.

---

## 8. Chroot içinde

### KISA YOL

```bash
/root/install.sh 5
```

### UZUN YOL

**8.1** Değişkenler chroot'a geçmez, tekrar tanımla:

```bash
export LV=/dev/mapper/data-root
export USER_NAME=bulentk
export COW="noatime,compress=zstd:1,ssd,discard=async,space_cache=v2"
export NOCOW="noatime,nodatacow,ssd,discard=async,space_cache=v2"
export FSUUID=$(blkid -s UUID -o value $LV)
echo $FSUUID
```

`echo` boş dönerse **DUR** — `$LV` yanlış.

**8.2** fstab — installer'ın `/` ve swap satırlarını yorumla:

```bash
cp /etc/fstab /etc/fstab.bak
awk '(($2=="/") || ($3=="swap")) && $0 !~ /^#/ {print "#"$0; next} {print}' \
    /etc/fstab.bak > /etc/fstab
```

**8.3** Kendi satırlarımızı ekle (tek blok, olduğu gibi yapıştır):

```bash
cat >> /etc/fstab <<EOF

# btrfs subvolumes
UUID=$FSUUID  /                        btrfs  defaults,$COW,subvol=@         0 0
UUID=$FSUUID  /home                    btrfs  defaults,$COW,subvol=@home     0 0
UUID=$FSUUID  /home/$USER_NAME/ml      btrfs  defaults,$COW,subvol=@ml       0 0
UUID=$FSUUID  /nix                     btrfs  defaults,$COW,subvol=@nix      0 0
UUID=$FSUUID  /var/log                 btrfs  defaults,$COW,subvol=@var-log  0 0
UUID=$FSUUID  /var/lib/docker          btrfs  defaults,$NOCOW,subvol=@docker  0 0
UUID=$FSUUID  /var/lib/libvirt/images  btrfs  defaults,$NOCOW,subvol=@libvirt 0 0
UUID=$FSUUID  /swap                    btrfs  defaults,$NOCOW,subvol=@swap    0 0
/swap/swapfile  none  swap  defaults  0 0
EOF
```

**8.4** Kontrol — eski `/` satırı `#` ile başlamalı, altta bizim 9 satır:

```bash
cat /etc/fstab
```

**8.5** crypttab — şifreli swap eşlemesini sil, TRIM iznini ekle:

```bash
cat /etc/crypttab
sed -i '/swap/d' /etc/crypttab
sed -i 's/luks$/luks,discard/' /etc/crypttab
cat /etc/crypttab
```

Sonuç şuna benzemeli:

```
cryptdata UUID=xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx none luks,discard
```

`,discard` eklenmemişse elle yaz:

```bash
nano /etc/crypttab
```

**8.6** LVM'in de TRIM'i geçirmesi için:

```bash
sed -i 's/^\([[:space:]]*\)issue_discards = 0/\1issue_discards = 1/' /etc/lvm/lvm.conf
grep issue_discards /etc/lvm/lvm.conf
```

**8.7** Kernel parametresi — **bu atlanırsa sistem boot etmez**:

```bash
kernelstub -a "rootflags=subvol=@"
```

**8.8** Swap dosyası. Önce `btrfs` komutu chroot'ta var mı diye bak, yoksa kur:

```bash
command -v btrfs >/dev/null || apt install -y btrfs-progs
```

```bash
btrfs filesystem mkswapfile --size 32g --uuid clear /swap/swapfile
ls -lh /swap/swapfile
```

**8.9** initramfs + bootloader:

```bash
update-initramfs -c -k all
kernelstub
```

**8.10** Loader entry'yi doğrula:

```bash
grep rootflags /boot/efi/loader/entries/Pop_OS-current.conf
```

Çıktı **gelmezse** elle ekle:

```bash
sed -i 's/splash/splash rootflags=subvol=@/' /boot/efi/loader/entries/Pop_OS-current.conf
cat /boot/efi/loader/entries/Pop_OS-current.conf
```

`rootflags=subvol=@` görünene kadar devam etme.

---

## 9. Reboot

```bash
exit
```

```bash
sudo umount -R /mnt
sudo reboot
```

> `umount` "target is busy" derse: `sudo umount -lR /mnt` — sonra reboot.
>
> Sonrasında sudo "unable to allocate pty" derse: kurulum sağlam, bozulan
> sadece canlı oturum. Sırayla dene: `sync` → `systemctl reboot` (sudo'suz) →
> GUI güç menüsü → olmadı güç tuşuna 10 sn bas (disk unmount edilmiş
> durumda, güvenli).

**USB'yi çıkar.** İlk ve tek reboot buydu.

---

## 10. İlk açılış

1. LUKS parolası sorulacak
2. Pop sihirbazı: **kullanıcı adı `bulentk`** (7.3'te bu isme `chown` yaptık)
3. Masaüstü

Kontrol:

```bash
findmnt -t btrfs
sudo btrfs subvolume list /
swapon --show
```

8 mount, 8 subvolume, `/swap/swapfile` 32G görmelisin.

> Home dizinin kurulumdan önce var olduğu için (7.3'teki `chown`) sihirbaz
> `/etc/skel` dosyalarını kopyalamamış olabilir. Terminal ayarların bozuk
> görünüyorsa:
>
> ```bash
> cp /etc/skel/.bashrc /etc/skel/.profile ~/
> ```

---

## 11. Snapshot + bakım

> Kurulu sistemde repo henüz yok (canlı oturumdaki klon RAM'deydi).
> KISA YOL için önce:
>
> ```bash
> sudo apt update && sudo apt install -y git
> git clone https://github.com/bulent-kopuklu/nixos-config.git
> cd nixos-config/hosts/bulentk-popos
> ```

### KISA YOL

```bash
./install.sh 6
```

### UZUN YOL

**11.1** TRIM zamanlayıcısı:

```bash
sudo systemctl enable --now fstrim.timer
```

**11.2** Paketler:

```bash
sudo apt update
sudo apt install -y timeshift btrfsmaintenance git
```

**11.3** Timeshift'i ayarla. En kolayı GUI (`timeshift-gtk`):

- Snapshot Type: **BTRFS**
- Include `@home`: **evet**
- Monthly **2**, Boot **5**
- Hourly / Daily / Weekly: **kapalı**

Terminalden yapmak istersen:

```bash
sudo timeshift --btrfs --create --comments "clean install"
sudo timeshift --list
```

Zamanlama ayarları `/etc/timeshift/timeshift.json` içinde:

```bash
sudo nano /etc/timeshift/timeshift.json
```

Şu değerleri ayarla:

```
"btrfs_mode" : "true",
"include_btrfs_home" : "true",            <- surume gore adi "include_btrfs_home_for_backup" olabilir; hangisi varsa onu true yap
"schedule_monthly" : "true",   "count_monthly" : "2",
"schedule_boot" : "true",      "count_boot" : "5",
"schedule_weekly" : "false",
"schedule_daily" : "false",
"schedule_hourly" : "false",
```

Doğrula:

```bash
sudo timeshift --list
```

**11.4** apt öncesi otomatik snapshot — asıl koruma bu:

```bash
git clone https://github.com/wmutschl/timeshift-autosnap-apt.git
cd timeshift-autosnap-apt
sudo make install
cd ..
```

```bash
sudo sed -i 's/^updateGrub=.*/updateGrub=false/' /etc/timeshift-autosnap-apt.conf
grep updateGrub /etc/timeshift-autosnap-apt.conf
```

> `updateGrub=false` **şart** — Pop'ta GRUB yok, systemd-boot var. `true`
> kalırsa her `apt` çağrısında hata basar.

Test et:

```bash
sudo apt install -y tree
sudo timeshift --list
```

Yeni bir snapshot görmelisin.

**11.5** btrfs bakımı:

```bash
sudo sed -i 's|^BTRFS_BALANCE_PERIOD=.*|BTRFS_BALANCE_PERIOD="monthly"|'         /etc/default/btrfsmaintenance
sudo sed -i 's|^BTRFS_BALANCE_MOUNTPOINTS=.*|BTRFS_BALANCE_MOUNTPOINTS="/"|'     /etc/default/btrfsmaintenance
sudo sed -i 's|^BTRFS_SCRUB_PERIOD=.*|BTRFS_SCRUB_PERIOD="monthly"|'             /etc/default/btrfsmaintenance
sudo sed -i 's|^BTRFS_SCRUB_MOUNTPOINTS=.*|BTRFS_SCRUB_MOUNTPOINTS="/"|'         /etc/default/btrfsmaintenance
sudo systemctl restart btrfsmaintenance-refresh.service
```

**11.6** TRIM gerçekten geçiyor mu — hiçbir katmanda `0` olmamalı:

```bash
lsblk -D
```

**11.7** Gerçek doluluk (`df` yalan söyler):

```bash
sudo btrfs filesystem usage /
```

---

## 12. Nix (opsiyonel)

Sadece dev toolchain. **GPU'ya dokunan hiçbir şeyi Nix'ten kurma** — CUDA,
torch, GL kullanan uygulamalar apt veya container.

### KISA YOL

```bash
./install.sh 7
```

### UZUN YOL

```bash
sh <(curl -L https://nixos.org/nix/install) --daemon
```

Yeni terminal aç (ya da aynı terminalde
`. /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh`), sonra:

```bash
echo "experimental-features = nix-command flakes" | sudo tee -a /etc/nix/nix.conf
sudo systemctl restart nix-daemon
```

```bash
nix profile install nixpkgs#direnv nixpkgs#nix-direnv
```

`.envrc` içinde `use flake`, `~/.config/direnv/direnvrc` içinde:

```bash
mkdir -p ~/.config/direnv
echo 'source $HOME/.nix-profile/share/nix-direnv/direnvrc' >> ~/.config/direnv/direnvrc
```

home-manager kullanacaksan `home.nix` içinde **şart**:

```nix
targets.genericLinux.enable = true;
```

Store şişmesin (ayda bir):

```bash
nix-collect-garbage --delete-older-than 30d
nix store optimise
```

---

## Bu makinenin bilinen sorunu: Panel Replay donması (ÇÖZÜLDÜ)

**Belirti:** boot sırasında veya login ekranında donma — görüntü kalır, klavye/
mouse ölür; bazen `amdgpudrmfb` satırında siyah ekran. HX 370 (Strix Point)
platformunun bilinen amdgpu hatası: panelin **Panel Replay** güç tasarrufu
özelliği sürücüyü kilitliyor.

**Çözüm** (kuruludur; format sonrası ilk iş geri yaz):

```bash
sudo kernelstub -a "amdgpu.dcdebugmask=0x400"
```

Boot edemiyorsan: systemd-boot menüsü (açılışta **Space** basılı) → `e` →
satır sonuna `amdgpu.dcdebugmask=0x400` → Enter; girince yukarıdaki komutla
kalıcılaştır.

Notlar:
- `0x12` (eski PSR biti) bu platformda İŞE YARAMAZ — Panel Replay ayrı bit.
- `nomodeset` semptomu maskeler, çözmez; kalıcı kullanma (GPU hızlandırmayı
  tamamen kapatır).
- İleride bir kernel bunu kökten düzeltirse: `sudo kernelstub -d
  "amdgpu.dcdebugmask=0x400"` ile kaldır, parametresiz reboot ile test et.
- Grafik açılmadığında tty kaçış kapısı: `e` → satıra
  `systemd.unit=multi-user.target` ekle → metin login'den gir.

## Sistem boot etmezse

Boot menüsünde **Pop!_OS Recovery**'yi seç, ya da USB'den boot et. Sonra:

```bash
sudo cryptsetup open /dev/nvme0n1p3 cryptdata
sudo vgchange -ay
sudo mount -o subvol=@ /dev/mapper/data-root /mnt
sudo mount /dev/nvme0n1p1 /mnt/boot/efi
for i in /dev /dev/pts /proc /sys /run; do sudo mount -B $i /mnt$i; done
sudo chroot /mnt
```

İçeride en olası iki sorun:

```bash
grep rootflags /boot/efi/loader/entries/Pop_OS-current.conf
kernelstub -a "rootflags=subvol=@"
kernelstub
```

```bash
update-initramfs -u -k all
```

Çık:

```bash
exit
sudo umount -R /mnt
sudo reboot
```

---

## Snapshot'tan geri dönme

```bash
sudo cryptsetup open /dev/nvme0n1p3 cryptdata
sudo vgchange -ay
sudo mount -o subvolid=5 /dev/mapper/data-root /mnt
cd /mnt
```

Snapshot'ları listele:

```bash
ls timeshift-btrfs/snapshots/
```

Birini seç ve geri al (tarihi kendin yaz):

```bash
sudo mv @ @.bozuk
sudo btrfs subvolume snapshot timeshift-btrfs/snapshots/2026-09-15_10-00-00/@ @
```

Kernel güncellemesini kapsayan bir rollback yaptıysan ESP'yi de senkronla,
yoksa boot etmez:

```bash
cd /
sudo umount /mnt
sudo mount -o subvol=@ /dev/mapper/data-root /mnt
sudo mount /dev/nvme0n1p1 /mnt/boot/efi
for i in /dev /dev/pts /proc /sys /run; do sudo mount -B $i /mnt$i; done
sudo chroot /mnt
update-initramfs -u -k all && kernelstub
exit
sudo umount -R /mnt
sudo reboot
```

---

## Neden böyle — kısa gerekçeler

**İki geçiş:** Pop installer btrfs'e format edebiliyor ama subvolume
oluşturmuyor. Ayrıca Custom modda sıfırdan LUKS+LVM kurmak kırılgan ve
recovery partition düzgün oluşmuyor.

**Subvolume'lar**

| Subvolume | Mount | Neden ayrı |
|---|---|---|
| `@` | `/` | Timeshift bunu snapshot'lar |
| `@home` | `/home` | Timeshift bunu da snapshot'lar |
| `@ml` | `~/ml` | modeller; unutulmuş snapshot 80 GB pinlemesin |
| `@nix` | `/nix` | store 50–100 GB; GC yer boşaltabilsin |
| `@var-log` | `/var/log` | rollback sonrası "ne bozuldu" okunabilsin |
| `@docker` | `/var/lib/docker` | nodatacow |
| `@libvirt` | `/var/lib/libvirt/images` | nodatacow |
| `@swap` | `/swap` | swapfile snapshot'lanan subvolume'de duramaz |

`/var`'ın tamamı ayrılmadı — `/var/lib/dpkg` snapshot dışında kalırsa rollback
tutarsız olur.

**`nodatacow` neden subvolume gerektiriyor:** NOCOW bir dosya snapshot'lanan
subvolume'deyse garantisini kaybeder; snapshot sonrası her bloğa ilk yazma
yine CoW'lanır. `chattr +C` tek başına yetmez.

**crypttab `discard`:** TRIM'in dm-crypt katmanından geçmesine izin verir.
Olmadan `fstrim` ve `discard=async` sessizce çalışmaz. Karşılığı: trim'lenmiş
bloklar sıfır okunduğu için diski imajlayan biri ne kadarının dolu olduğunu
görebilir; dosya içeriği/isimleri sızmaz. Çalınan laptop senaryosunda önemsiz.

**Hibernate kapalı.** 64 GB RAM'de swapfile de 64 GB olurdu ve model yüklüyken
50 GB'ı diske yazıp okumak suspend-to-RAM'den kötü. İstersen 8.8'de `--size 64g`
yap ve şunu ekle:

```bash
kernelstub -a "resume=UUID=$FSUUID resume_offset=$(btrfs inspect-internal map-swapfile -r /swap/swapfile)"
```

**Harici ekranlar USB-C'den.** Bu modelde HDMI doğrudan NVIDIA dGPU'ya bağlı
ve Linux'ta sorunlu. Sol USB-C iGPU'ya bağlı, DP alt-mode oradan. İki USB-C
portunu ayrı ayrı test et, sağdakinin nereye gittiği belirsiz.

**GPU modu.** Varsayılan hybrid/offload zaten istediğin şey: ekranlar AMD'den,
CUDA NVIDIA'da, oyunlar `prime-run` ile. NixOS'ta bataryayı bitiren
`prime.sync.enable = true` idi; burada öyle bir ayar yapma.
