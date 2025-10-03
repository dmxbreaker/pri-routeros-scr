#!rsc
# Installer: Health Check Monitoring
# Tambah scheduler untuk cek kesehatan tiap 10 menit

:if ([:len [/system scheduler find where name="HealthCheck"]] > 0) do={
    /system scheduler remove [find where name="HealthCheck"]
}

/system scheduler add name="HealthCheck" interval=10m \
    on-event="/system script run mod_health_check"

:log info "[Installer] HealthCheck scheduler aktif (10 menit sekali)"
