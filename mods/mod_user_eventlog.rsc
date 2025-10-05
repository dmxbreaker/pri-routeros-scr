# tipis: pakai helper pusat
:global TG_CHATID_MON; :global tgSendMessage
:local evt $"event"; :local user [$"user"]; :local addr [$"address"]; :local mac [$"mac-address"]; :local hs [$"hotspot"]
:local msg ("[Hotspot] " . $evt . "\nUser: " . $user . "\nIP: " . $addr . "\nMAC: " . $mac . "\nProfile: " . $hs)
$tgSendMessage $TG_CHATID_MON $msg

:local LOGFILE "user-events.log"
:local cur ""
:if ([:len [/file find name=$LOGFILE]]>0) do={ :set cur [/file get $LOGFILE contents] } else={ /file add name=$LOGFILE contents="" }
:/file set $LOGFILE contents=($cur.$msg."\r\n")
