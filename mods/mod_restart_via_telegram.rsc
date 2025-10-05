# Reboot jika secret cocok & chat_id terpercaya; helper pusat.
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
