# Fetch & import semua komponen dgn kontrol error; environment dulu!
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
