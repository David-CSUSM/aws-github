yum update -y

# Install Python 3.11 with pip
# --------------------------------------------------------------------------------

yum install -y python3.11

python3.11 -m ensurepip --upgrade

python3.11 -m pip install --upgrade pip
