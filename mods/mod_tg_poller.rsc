# Poll getUpdates; validasi chat; update offset. Helper di environment.
:global TG_TOKEN_MON; :global TG_LAST_UPDATE_ID; :global isTrustedChat

:local url ("https://api.telegram.org/bot".$TG_TOKEN_MON."/getUpdates")
:local body ("timeout=0&offset=" . ($TG_LAST_UPDATE_ID + 1))
:local R [/tool fetch url=$url http-method=post http-data=$body http-header-field="Content-Type: application/x-www-form-urlencoded" \
  as-value output=user keep-result=no]
:local data ($R->"data")

:local pos 0
:while ( ( :typeof $data = "str") && (($pos := [:find $data "\"update_id\":" $pos]) != nil) ) do={
  :local uidStart ($pos + 12)
  :local uidEnd   [:find $data "," $uidStart]
  :local updId [:tonum [:pick $data $uidStart $uidEnd]]

  # chat_id
  :local chatPos [:find $data "\"chat\":{\"id\":" $pos]
  :if ($chatPos = nil) do={ :set pos ($pos + 12); :log warning "POLLER: chat_id tidak ditemukan"; :continue }
  :local cidStart ($chatPos + 12)
  :local cidEnd [:find $data "," $cidStart]
  :local chatId [:pick $data $cidStart $cidEnd]

  # text (opsional)
  :local tPos [:find $data "\"text\":\"" $pos]
  :local text ""
  :if ($tPos != nil) do={
    :local tStart ($tPos + 8)
    :local tEnd [:find $data "\"" $tStart]
    :if ($tEnd != nil) do={ :set text [:pick $data $tStart $tEnd] }
  }

  # hanya log dari trusted chat
  :if ([ $isTrustedChat $chatId ]) do={
    :log info ("TG POLLER: chat=" . $chatId . " text=\"" . $text . "\"")
  } else={
    :log warning ("TG POLLER: pesan dari chat tak dipercaya: " . $chatId)
  }

  :set TG_LAST_UPDATE_ID $updId
  :set pos ($uidEnd)
}
