cd $HOME
sudo apt-get install unzip -y
curl -L -o nomad.zip https://releases.hashicorp.com/nomad/0.8.6/nomad_0.8.6_linux_amd64.zip
unzip nomad.zip
sudo mv nomad /usr/local/bin
nomad version

cat << EOF > $HOME/server.hcl
# Increase log verbosity
log_level = "DEBUG"

# Setup data dir
data_dir = "/tmp/server1"

# Enable the server
server {
    enabled = true

    # Self-elect, should be 3 or 5 for production
    bootstrap_expect = 1
}

EOF

nomad agent -config server.hcl > ~/nomad-server.log 2>&1 &

