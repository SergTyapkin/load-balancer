# sudo apt install git docker.io -y
# sudo docker build -t s.tyapkin https://github.com/SergTyapkin/DB-forums.git
# sudo docker run -p 5000:5000 --name DB_forums -t s.tyapkin

sudo apt update
sudo apt upgrade -y
sudo apt install git golang-go postgresql -y
git clone https://github.com/SergTyapkin/DB-forums.git
cd DB-forums/
sudo service postgresql start
sudo -u postgres psql --command "ALTER USER postgres WITH PASSWORD 'root';"
sudo -u postgres createdb -O postgres DB-forums
sudo echo "listen_addresses='*'" >> /etc/postgresql/12/main/postgresql.conf
sudo echo "host all all 0.0.0.0/0 md5" >> /etc/postgresql/12/main/pg_hba.conf
sudo -u postgres psql -d DB-forums -a -q -f ./sql/initial.sql
sudo go run main.go &


# Download node_exporter:
# --
sudo wget https://github.com/prometheus/node_exporter/releases/download/v1.2.2/node_exporter-1.2.2.linux-amd64.tar.gz
sudo tar zxvf node_exporter-1.2.2.linux-amd64.tar.gz
sudo cp node_exporter-1.2.2.linux-amd64/node_exporter /usr/local/bin/
sudo useradd --no-create-home --shell /bin/false node_exporter

# Configure node_exporter:
# --
sudo cat > /etc/systemd/system/node_exporter.service <<EOF
[Unit]
Description=Node Exporter
Wants=network-online.target
After=network-online.target

[Service]
User=node_exporter
Group=node_exporter
ExecStart=/usr/local/bin/node_exporter

[Install]
WantedBy=default.target
EOF
sudo systemctl daemon-reload
sudo systemctl start node_exporter
sudo systemctl enable node_exporter
sudo systemctl status node_exporter
