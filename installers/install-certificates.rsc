#!rsc
# install-certificates.rsc
# Auto fetch & import Let's Encrypt root certificates (ISRG Root X1 & X2)
# Dibutuhkan agar RouterOS bisa fetch script via HTTPS (GitHub, dll.)

:log info "[install-certificates] Mulai download root certificates..."

# Download ISRG Root X1
/tool fetch url="https://letsencrypt.org/certs/isrgrootx1.pem" dst-path="isrg-root-x1.pem"
:delay 2s
/certificate import file-name=isrg-root-x1.pem passphrase=""

# Download ISRG Root X2
/tool fetch url="https://letsencrypt.org/certs/isrg-root-x2.pem" dst-path="isrg-root-x2.pem"
:delay 2s
/certificate import file-name=isrg-root-x2.pem passphrase=""

:log info "[install-certificates] Import certificate selesai. Router siap fetch via HTTPS."
