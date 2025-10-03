#!rsc
# Poll Telegram bot untuk ambil perintah sederhana

:global mod_tg_poller do={
    :global TG_TOKEN_MON;
    :global TG_LAST_UPDATE_ID;
    :global TG_TRUSTED_CHATIDS;

    :local offset ($TG_LAST_UPDATE_ID + 1)
    :local url ("https://api.telegram.org/bot$TG_TOKEN_MON/getUpdates?offset=$offset&limit=5")

    :local res ""
    :do {
        :set res ([/tool fetch url=$url as-value output=user]->"data")
    } on-error={ :log warning "[mod_tg_poller] gagal fetch"; :return }

    :local idx [:find $res "\"text\""]
    :if ($idx != -1) do={
        :local txt [:pick $res ($idx+8) ($idx+80)]
        :log info ("[mod_tg_poller] pesan: " . $txt)
    }
}
