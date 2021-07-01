
AddPackage ffmpeg # Complete solution to record, convert and stream audio and video
AddPackage lighttpd # A secure, fast, compliant and very flexible web-server
AddPackage ustreamer # Lightweight and fast MJPG-HTTP streamer

CopyFile /usr/local/bin/dvr.sh 755
CopyFile /etc/systemd/system/dvr.service
CreateLink /etc/systemd/system/default.target.wants/dvr.service /etc/systemd/system/dvr.service

CopyFile /etc/systemd/system/srv-http.mount
CreateLink /etc/systemd/system/local-fs.target.wants/srv-http.mount /etc/systemd/system/srv-http.mount
CreateLink /etc/systemd/system/multi-user.target.wants/lighttpd.service /usr/lib/systemd/system/lighttpd.service
