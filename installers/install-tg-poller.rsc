:if ([:len [/system script find name="mod_tg_poller"]]=0) do={ :error "mod_tg_poller belum diimport" }
/system scheduler remove [find name="sch_mod_tg_poller"]
/system scheduler add name="sch_mod_tg_poller" on-event="/system script run mod_tg_poller" \
  policy=read,write,test,sensitive start-time=startup interval=15s
:log info "INSTALL-POLLER: scheduler aktif"
