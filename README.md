# async-emerge-overlay
Async emerge overlay for layman/repo for portage.

Use this repo to add AE to Gentoo.

Fast add:
# cat > /etc/portage/repos.conf/async-emerge.conf
[async-emerge]
location = /usr/portage/overlays/async-emerge/
sync-type = git
sync-uri = https://github.com/alexdux/async-emerge-overlay.git
auto-sync = true
^D
# eix-sync
# emerge async-emerge
