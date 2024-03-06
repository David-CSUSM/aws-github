echo "after install"
SECRET_KEY=$(aws ssm get-parameters --region us-east-1 --names SECRET_KEY --with-decryption --query Parameters[0].Value)
echo $SECRET_KEY

DEBUG=$(aws ssm get-parameters --region us-east-1 --names DEBUG --with-decryption --query Parameters[0].Value)
echo $DEBUG

ALLOWED_HOSTS=$(aws ssm get-parameters --region us-east-1 --names ALLOWED_HOSTS --with-decryption --query Parameters[0].Value)
echo $ALLOWED_HOSTS
