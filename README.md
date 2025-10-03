# pri-routeros-scr
(Private Script base on eworm-de projects)

# pri-routeros-scr

Kumpulan **RouterOS Scripts** untuk monitoring jaringan via **Telegram**.

## 📂 Struktur
- `global-config-overlay/environment.rsc` → konfigurasi global (token, chatid, secret, dll.)
- `mods/` → modul-modul fungsi
- `installers/` → script auto-install modul tertentu
- `README.md` → panduan


## 🚀 Instalasi Cepat
1. Edit `environment.rsc` isi token/chatid.
2. Upload ke router:  
3. Router otomatis pasang script login/logout ke semua Hotspot Profile.
4. Tes dengan login user hotspot → notifikasi muncul di Telegram.





## PENTING:
Siapkan bot Telegram (sekali saja)


# Buka Telegram → cari @BotFather → tekan Start.

# Kirim /newbot → ikuti instruksi beri nama dan username bot.

# BotFather akan kasih Token (contoh: 123456789:ABCDEF...). Simpan token ini.

# Tentukan chat tujuan:

Kalau grup: buat grup, tambahkan bot sebagai anggota, lalu kirim pesan apa saja di grup itu.

Kalau private (ke diri sendiri): chat langsung bot-mu dan kirim pesan apa saja.

Dapatkan chat_id dengan cara paling mudah:

Buka browser di HP/PC, tempelkan URL ini (ganti <TOKEN>):

#https://api.telegram.org/bot<TOKEN>/getUpdates#


Setelah tadi kamu kirim pesan, di hasil JSON akan terlihat chat":{"id": ... }.

Kalau grup, biasanya bentuknya minus besar, misal: -1002910530545.

Kalau private, angka positif (misal 123456789).

Catat chat_id itu.

# Catatan: untuk grup super, chat_id mulai dengan -100.... Itu normal.


