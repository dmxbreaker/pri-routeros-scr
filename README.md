# PRI RouterOS Scripts — 

base on https://github.com/eworm-de/routeros-scripts

Koleksi skrip RouterOS untuk pemantauan dan otomasi via Telegram—**tanpa mengubah fungsi asli**, namun telah diperkeras (hardened) agar lebih aman & robust.

**Fitur hardening utama:**
- Panggilan Telegram memakai **POST** (`application/x-www-form-urlencoded`), bukan query string.
- Helper **terpusat** di `environment.rsc`:
  - `tgSendMessage` (POST Telegram)
  - `isTrustedChat` (validasi `chat_id`)
  - `f_urlencode` (aman untuk konten pesan)
- Validasi **trusted chat_id** untuk aksi sensitif (`mod_restart_via_telegram`).
- `TG_LAST_UPDATE_ID` **diupdate** oleh poller (`mod_tg_poller`), mencegah baca ulang pesan lama.
- `LOG_FORWARD_LINES` **dipatuhi** oleh log forwarder.
- Penanganan error dan logging lebih jelas di installer.

> Teruji pada **MikroTik hAP ax2** dengan **RouterOS v7.20**.

---

## Struktur Repositori (ringkas)

```
global-config-overlay/
  └─ environment.rsc
installers/
  ├─ install-all.rsc
  ├─ install-certificates.rsc
  ├─ install-health-check.rsc
  ├─ install-log-forwarder.rsc
  ├─ install-tg-poller.rsc
  └─ install-user-eventlog.rsc
mods/
  ├─ mod_health_check.rsc
  ├─ mod_log_forwarder.rsc
  ├─ mod_restart_via_telegram.rsc
  ├─ mod_tg_poller.rsc
  └─ mod_user_eventlog.rsc
tools/
  └─ self-test.rsc
```

---

## Konfigurasi Wajib (`environment.rsc`)

> Ubah nilai sesuai lingkungan Anda sebelum mengimpor.

```routeros
:global TG_TOKEN_MON         "YOUR_TELEGRAM_BOT_TOKEN"
:global TG_CHATID_MON        "123456789"
:global TG_TRUSTED_CHATIDS   "123456789,987654321"  ;# koma, tanpa spasi

:global RESTART_SECRET       "change-me-LongerRandom123!@#"

:global LOG_FORWARD_LINES    200
:global TG_LAST_UPDATE_ID    0

:global HEALTH_FREE_MEM_WARN_BYTES  209715200   ;# ~200 MB
:global HEALTH_TEMP_WARN_C          80
:global HEALTH_UPTIME_WARN_SEC      604800      ;# 7 hari

# ========= Helper Umum =========
:global f_urlencode do={ :local s $1; :local out "";
  :for i from=0 to=([:len $s]-1) do={
    :local ch [:pick $s $i]
    :local o [:tonum [:pick $s $i]]
    :if ( ( $o>=48 && $o<=57 ) || ( $o>=65 && $o<=90 ) || ( $o>=97 && $o<=122 ) || ($ch="-") || ($ch="_") || ($ch=".") || ($ch="~") ) do={
      :set out ($out.$ch)
    } else={
      :set out ($out."%".[:pick "0123456789ABCDEF" (($o/16)%16)].[:pick "0123456789ABCDEF" ($o%16)])
    }
  }
  :return $out
}

:global tgSendMessage do={
  :local chatId ($1); :local text ($2)
  :global TG_TOKEN_MON; :global f_urlencode
  :local url ("https://api.telegram.org/bot".$TG_TOKEN_MON."/sendMessage")
  :local body ("chat_id=".[ $f_urlencode $chatId ]."&text=".[ $f_urlencode $text ])
  /tool fetch url=$url http-method=post http-data=$body \
    http-header-field="Content-Type: application/x-www-form-urlencoded" \
    output=none keep-result=no as-value
}

:global isTrustedChat do={
  :local chatId ($1); :global TG_TRUSTED_CHATIDS
  :if ([:len $TG_TRUSTED_CHATIDS]=0) do={ :return true }
  :foreach a in=[:toarray [:pick ($TG_TRUSTED_CHATIDS.",") 0 [:len ($TG_TRUSTED_CHATIDS.",")]]] do={
    :if (("$a"="$chatId")) do={ :return true }
  }
  :return false
}
```

---

## Instalasi Cepat

**Metode 1: Import otomatis (disarankan):**
```routeros
/import file-name=global-config-overlay/environment.rsc
/import file-name=installers/install-all.rsc
```

**Metode 2: Import manual (env → mods → installers):**
```routeros
/import file-name=global-config-overlay/environment.rsc

/import file-name=mods/mod_health_check.rsc
/import file-name=mods/mod_log_forwarder.rsc
/import file-name=mods/mod_tg_poller.rsc
/import file-name=mods/mod_user_eventlog.rsc
/import file-name=mods/mod_restart_via_telegram.rsc

/import file-name=installers/install-certificates.rsc
/import file-name=installers/install-user-eventlog.rsc
/import file-name=installers/install-health-check.rsc
/import file-name=installers/install-log-forwarder.rsc
/import file-name=installers/install-tg-poller.rsc
```

**Opsional: Self-test**
```routeros
/import file-name=tools/self-test.rsc
```

---

## Cuplikan Skrip (siap copas)

### `installers/install-certificates.rsc`
```routeros
:do {
  :log info "CERT: mengunduh ISRG Root X1/X2"
  /tool fetch url="https://letsencrypt.org/certs/isrgrootx1.pem" mode=https dst-path="isrgrootx1.pem" keep-result=yes
  /tool fetch url="https://letsencrypt.org/certs/isrgrootx2.pem" mode=https dst-path="isrgrootx2.pem" keep-result=yes

  :if ([:len [/file find name="isrgrootx1.pem"]]=0) do={ :error "CERT: isrgrootx1.pem tidak ditemukan" }
  :if ([:len [/file find name="isrgrootx2.pem"]]=0) do={ :error "CERT: isrgrootx2.pem tidak ditemukan" }

  :log info "CERT: impor ke /certificate"
  /certificate import file-name="isrgrootx1.pem" passphrase=""
  /certificate import file-name="isrgrootx2.pem" passphrase=""

  :log info "CERT: selesai"
} on-error={ :log warning ("CERT: gagal - " . $"message") }
```

### `installers/install-all.rsc`
```routeros
:local baseURL "https://raw.githubusercontent.com/dmxbreaker/pri-routeros-scr/main"

:do {
  :log info "INSTALL: fetch environment"
  /tool fetch url="$baseURL/global-config-overlay/environment.rsc" dst-path="environment.rsc" mode=https keep-result=yes
  /import file-name="environment.rsc"

  :log info "INSTALL: fetch installers"
  :foreach f in={"install-certificates.rsc";"install-user-eventlog.rsc";"install-health-check.rsc";"install-log-forwarder.rsc";"install-tg-poller.rsc"} do={
    /tool fetch url="$baseURL/installers/$f" dst-path=$f mode=https keep-result=yes
  }

  :log info "INSTALL: fetch mods"
  :foreach f in={"mod_user_eventlog.rsc";"mod_health_check.rsc";"mod_log_forwarder.rsc";"mod_tg_poller.rsc";"mod_restart_via_telegram.rsc"} do={
    /tool fetch url="$baseURL/mods/$f" dst-path=$f mode=https keep-result=yes
  }

  :log info "INSTALL: import mods"
  :foreach f in={"mod_user_eventlog.rsc";"mod_health_check.rsc";"mod_log_forwarder.rsc";"mod_tg_poller.rsc";"mod_restart_via_telegram.rsc"} do={
    :if ([:len [/file find name=$f]]>0) do={ /import file-name=$f } else={ :log warning ("INSTALL: file hilang: " . $f) }
  }

  :log info "INSTALL: import installers"
  :foreach f in={"install-certificates.rsc";"install-user-eventlog.rsc";"install-health-check.rsc";"install-log-forwarder.rsc";"install-tg-poller.rsc"} do={
    :if ([:len [/file find name=$f]]>0) do={ /import file-name=$f } else={ :log warning ("INSTALL: file hilang: " . $f) }
  }

  :log info "INSTALL: selesai"
} on-error={ :log warning ("INSTALL: gagal - " . $"message") }
```

### `installers/install-user-eventlog.rsc`
```routeros
:if ([:len [/system script find name="User-Event-Hook"]]>0) do={ /system script remove "User-Event-Hook" }

/system script add name="User-Event-Hook" policy=ftp,read,write,policy,test,password,sensitive source={
  :global TG_CHATID_MON; :global tgSendMessage
  :local evt $"event"; :local user [$"user"]; :local addr [$"address"]; :local mac [$"mac-address"]; :local hs [$"hotspot"]
  :local msg ("[Hotspot] " . $evt . "\nUser: " . $user . "\nIP: " . $addr . "\nMAC: " . $mac . "\nProfile: " . $hs)
  $tgSendMessage $TG_CHATID_MON $msg

  :local LOGFILE "user-events.log"
  :local cur ""
  :if ([:len [/file find name=$LOGFILE]]>0) do={ :set cur [/file get $LOGFILE contents] } else={ /file add name=$LOGFILE contents="" }
  /file set $LOGFILE contents=($cur.$msg."\r\n")
}

/ip hotspot profile
:foreach i in=[find] do={
  set $i on-login="/system script run User-Event-Hook event=login user=\$user address=\$address mac-address=\$mac hot-spot=\$hotspot"
  set $i on-logout="/system script run User-Event-Hook event=logout user=\$user address=\$address mac-address=\$mac hot-spot=\$hotspot"
}
:log info "INSTALL-UE: hook terpasang"
```

### `installers/install-health-check.rsc`
```routeros
:if ([:len [/system script find name="mod_health_check"]]=0) do={ :error "mod_health_check belum diimport" }
/system scheduler remove [find name="sch_mod_health_check"]
/system scheduler add name="sch_mod_health_check" on-event="/system script run mod_health_check" \
  policy=read,write,test,sensitive start-time=startup interval=10m
:log info "INSTALL-HC: scheduler aktif"
```

### `installers/install-log-forwarder.rsc`
```routeros
:if ([:len [/system script find name="mod_log_forwarder"]]=0) do={ :error "mod_log_forwarder belum diimport" }
/system scheduler remove [find name="sch_mod_log_forwarder"]
/system scheduler add name="sch_mod_log_forwarder" on-event="/system script run mod_log_forwarder" \
  policy=read,write,test,sensitive start-time=startup interval=30m
:log info "INSTALL-LF: scheduler aktif"
```

### `installers/install-tg-poller.rsc`
```routeros
:if ([:len [/system script find name="mod_tg_poller"]]=0) do={ :error "mod_tg_poller belum diimport" }
/system scheduler remove [find name="sch_mod_tg_poller"]
/system scheduler add name="sch_mod_tg_poller" on-event="/system script run mod_tg_poller" \
  policy=read,write,test,sensitive start-time=startup interval=10s
:log info "INSTALL-POLLER: scheduler aktif"
```

### `mods/mod_tg_poller.rsc`
```routeros
:global TG_TOKEN_MON; :global TG_LAST_UPDATE_ID; :global isTrustedChat

:local url ("https://api.telegram.org/bot".$TG_TOKEN_MON."/getUpdates")
:local body ("timeout=0&offset=" . ($TG_LAST_UPDATE_ID + 1))
:local R [/tool fetch url=$url http-method=post http-data=$body http-header-field="Content-Type: application/x-www-form-urlencoded" \
  as-value output=user keep-result=no]
:local data ($R->"data")

:local pos 0
:while ( ( :typeof $data = "str") && (($pos := [:find $data "\"update_id\":" $pos]) != nil) ) do={
  :local uidStart ($pos + 12)
  :local uidEnd   [:find $data "," $uidStart]
  :local updId [:tonum [:pick $data $uidStart $uidEnd]]

  :local chatPos [:find $data "\"chat\":{\"id\":" $pos]
  :if ($chatPos = nil) do={ :set pos ($pos + 12); :log warning "POLLER: chat_id tidak ditemukan"; :continue }
  :local cidStart ($chatPos + 12)
  :local cidEnd [:find $data "," $cidStart]
  :local chatId [:pick $data $cidStart $cidEnd]

  :local tPos [:find $data "\"text\":\"" $pos]
  :local text ""
  :if ($tPos != nil) do={
    :local tStart ($tPos + 8)
    :local tEnd [:find $data "\"" $tStart]
    :if ($tEnd != nil) do={ :set text [:pick $data $tStart $tEnd] }
  }

  :if ([ $isTrustedChat $chatId ]) do={
    :log info ("TG POLLER: chat=" . $chatId . " text=\"" . $text . "\"")
  } else={
    :log warning ("TG POLLER: pesan dari chat tak dipercaya: " . $chatId)
  }

  :set TG_LAST_UPDATE_ID $updId
  :set pos ($uidEnd)
}
```

### `mods/mod_health_check.rsc`
```routeros
:global TG_CHATID_MON; :global tgSendMessage
:global HEALTH_FREE_MEM_WARN_BYTES; :global HEALTH_TEMP_WARN_C; :global HEALTH_UPTIME_WARN_SEC

:local warnings ""

:local freeMem [/system resource get free-memory]
:if ($freeMem < $HEALTH_FREE_MEM_WARN_BYTES) do={
  :set warnings ($warnings . "Low free memory: " . $freeMem . " bytes\n")
}

:do {
  :local temp [/system health get temperature]
  :if ([:typeof $temp]!="nothing" && [:tonum $temp] >= $HEALTH_TEMP_WARN_C) do={
    :set warnings ($warnings . "High temperature: " . $temp . " C\n")
  }
} on-error={ :log info "HEALTH: sensor temperature tidak tersedia" }

:local up [/system resource get uptime]
:local upsec [/system resource get uptime-seconds]
:if ($upsec >= $HEALTH_UPTIME_WARN_SEC) do={
  :set warnings ($warnings . "Long uptime: " . $up . "\n")
}

:if ([:len $warnings] > 0) do={
  :local msg ("[Health Warning]\n" . $warnings)
  $tgSendMessage $TG_CHATID_MON $msg
  :log warning $msg
} else={
  :log info "HEALTH: OK"
}
```

### `mods/mod_log_forwarder.rsc`
```routeros
:global TG_CHATID_MON; :global LOG_FORWARD_LINES; :global tgSendMessage

:local count $LOG_FORWARD_LINES
:if ($count < 1) do={ :set count 50 }

:local idx 0
:local msg "[Log Forwarder] Last " . $count . " lines:\n"
:foreach l in=[/log find] do={
  :if ($idx >= $count) do={ :break }
  :local time [/log get $l time]
  :local topics [/log get $l topics]
  :local txt [/log get $l message]
  :set txt [:pick $txt 0 400]
  :set msg ($msg . $time . " " . $topics . " " . $txt . "\n")
  :set idx ($idx + 1)
}

$tgSendMessage $TG_CHATID_MON $msg
```

### `mods/mod_user_eventlog.rsc`
```routeros
:global TG_CHATID_MON; :global tgSendMessage
:local evt $"event"; :local user [$"user"]; :local addr [$"address"]; :local mac [$"mac-address"]; :local hs [$"hotspot"]
:local msg ("[Hotspot] " . $evt . "\nUser: " . $user . "\nIP: " . $addr . "\nMAC: " . $mac . "\nProfile: " . $hs)
$tgSendMessage $TG_CHATID_MON $msg

:local LOGFILE "user-events.log"
:local cur ""
:if ([:len [/file find name=$LOGFILE]]>0) do={ :set cur [/file get $LOGFILE contents] } else={ /file add name=$LOGFILE contents="" }
:/file set $LOGFILE contents=($cur.$msg."\r\n")
```

### `mods/mod_restart_via_telegram.rsc`
```routeros
:global TG_CHATID_MON; :global RESTART_SECRET; :global isTrustedChat; :global tgSendMessage

:local arg ($"arg")
:local fromChat ($"chat_id")

:if (![ $isTrustedChat $fromChat ]) do={
  :local warn ("RESTART: chat tak dipercaya: " . $fromChat)
  :log warning $warn
  $tgSendMessage $TG_CHATID_MON $warn
  :return
}

:if ($arg = $RESTART_SECRET) do={
  :local info "RESTART: Secret valid, reboot now"
  :log warning $info
  $tgSendMessage $TG_CHATID_MON $info
  /system reboot
} else={
  :local info "RESTART: Secret salah"
  :log warning $info
  $tgSendMessage $TG_CHATID_MON $info
}
```

### `tools/self-test.rsc`
```routeros
:log info "SELFTEST: mulai…"
:local errs 0
:if ([:typeof TG_TOKEN_MON]="nothing" || [:len $TG_TOKEN_MON]=0) do={ :log warning "SELFTEST: TG_TOKEN_MON kosong/tdk ada"; :set errs ($errs+1) }
:if ([:typeof TG_CHATID_MON]="nothing" || [:len $TG_CHATID_MON]=0) do={ :log warning "SELFTEST: TG_CHATID_MON kosong/tdk ada"; :set errs ($errs+1) }

:local hasSend false
:if ([:typeof tgSendMessage]!="nothing") do={ :set hasSend true } else={ :log warning "SELFTEST: helper tgSendMessage tidak ditemukan"; :set errs ($errs+1) }
:local hasTrust false
:if ([:typeof isTrustedChat]!="nothing") do={ :set hasTrust true } else={ :log warning "SELFTEST: helper isTrustedChat tidak ditemukan"; :set errs ($errs+1) }

:if ($hasSend) do={
  :local host [/system identity get name]
  :local msg ("[SELFTEST] OK start on " . $host . "\nTime: " . [/system clock get time] . " " . [/system clock get date])
  $tgSendMessage $TG_CHATID_MON $msg
}

:local modsOk 0
:foreach n in={"mod_user_eventlog";"mod_health_check";"mod_log_forwarder";"mod_tg_poller";"mod_restart_via_telegram"} do={
  :if ([:len [/system script find name=$n]]>0) do={ :set modsOk ($modsOk+1) } else={ :log warning ("SELFTEST: script hilang: " . $n) }
}
:if ([:len [/system script find name="User-Event-Hook"]]=0) do={ :log warning "SELFTEST: User-Event-Hook tidak ada" } else={ :set modsOk ($modsOk+1) }

:local schedOk 0
:foreach s in={"sch_mod_health_check";"sch_mod_log_forwarder";"sch_mod_tg_poller"} do={
  :if ([:len [/system scheduler find name=$s]]>0) do={ :set schedOk ($schedOk+1) } else={ :log warning ("SELFTEST: scheduler hilang: " . $s) }
}

:local warn ""
:if ([:typeof HEALTH_FREE_MEM_WARN_BYTES]!="nothing") do={
  :local fm [/system resource get free-memory]
  :if ($fm < $HEALTH_FREE_MEM_WARN_BYTES) do={ :set warn ($warn . "Low free mem: " . $fm . " bytes\n") }
}
:if ([:typeof HEALTH_TEMP_WARN_C]!="nothing") do={
  :do {
    :local t [/system health get temperature]
    :if ([:typeof $t]!="nothing" && [:tonum $t] >= $HEALTH_TEMP_WARN_C) do={ :set warn ($warn . "High temp: " . $t . " C\n") }
  } on-error={ :log info "SELFTEST: sensor temperature tidak tersedia" }
}
:if ([:typeof HEALTH_UPTIME_WARN_SEC]!="nothing") do={
  :local us [/system resource get uptime-seconds]
  :if ($us >= $HEALTH_UPTIME_WARN_SEC) do={ :set warn ($warn . "Long uptime: " . [/system resource get uptime] . "\n") }
}

:local certMsg ""
:local foundX1 false
:local foundX2 false
:foreach c in=[/certificate find] do={
  :local cn [/certificate get $c name]
  :if ([:find $cn "ISRG Root X1"]!=nil) do={ :set foundX1 true }
  :if ([:find $cn "ISRG Root X2"]!=nil) do={ :set foundX2 true }
}
:if ($foundX1 || $foundX2) do={
  :set certMsg ("Cert: ISRG present (X1=" . $foundX1 . ", X2=" . $foundX2 . ")")
} else={
  :local f1 ([:len [/file find name="isrgrootx1.pem"]]>0)
  :local f2 ([:len [/file find name="isrgrootx2.pem"]]>0)
  :set certMsg ("Cert: ISRG not in store; files x1=" . $f1 . ", x2=" . $f2)
}

:local count 50
:if ([:typeof LOG_FORWARD_LINES]!="nothing" && $LOG_FORWARD_LINES>0) do={ :set count $LOG_FORWARD_LINES }
:local have 0
:foreach _ in=[/log find] do={
  :set have ($have+1)
  :if ($have >= $count) do={ :break }
}

:local offsMsg ""
:if ([:typeof TG_LAST_UPDATE_ID]="nothing") do={
  :set offsMsg "TG_LAST_UPDATE_ID: not set"
} else={
  :set offsMsg ("TG_LAST_UPDATE_ID: " . $TG_LAST_UPDATE_ID)
}

:local summary ("[SELFTEST RESULT]\n" .
  "Mods: " . $modsOk . "/6 ok\n" .
  "Schedulers: " . $schedOk . "/3 ok\n" .
  "HealthWarn:\n" . ($warn!="" ? $warn : "- none -\n") .
  $certMsg . "\n" .
  "Log lines available (cap): " . $have . "/" . $count . "\n" .
  $offsMsg . "\n" .
  "Errors during test: " . $errs )

:log info $summary
:if ($hasSend) do={ $tgSendMessage $TG_CHATID_MON $summary }

:log info "SELFTEST: selesai."
```

---

## Troubleshooting Ringkas

- **Tidak ada pesan Telegram:** Periksa `TG_TOKEN_MON`, `TG_CHATID_MON`, koneksi internet. Jalankan `self-test.rsc`.
- **Poller baca pesan lama:** Pastikan `environment.rsc` diimport lebih dulu; monitor `TG_LAST_UPDATE_ID`.
- **Log berlebihan:** Kurangi `LOG_FORWARD_LINES` (mis. 100). Ingat limit Telegram.

---

## Uninstall (opsional)
```routeros
/system scheduler remove [find name~"sch_mod_"]
/system script remove [find name~"mod_"]
/system script remove [find name="User-Event-Hook"]
/file remove "user-events.log"
```

— Selesai —
