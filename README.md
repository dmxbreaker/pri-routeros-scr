# pri-routeros-scr

[![RouterOS v7+](https://img.shields.io/badge/RouterOS-v7+-blue.svg)]()
[![Telegram Bot Ready](https://img.shields.io/badge/Telegram-Bot%20Ready-29a1d4.svg?logo=telegram)]()
[![License MIT](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)

Kumpulan **RouterOS Scripts** untuk monitoring & kontrol router via **Telegram**.  
Struktur repo dibuat sederhana agar mudah dipakai user awam maupun sysadmin.

---

## 📂 Struktur Repo

- **global-config-overlay/**
  - `environment.rsc`
- **mods/**
  - `mod_user_eventlog.rsc`
  - `mod_tg_poller.rsc`
  - `mod_health_check.rsc`
  - `mod_log_forwarder.rsc`
  - `mod_restart_via_telegram.rsc`
- **installers/**
  - `install-certificates.rsc`
  - `install-user-eventlog.rsc`
  - `install-health-check.rsc`
  - `install-log-forwarder.rsc`
  - `install-tg-poller.rsc`
  - `install-all.rsc`
- `README.md`

---

## 🚀 Instalasi Step by Step

### 1️⃣ Persiapan
- Pastikan router sudah bisa akses internet.  
- Buka **Winbox / WebFig / SSH terminal**.

---

### 2️⃣ Install Root Certificates (sekali saja)

1. Fetch script installer:
```rsc
/tool fetch url="https://raw.githubusercontent.com/dmxbreaker/pri-routeros-scr/main/installers/install-certificates.rsc" dst-path=install-certificates.rsc
```

2. Import ke RouterOS:
```rsc
/import file-name=install-certificates.rsc
```

Jika sukses, log akan muncul:
```text
[install-certificates] Import certificate selesai. Router siap fetch via HTTPS.
```

---

### 3️⃣ Install Semua Modul + Installer

1. Fetch script installer:
```rsc
/tool fetch url="https://raw.githubusercontent.com/dmxbreaker/pri-routeros-scr/main/installers/install-all.rsc" dst-path=install-all.rsc
```

2. Import ke RouterOS:
```rsc
/import file-name=install-all.rsc
```

`install-all.rsc` akan:
- mengunduh & import `environment.rsc`  
- mengunduh & import semua `mods/`  
- mengunduh & import semua `installers/`  
- membuat scheduler & hook otomatis  

---

### 4️⃣ Konfigurasi Bot Telegram

Edit script **environment** di RouterOS:

```rsc
:global TG_TOKEN_MON "123456789:ABCDEF-your-bot-token";
:global TG_CHATID_MON "-1001234567890";
:global TG_TRUSTED_CHATIDS { "-1001234567890"; }
:global RESTART_SECRET "mySecret123";
```

⚠️ Jangan bagikan token bot Telegram ke siapa pun.

---

### 5️⃣ Uji Coba

- **Hotspot login/logout** → notifikasi muncul di Telegram.  
- **Health check** → tiap 10 menit, jika ada masalah (low memory, suhu CPU tinggi) → Telegram alert.  
- **Log forwarder** → tiap 30 menit kirim potongan log.  
- **Telegram poller** → pesan masuk dari bot akan dicatat di log RouterOS.  

---

## 📲 Modul yang Tersedia

| Modul                        | Fungsi                                                                 |
|-------------------------------|------------------------------------------------------------------------|
| `mod_user_eventlog`           | Notifikasi login/logout user Hotspot → Telegram + simpan file          |
| `mod_tg_poller`               | Poll update Telegram (versi minimal, logging pesan)                   |
| `mod_health_check`            | Monitor memori, suhu CPU, uptime → alert Telegram                     |
| `mod_log_forwarder`           | Forward log RouterOS ke Telegram secara berkala                       |
| `mod_restart_via_telegram`    | Restart router dengan secret lewat Telegram                           |

---

## ⚠️ Troubleshooting

- **HTTPS fetch gagal / SSL error**  
  Pastikan sudah import certificate (step 2).  

  Tes koneksi dari PC/Laptop:
```shell
curl -I https://raw.githubusercontent.com/dmxbreaker/pri-routeros-scr/main/README.md
```

atau:
```shell
wget --spider https://raw.githubusercontent.com/dmxbreaker/pri-routeros-scr/main/README.md
```

- **Tidak ada pesan Telegram**  
  Cek token/chat id di `environment.rsc`, lalu cek log:
```rsc
/log print where message~"Telegram"
```

- **Hotspot hook tidak jalan**  
  Pastikan `install-user-eventlog.rsc` sudah di-import.  

---

## 🔐 Keamanan

- Gunakan `TG_TRUSTED_CHATIDS` untuk membatasi akses bot.  
- Gunakan `RESTART_SECRET` yang kuat & unik.  
- Uji coba di router lab sebelum dipasang di produksi.  

---

## 🧹 Uninstall (opsional)

```rsc
/system scheduler remove [find where name="HealthCheck"]
/system scheduler remove [find where name="LogForward"]
/system scheduler remove [find where name="TG-Poller"]

/system script remove [find where name~"mod_"]
/system script remove [find where name="environment"]
```

---

Author : dmxbreaker (https://github.com/dmxbreaker)  
License : MIT
