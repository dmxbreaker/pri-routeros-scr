# Global environment config for monitoring scripts

:global TG_TOKEN_MON "YOUR-BOT-TOKEN";
:global TG_CHATID_MON "YOUR-CHAT-ID";

# Trusted chat ids allowed to issue commands
:global TG_TRUSTED_CHATIDS {
  "YOUR-CHAT-ID";
}

# Secret required for restart command
:global RESTART_SECRET "mySecret123";

# File for storing user session events
:global USER_EVENTS_FILE "user-events.log";

# Init Telegram last update id
:global TG_LAST_UPDATE_ID 0;

# Thresholds for health check
:global HEALTH_FREE_MEM_WARN_MB 200000;
:global HEALTH_CPU_TEMP_WARN 70;

# Lines of logs to forward periodically
:global LOG_FORWARD_LINES 50;
