# Install Let's Encrypt (ISRG) roots – dengan penanganan error
:do {
  :log info "CERT: mengunduh ISRG Root X1/X2"
  /tool fetch url="https://letsencrypt.org/certs/isrgrootx1.pem" mode=https dst-path="isrgrootx1.pem" keep-result=yes
  /tool fetch url="https://letsencrypt.org/certs/isrgrootx2.pem" mode=https dst-path="isrgrootx2.pem" keep-result=yes

  :if ([:len [/file find name="isrgrootx1.pem"]]=0) do={ :error "CERT: isrgrootx1.pem tidak ditemukan" }
  :if ([:len [/file find name="isrgrootx2.pem"]]=0) do={ :error "CERT: isrgrootx2.pem tidak ditemukan" }

  :log info "CERT: impor ke /certificate"
  /certificate import file-name="isrgrootx1.pem" passphrase=""
  /certificate import file-name="isrgrootx2.pem" passphrase=""

  :log info "CERT: selesai"
} on-error={ :log warning ("CERT: gagal - " . $"message") }
