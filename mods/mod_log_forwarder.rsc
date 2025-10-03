#!rsc
# Kirim potongan log ke Telegram

:global mod_log_forwarder do={
    :global TG_TOKEN_MON;
    :global TG_CHATID_MON;
    :global LOG_FORWARD_LINES;

    :local logs ""
    :foreach li in=[/log find] do={
        :set logs ($logs . "\n" . [/log get $li message])
    }

    :local msg ("Last logs:\n" . $logs)
    /tool fetch url=("https://api.telegram.org/bot$TG_TOKEN_MON/sendMessage?chat_id=$TG_CHATID_MON&text=$msg") http-method=get keep-result=no
}
