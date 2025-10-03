#!rsc
# Installer: Telegram Poller
# Tambah scheduler untuk polling perintah dari bot Telegram

:if ([:len [/system scheduler find where name="TG-Poller"]] > 0) do={
    /system scheduler remove [find where name="TG-Poller"]
}

/system scheduler add name="TG-Poller" interval=10s \
    on-event="/system script run mod_tg_poller"

:log info "[Installer] TG-Poller aktif (interval 10 detik)"
