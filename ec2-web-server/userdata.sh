#! /bin/bash -v

apt-get update -y
apt-get install -y nginx > /tmp/nginx.log


WEBSRV=$(curl http://169.254.169.254/latest/meta-data/instance-id)
cat <<EOM > /var/www/html/index.nginx-debian.html
<html>
<head>
<title>Welcome to nginx</title>
<style>
    body {
        width: 35em;
        margin: 0 auto;
        font-family: Tahoma, Verdana, Arial, sans-serif;
    }
</style>
</head>
<body>
<h1>Welcome to $WEBSRV</h1>
</body>
</html>
EOM