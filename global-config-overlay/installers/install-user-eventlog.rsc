#!rsc
# Installer: User-Event-Hook
:if ([:len [/system script find where name="User-Event-Hook"]] > 0) do={
    /system script remove [find where name="User-Event-Hook"]
}

/system script add name="User-Event-Hook" source={

    :global TG_TOKEN_MON "ISI-DENGAN-TOKEN-BOT";
    :global TG_CHATID_MON "ISI-DENGAN-CHAT-ID";
    :global USER_EVENTS_FILE "user-events.log";

    :local action $action
    :local username $user
    :local ipaddr $address
    :local macaddr $mac

    :local logtime [/system clock get time]
    :local logdate [/system clock get date]
    :local timestamp ("$logdate $logtime")

    :local msg ("### User Session Event\n" .
        "**Time:** $timestamp\n" .
        "**Event:** $action\n" .
        "**User:** `$username`\n" .
        "**IP:** `$ipaddr`\n" .
        "**MAC:** `$macaddr`\n")

    :do {
        /tool fetch url=("https://api.telegram.org/bot$TG_TOKEN_MON/sendMessage?chat_id=$TG_CHATID_MON&parse_mode=Markdown&text=$msg") \
        http-method=get keep-result=no
    } on-error={ :log warning "[User-Event-Hook] Gagal kirim ke Telegram" }

    :do { :put ($msg . "\r\n") >> $USER_EVENTS_FILE } on-error={
        :log warning "[User-Event-Hook] Gagal tulis ke file"
    }
}

:foreach profId in=[/ip hotspot user profile find] do={
    /ip hotspot user profile set $profId \
        on-login="/system script run User-Event-Hook action=\"Login\" user=\$user address=\$address mac=\$mac" \
        on-logout="/system script run User-Event-Hook action=\"Logout\" user=\$user address=\$address mac=\$mac"
}

:log info "[Installer] User-Event-Hook berhasil diinstall untuk semua Hotspot Profile"
