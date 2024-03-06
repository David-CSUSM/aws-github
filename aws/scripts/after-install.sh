# Install Nginx
# --------------------------------------------------------------------------------

# yum install -y nginx

# # edit later for our project
# cat > /etc/nginx/sites-enabled/project.conf <<EOF
# server {
#   set \$my_host \$host;
#   if (\$host ~ "\d+\.\d+\.\d+\.\d+") {
#       set \$my_host "donate-anything.org";
#   }

#   client_max_body_size 2G;
#   server_name donate-anything.org www.donate-anything.org;

#   keepalive_timeout 5;

#   location / {
#     proxy_pass http://127.0.0.1:5000;
#     proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
#     proxy_set_header X-Forwarded-Proto \$scheme;
#     proxy_set_header Host \$my_host;
#     # we don't want nginx trying to do something clever with
#     # redirects, we set the Host: header above already.
#     proxy_redirect off;

#     ## The following is only needed for async frameworks:
#     ## NGINX example https://www.nginx.com/blog/websocket-nginx/
#     ## To turn off buffering, you only need to add `proxy_buffering off;`
#     # proxy_set_header Upgrade \$http_upgrade;
#     # proxy_set_header Connection 'upgrade';
#     ## 25 minutes of no data closes connection
#     # proxy_read_timeout 1500s;
#   }
# }

# EOF

# service nginx restart


# Set working directory of project
cd /home/ec2-user/project


# Configure environment variables
# --------------------------------------------------------------------------------
# The values are stored in AWS Parameter Store
# 'sed' removes double quotes from the environment variables

SECRET_KEY=$(aws ssm get-parameters --region us-east-1 --names SECRET_KEY --with-decryption --query Parameters[0].Value)
SECRET_KEY=`echo $SECRET_KEY | sed -e 's/^"//' -e 's/"$//'`

DEBUG=$(aws ssm get-parameters --region us-east-1 --names DEBUG --with-decryption --query Parameters[0].Value)
DEBUG=`echo $DEBUG | sed -e 's/^"//' -e 's/"$//'`

ALLOWED_HOSTS=$(aws ssm get-parameters --region us-east-1 --names ALLOWED_HOSTS --with-decryption --query Parameters[0].Value)
ALLOWED_HOSTS=`echo $ALLOWED_HOSTS | sed -e 's/^"//' -e 's/"$//'`

cat > .env <<EOF
SECRET_KEY=${SECRET_KEY}
DEBUG=${DEBUG}
ALLOWED_HOSTS=${ALLOWED_HOSTS}

EOF


# Install dependencies
# --------------------------------------------------------------------------------
yum install -y python3.11

python3.11 -m ensurepip --upgrade

python3.11 -m pip install --upgrade pip

python3.11 -m venv .venv

source .venv/bin/activate

python3.11 -m pip install -r requirements.txt
