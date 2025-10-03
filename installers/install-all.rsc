#!rsc
# install-all.rsc - Auto fetch & import all configs, mods, installers
# Inspired by eworm-de/routeros-scripts
# Repo: https://github.com/dmxbreaker/pri-routeros-scr

:local baseUrl "https://raw.githubusercontent.com/dmxbreaker/pri-routeros-scr/main"

:log info "[install-all] Start installation from $baseUrl"

# ===== Fetch & Import Global Config =====
/tool fetch url="$baseUrl/global-config-overlay/environment.rsc" dst-path=environment.rsc
/import file-name=environment.rsc

# ===== Fetch & Import Mods =====
:foreach f in={"mod_user_eventlog.rsc";"mod_tg_poller.rsc";"mod_health_check.rsc";"mod_log_forwarder.rsc";"mod_restart_via_telegram.rsc"} do={
    /tool fetch url="$baseUrl/mods/$f" dst-path=$f
    /import file-name=$f
    :log info "[install-all] Imported $f"
}

# ===== Fetch & Import Installers =====
:foreach f in={"install-user-eventlog.rsc";"install-health-check.rsc";"install-log-forwarder.rsc";"install-tg-poller.rsc"} do={
    /tool fetch url="$baseUrl/installers/$f" dst-path=$f
    /import file-name=$f
    :log info "[install-all] Imported $f"
}

:log info "[install-all] Installation complete!"
