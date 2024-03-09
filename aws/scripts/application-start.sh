systemctl start gunicorn.socket
systemctl enable gunicorn.socket

systemctl restart nginx
