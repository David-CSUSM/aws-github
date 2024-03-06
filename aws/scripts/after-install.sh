echo "after install"
SECRET_KEY=$(aws ssm get-parameters --region us-east-1 --names SECRET_KEY --with-decryption --query Parameters[0].Value)

DEBUG=$(aws ssm get-parameters --region us-east-1 --names DEBUG --with-decryption --query Parameters[0].Value)

ALLOWED_HOSTS=$(aws ssm get-parameters --region us-east-1 --names ALLOWED_HOSTS --with-decryption --query Parameters[0].Value)

cat > .env <<EOL
SECRET_KEY=${SECRET_KEY}
DEBUG=${DEBUG}
ALLOWED_HOSTS=${ALLOWED_HOSTS}
EOL
