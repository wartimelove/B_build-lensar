#!/bin/bash

cat >/root/build-server/log/patch.html << EOF
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 3.2 Final//EN">
<html>
 <head>
  <title>Info of Commit patch</title>
 </head>
 <body>
<commit_info>
EOF

cd /build_server/ ;ls >> /root/build-server/log/patch.html

cat >> /root/build-server/log/patch.html << EOF
 </commit_info>

</body></html>
EOF

