# Cek memori/temperatur/uptime; kirim alert via helper.
:global TG_CHATID_MON; :global tgSendMessage
:global HEALTH_FREE_MEM_WARN_BYTES; :global HEALTH_TEMP_WARN_C; :global HEALTH_UPTIME_WARN_SEC

:local warnings ""

:local freeMem [/system resource get free-memory]
:if ($freeMem < $HEALTH_FREE_MEM_WARN_BYTES) do={
  :set warnings ($warnings . "Low free memory: " . $freeMem . " bytes\n")
}

:do {
  :local temp [/system health get temperature]
  :if ([:typeof $temp]!="nothing" && [:tonum $temp] >= $HEALTH_TEMP_WARN_C) do={
    :set warnings ($warnings . "High temperature: " . $temp . " C\n")
  }
} on-error={ :log info "HEALTH: sensor temperature tidak tersedia" }

:local up [/system resource get uptime]
:local upsec [/system resource get uptime-seconds]
:if ($upsec >= $HEALTH_UPTIME_WARN_SEC) do={
  :set warnings ($warnings . "Long uptime: " . $up . "\n")
}

:if ([:len $warnings] > 0) do={
  :local msg ("[Health Warning]\n" . $warnings)
  $tgSendMessage $TG_CHATID_MON $msg
  :log warning $msg
} else={
  :log info "HEALTH: OK"
}
