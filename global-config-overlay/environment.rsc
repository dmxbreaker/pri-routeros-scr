# === Environment / Globals (ROS 7.20, hAP ax2) ===
# UBAH NILAI INI SESUAI LINGKUNGANMU
:global TG_TOKEN_MON         "YOUR_TELEGRAM_BOT_TOKEN"
:global TG_CHATID_MON        "123456789"
# koma tanpa spasi jika lebih dari satu
:global TG_TRUSTED_CHATIDS   "123456789,987654321"

:global RESTART_SECRET       "change-me-LongerRandom123!@#"

# Log forwarder batas baris terakhir
:global LOG_FORWARD_LINES    200

# Offset Telegram getUpdates (dipelihara oleh mod_tg_poller)
:global TG_LAST_UPDATE_ID    0

# Ambang kesehatan (bytes, celcius, detik)
:global HEALTH_FREE_MEM_WARN_BYTES  209715200   ;# ~200 MB
:global HEALTH_TEMP_WARN_C          80
:global HEALTH_UPTIME_WARN_SEC      604800      ;# 7 hari

# ========= Helper Umum =========
# URL-encode sederhana (alfanumerik dan - _ . ~ dibiarkan)
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

# Kirim message Telegram via POST form-urlencoded
:global tgSendMessage do={
  :local chatId ($1); :local text ($2)
  :global TG_TOKEN_MON; :global f_urlencode
  :local url ("https://api.telegram.org/bot".$TG_TOKEN_MON."/sendMessage")
  :local body ("chat_id=".[ $f_urlencode $chatId ]."&text=".[ $f_urlencode $text ])
  /tool fetch url=$url http-method=post http-data=$body \
    http-header-field="Content-Type: application/x-www-form-urlencoded" \
    output=none keep-result=no as-value
}

# Cek apakah chat_id termasuk trusted (kosong = allow all)
:global isTrustedChat do={
  :local chatId ($1); :global TG_TRUSTED_CHATIDS
  :if ([:len $TG_TRUSTED_CHATIDS]=0) do={ :return true }
  :foreach a in=[:toarray [:pick ($TG_TRUSTED_CHATIDS.",") 0 [:len ($TG_TRUSTED_CHATIDS.",")]]] do={
    :if (("$a"="$chatId")) do={ :return true }
  }
  :return false
}