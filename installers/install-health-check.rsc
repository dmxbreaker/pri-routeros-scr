:if ([:len [/system script find name="mod_health_check"]]=0) do={ :error "mod_health_check belum diimport" }
/system scheduler remove [find name="sch_mod_health_check"]
/system scheduler add name="sch_mod_health_check" on-event="/system script run mod_health_check" \
  policy=read,write,test,sensitive start-time=startup interval=10m
:log info "INSTALL-Health Check: scheduler aktif"
