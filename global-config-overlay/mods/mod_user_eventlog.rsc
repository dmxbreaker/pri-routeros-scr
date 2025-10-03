#!rsc
:global mod_user_eventlog do={

    :local event     ($1)
    :local username  ($2)
    :local ipaddr    ($3)
    :local macaddr   ($4)

    :global TG_TOKEN_MON;
    :global TG_CHATID_MON;
    :global USER_EVENTS_FILE;

    :local logtime [/system clock get time]
    :local logdate [/system clock get date]
    :local timestamp ("$logdate $logtime")

    :local msg ("### User Session Event\n" .
        "**Time:** $timestamp\n" .
        "**Event:** $event\n" .
        "**User:** `$username`\n" .
        "**IP:** `$ipaddr`\n" .
        "**MAC:** `$macaddr`\n")

    :do {
        /tool fetch url=("https://api.telegram.org/bot$TG_TOKEN_MON/sendMessage?chat_id=$TG_CHATID_MON&parse_mode=Markdown&text=$msg") \
        http-method=get keep-result=no
    } on-error={
        :log warning "[mod_user_eventlog] Failed send to Telegram"
    }

    :do {
        :put ($msg . "\r\n") >> $USER_EVENTS_FILE
    } on-error={
        :log warning "[mod_user_eventlog] Failed write to file"
    }
}
