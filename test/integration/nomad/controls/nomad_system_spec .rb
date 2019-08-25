
control 'nomad_system' do
  describe command('nomad --version') do
    its('stdout') { should match (/0.9.5/) }
  end
end