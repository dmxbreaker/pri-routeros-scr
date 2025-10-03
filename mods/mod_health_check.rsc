#!rsc
# Monitor kesehatan router

:global mod_health_check do={
    :global TG_TOKEN_MON;
    :global TG_CHATID_MON;
    :global HEALTH_FREE_MEM_WARN_MB;
    :global HEALTH_CPU_TEMP_WARN;

    :local freeMem [/system resource get free-memory]
    :local cpuTemp [/system health get temperature]
    :local uptime [/system resource get uptime]
    :local warn ""

    :if ($freeMem < $HEALTH_FREE_MEM_WARN_MB) do={
        :set warn ($warn . "Low memory: $freeMem\n")
    }
    :if ($cpuTemp > $HEALTH_CPU_TEMP_WARN) do={
        :set warn ($warn . "High CPU temp: $cpuTemp\n")
    }

    :if ([:len $warn] > 0) do={
        :local msg ("⚠️ ALERT:\nUptime: $uptime\n" . $warn)
        /tool fetch url=("https://api.telegram.org/bot$TG_TOKEN_MON/sendMessage?chat_id=$TG_CHATID_MON&text=$msg") http-method=get keep-result=no
    }
}
