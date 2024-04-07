# Configure environment variables
# --------------------------------------------------------------------------------
# The values are stored in AWS Parameter Store
# 'sed' removes double quotes from the environment variables

SECRET_KEY=$(aws ssm get-parameters --region us-east-1 --names SECRET_KEY --with-decryption --query Parameters[0].Value)
SECRET_KEY=`echo $SECRET_KEY | sed -e 's/^"//' -e 's/"$//'`

SERVER_IP=$(curl https://checkip.amazonaws.com)

cat > /home/ec2-user/project/.env <<EOF
SECRET_KEY=${SECRET_KEY}
ALLOWED_HOSTS=${SERVER_IP}

EOF


# Install Requirements
# --------------------------------------------------------------------------------

source /home/ec2-user/venv/bin/activate

python3.11 -m pip install -r /home/ec2-user/project/requirements.txt


# Configure static files
# --------------------------------------------------------------------------------

cd /home/ec2-user/project

python3.11 manage.py collectstatic --clear --noinput


# Configure Permissions
# --------------------------------------------------------------------------------

chown -R ec2-user:ec2-user /home/ec2-user
chmod -R 750 /home/ec2-user


# Configure Gunicorn
# --------------------------------------------------------------------------------

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
Group=www
WorkingDirectory=/home/ec2-user/project
ExecStart=/home/ec2-user/venv/bin/gunicorn \
          --access-logfile - \
          --workers 3 \
          --bind unix:/run/gunicorn.sock \
          scoresensei.wsgi:application

[Install]
WantedBy=multi-user.target

EOF

systemctl start gunicorn.socket
systemctl enable gunicorn.socket


# Configure Nginx
# --------------------------------------------------------------------------------

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

    location /static/ {
        root /home/ec2-user/project;
    }
}

EOF
