locals {
cloud\_config = <<-EOT
\#cloud-config
\${yamlencode({
write\_files = \[
{
path        = "/etc/systemd/system/duckdns.service"
permissions = "0644"
owner       = "root"
content     = <<-EOT1
\[Unit]
Description=Start DuckDNS

\[Service]
ExecStart=/usr/bin/docker run --rm -e SUBDOMAINS=\${var.duckdns\_subdomains} -e TOKEN=\${var.duckdns\_token} --name=duckdns lscr.io/linuxserver/duckdns\:latest
ExecStop=/usr/bin/docker stop duckdns
ExecStopPost=/usr/bin/docker rm duckdns
EOT1
},
{
path        = "/etc/systemd/system/caddy.service"
permissions = "0644"
owner       = "root"
content     = <<-EOT2
\[Unit]
Description=Start Caddy

\[Service]
ExecStart=/usr/bin/docker run --rm --network custom\_default&#x20;
-v /mnt/disks/data/caddy/config:/config&#x20;
-v /mnt/disks/data/caddy/data:/data&#x20;
\--name=caddy caddy\:alpine
ExecStop=/usr/bin/docker stop caddy
ExecStopPost=/usr/bin/docker rm caddy
EOT2
},
{
path        = "/etc/systemd/system/actual.service"
permissions = "0644"
owner       = "root"
content     = <<-EOT3
\[Unit]
Description=Start Actual Server with Akahu Sync

\[Service]
ExecStart=/usr/bin/docker run --rm --network custom\_default&#x20;
-v /mnt/disks/data/actual-data:/data&#x20;
-v /mnt/disks/data/akahu\_to\_budget/.env:/opt/akahu\_to\_budget/.env&#x20;
\--name=actual\_server gcr.io/\${var.project\_id}/actual-custom\:latest
ExecStop=/usr/bin/docker stop actual\_server
ExecStopPost=/usr/bin/docker rm actual\_server
EOT3
},
{
path        = "/tmp/Caddyfile"
permissions = "0644"
owner       = "root"
content     = <<-EOT4
\${var.actual\_fqdn} {
encode gzip zstd
reverse\_proxy actual\_server:5006
}
EOT4
},
{
path        = "/var/lib/cloud/scripts/per-instance/fs-prepare.sh"
permissions = "0544"
owner       = "root"
content     = <<-EOT5
\#!/bin/bash
fsck.ext4 -tvy /dev/disk/by-id/google-persistent-disk-1
mkdir -p /mnt/disks/data
mount -t ext4 -o nodev,nosuid /dev/disk/by-id/google-persistent-disk-1 /mnt/disks/data
mkdir -p /mnt/disks/data/caddy
mkdir -p /mnt/disks/data/caddy/data
mkdir -p /mnt/disks/data/caddy/config
mkdir -p /mnt/disks/data/actual-data
mkdir -p /mnt/disks/data/akahu\_to\_budget
EOT5
}
],
bootcmd = \[
"fsck.ext4 -tvy /dev/disk/by-id/google-persistent-disk-1",
"mount -t ext4 -o nodev,nosuid /dev/disk/by-id/google-persistent-disk-1 /mnt/disks/data",
"mkdir -p /mnt/disks/data/caddy",
"mkdir -p /mnt/disks/data/actual-data",
"mkdir -p /mnt/disks/data/akahu\_to\_budget",
]
})}
EOT
}
