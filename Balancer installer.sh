sudo apt install git docker.io -y
sudo docker build -t s.tyapkin https://github.com/SergTyapkin/load-balancer.git#main
sudo docker run -p 80:80 --name Balancer -t s.tyapkin &


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


# Download prometheus:
# --
sudo wget https://github.com/prometheus/prometheus/releases/download/v2.30.3/prometheus-2.30.3.linux-amd64.tar.gz
sudo tar zxvf prometheus-2.30.3.linux-amd64.tar.gz
sudo mkdir /etc/prometheus
sudo mkdir /var/lib/prometheus
sudo cp prometheus-2.30.3.linux-amd64/prometheus prometheus-2.30.3.linux-amd64/promtool /usr/local/bin/
sudo cp -r prometheus-2.30.3.linux-amd64/console_libraries prometheus-2.30.3.linux-amd64/consoles prometheus-2.30.3.linux-amd64/prometheus.yml /etc/prometheus
sudo useradd --no-create-home --shell /bin/false prometheus
sudo chown -R prometheus:prometheus /etc/prometheus
sudo chown prometheus:prometheus /var/lib/prometheus
sudo chown prometheus:prometheus /usr/local/bin/{prometheus,promtool}

# Configure prometheus:
# --
sudo cat >> /etc/prometheus/prometheus.yml <<EOF
  - job_name: 'backends'
    static_configs:
      - targets: ['10.129.0.6:9100', '10.129.0.29:9100', '10.129.0.31:9100']
  - job_name: 'backends_rps'
    static_configs:
      - targets: ['10.129.0.6:5000', '10.129.0.29:5000', '10.129.0.31:5000']
  - job_name: 'balancer'
    static_configs:
      - targets: ['localhost:9100']
EOF
sudo cat > /etc/systemd/system/prometheus.service <<EOF
[Unit]
Description=Prometheus
Wants=network-online.target
After=network-online.target

[Service]
User=prometheus
Group=prometheus
ExecStart=/usr/local/bin/prometheus \
    --config.file /etc/prometheus/prometheus.yml \
    --storage.tsdb.path /var/lib/prometheus/ \
    --web.console.templates=/etc/prometheus/consoles \
    --web.console.libraries=/etc/prometheus/console_libraries

[Install]
WantedBy=default.target
EOF
sudo systemctl daemon-reload
sudo systemctl start prometheus
sudo systemctl enable prometheus
sudo systemctl status prometheus


# Download and start grafana:
# --
wget https://dl.grafana.com/enterprise/release/grafana-enterprise_8.2.2_amd64.deb
sudo apt install ./grafana-enterprise_8.2.2_amd64.deb -y
sudo systemctl start grafana-server
sudo systemctl enable grafana-server
sudo systemctl status grafana-server
