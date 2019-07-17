
control 'nomad_system' do
  describe command('nomad --version') do
    its('stdout') { should match (/0.9.3/) }
  end
end