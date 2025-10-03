#!rsc
# Restart router jika command benar

:global mod_restart_via_telegram do={
    :global RESTART_SECRET;
    :global TG_TOKEN_MON;
    :global TG_CHATID_MON;

    :local arg ($1)
    :if ($arg = $RESTART_SECRET) do={
        /tool fetch url=("https://api.telegram.org/bot$TG_TOKEN_MON/sendMessage?chat_id=$TG_CHATID_MON&text=Router restarting...") http-method=get keep-result=no
        /system reboot
    } else={
        /tool fetch url=("https://api.telegram.org/bot$TG_TOKEN_MON/sendMessage?chat_id=$TG_CHATID_MON&text=Invalid secret, restart aborted") http-method=get keep-result=no
    }
}
