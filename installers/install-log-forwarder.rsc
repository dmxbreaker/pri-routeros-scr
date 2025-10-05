:if ([:len [/system script find name="mod_log_forwarder"]]=0) do={ :error "mod_log_forwarder belum diimport" }
/system scheduler remove [find name="sch_mod_log_forwarder"]
/system scheduler add name="sch_mod_log_forwarder" on-event="/system script run mod_log_forwarder" \
  policy=read,write,test,sensitive start-time=startup interval=30m
:log info "INSTALL-LF: scheduler aktif"
