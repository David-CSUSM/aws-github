systemctl start gunicorn.socket
systemctl enable gunicorn.socket

# testing
systemctl status gunicorn.socket
# testing
file /run/gunicorn.sock

systemctl restart nginx
