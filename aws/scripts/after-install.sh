# Configure environment variables
# --------------------------------------------------------------------------------
# The values are stored in AWS Parameter Store
# 'sed' removes double quotes from the environment variables

SECRET_KEY=$(aws ssm get-parameters --region us-east-1 --names SECRET_KEY --with-decryption --query Parameters[0].Value)
SECRET_KEY=`echo $SECRET_KEY | sed -e 's/^"//' -e 's/"$//'`

SERVER_IP=$(curl https://checkip.amazonaws.com)

cat > /home/ec2-user/project/.env <<EOF
SECRET_KEY=${SECRET_KEY}
DEBUG=False
ALLOWED_HOSTS=${SERVER_IP}

EOF


# Install dependencies
# --------------------------------------------------------------------------------

python3.11 -m venv .venv

source .venv/bin/activate

python3.11 -m pip install -r requirements.txt


# Install Gunicorn
# --------------------------------------------------------------------------------

python3.11 -m pip install gunicorn

cat > /etc/systemd/system/gunicorn.socket <<EOF
[Unit]
Description=gunicorn socket

[Socket]
ListenStream=/run/gunicorn.sock

[Install]
WantedBy=sockets.target

EOF

cat > /etc/systemd/system/gunicorn.service <<EOF
[Unit]
Description=gunicorn daemon
Requires=gunicorn.socket
After=network.target

[Service]
User=ec2-user
Group=www-data
WorkingDirectory=/home/ec2-user/project
ExecStart=/home/ec2-user/project/.venv/bin/gunicorn \
          --access-logfile - \
          --workers 3 \
          --bind unix:/run/gunicorn.sock \
          example.wsgi:application

[Install]
WantedBy=multi-user.target

EOF


# Install Nginx
# --------------------------------------------------------------------------------

yum install -y nginx

cat > /etc/nginx/conf.d/project.conf <<EOF
server {
    listen 80;
    server_name ${SERVER_IP};

    location = /favicon.ico { access_log off; log_not_found off; }

    location / {
        proxy_set_header Host \$http_host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_pass http://unix:/run/gunicorn.sock;
    }
}

EOF
