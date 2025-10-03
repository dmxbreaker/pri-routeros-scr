#!rsc
# Installer: Log Forwarder
# Tambah scheduler untuk forward log tiap 30 menit

:if ([:len [/system scheduler find where name="LogForward"]] > 0) do={
    /system scheduler remove [find where name="LogForward"]
}

/system scheduler add name="LogForward" interval=30m \
    on-event="/system script run mod_log_forwarder"

:log info "[Installer] LogForwarder scheduler aktif (30 menit sekali)"
