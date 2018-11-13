cd $HOME
mkdir nomad-jobs
sudo apt-get install unzip -y
curl -L -o nomad.zip https://releases.hashicorp.com/nomad/0.8.6/nomad_0.8.6_linux_amd64.zip
unzip nomad.zip
sudo mv nomad /usr/local/bin
nomad version

sudo mkdir /etc/nomad

cat << EOF > nomad-server.hcl
# Increase log verbosity
log_level = "DEBUG"

# Setup data dir
data_dir = "/var/lib/nomad"

# Enable the server
server {
    enabled = true

    # Self-elect, should be 3 or 5 for production
    bootstrap_expect = 1
}

EOF

sudo mv $HOME/nomad-server.hcl /etc/nomad

cat << EOF > nomad-server.service
[Unit]
Description=Nomad server

Wants=network-online.target
After=network-online.target

[Service]

ExecStart= /bin/sh -c "/usr/local/bin/nomad agent -config=/etc/nomad/nomad-server.hcl -bind=$(/sbin/ifconfig enp3s0 | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1}')"

Restart=always
RestartSec=10

[Install]

WantedBy=multi-user.target

EOF

sudo mv $HOME/nomad-server.service /etc/systemd/system

sudo systemctl enable nomad-server.service
sudo systemctl start nomad-server.service


