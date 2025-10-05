# Hook Hotspot; gunakan helper dari environment (tidak ada duplikasi)
:if ([:len [/system script find name="User-Event-Hook"]]>0) do={ /system script remove "User-Event-Hook" }

/system script add name="User-Event-Hook" policy=ftp,read,write,policy,test,password,sensitive source={
  :global TG_CHATID_MON; :global tgSendMessage
  :local evt $"event"; :local user [$"user"]; :local addr [$"address"]; :local mac [$"mac-address"]; :local hs [$"hotspot"]
  :local msg ("[Hotspot] " . $evt . "\nUser: " . $user . "\nIP: " . $addr . "\nMAC: " . $mac . "\nProfile: " . $hs)
  $tgSendMessage $TG_CHATID_MON $msg

  # append file yang kompatibel antar versi
  :local LOGFILE "user-events.log"
  :local cur ""
  :if ([:len [/file find name=$LOGFILE]]>0) do={ :set cur [/file get $LOGFILE contents] } else={ /file add name=$LOGFILE contents="" }
  /file set $LOGFILE contents=($cur.$msg."\r\n")
}

/ip hotspot profile
:foreach i in=[find] do={
  set $i on-login="/system script run User-Event-Hook event=login user=\$user address=\$address mac-address=\$mac hot-spot=\$hotspot"
  set $i on-logout="/system script run User-Event-Hook event=logout user=\$user address=\$address mac-address=\$mac hot-spot=\$hotspot"
}
:log info "INSTALL-UE: hook terpasang"
