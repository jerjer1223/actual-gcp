FROM actualbudget/actual-server:latest
RUN apt-get update && apt-get install -y python3 python3-pip git cron
RUN git clone https://github.com/corrin/akahu_to_budget.git /opt/akahu_to_budget
RUN pip3 install -r /opt/akahu_to_budget/requirements.txt --break-system-packages
RUN echo "0 0 * * * python3 /opt/akahu_to_budget/flask_app.py --sync >> /var/log/akahu_sync.log 2>&1" > /etc/cron.d/akahu_sync
RUN echo "BASH_ENV=/opt/akahu_to_budget/.env" >> /etc/cron.d/akahu_sync
RUN chmod 0644 /etc/cron.d/akahu_sync && crontab /etc/cron.d/akahu_sync
RUN mkdir -p /var/log && touch /var/log/akahu_sync.log
CMD ["sh", "-c", "cron && start-actual"]