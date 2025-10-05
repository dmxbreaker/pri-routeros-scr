# Forward log terakhir N baris (hormati LOG_FORWARD_LINES); helper pusat.
:global TG_CHATID_MON; :global LOG_FORWARD_LINES; :global tgSendMessage

:local count $LOG_FORWARD_LINES
:if ($count < 1) do={ :set count 50 }

:local idx 0
:local msg "[Log Forwarder] Last " . $count . " lines:\n"
:foreach l in=[/log find] do={
  :if ($idx >= $count) do={ :break }
  :local time [/log get $l time]
  :local topics [/log get $l topics]
  :local txt [/log get $l message]
  :set txt [:pick $txt 0 400]
  :set msg ($msg . $time . " " . $topics . " " . $txt . "\n")
  :set idx ($idx + 1)
}

$tgSendMessage $TG_CHATID_MON $msg
