require 'spec_helper_acceptance'

if fact('osfamily') != 'Suse'

describe "Elasticsearch class:" do

  case fact('osfamily')
  when 'RedHat'
    package_name = 'elasticsearch'
    url = 'https://download.elasticsearch.org/elasticsearch/elasticsearch/elasticsearch-1.0.0.noarch.rpm'
    local = '/tmp/elasticsearch-1.0.0.noarch.rpm'
    puppet = 'elasticsearch-1.0.0.noarch.rpm'
  when 'Debian'
    package_name = 'elasticsearch'
    url = 'https://download.elasticsearch.org/elasticsearch/elasticsearch/elasticsearch-1.0.0.deb'
    local = '/tmp/elasticsearch-1.0.0.deb'
    puppet = 'elasticsearch-1.0.0.deb'
  end

  shell("mkdir -p #{default['distmoduledir']}/another/files")
  curl_with_retries('Download package for local file test', default, "#{url} -o #{local}", 0)
  shell("cp #{local} #{default['distmoduledir']}/another/files/#{puppet}")

  context "install via http resource" do

    it 'should run successfully' do
      pp = "class { 'elasticsearch': package_url => '#{url}', java_install => true, config => { 'node.name' => 'elasticsearch001' } }"

      # Run it twice and test for idempotency
      apply_manifest(pp, :catch_failures => true)
      sleep 10
      expect(apply_manifest(pp, :catch_failures => true).exit_code).to be_zero

    end

    describe package(package_name) do
      it { should be_installed }
    end

  end

  context "Clean" do
    it 'should run successfully' do
      apply_manifest("class { 'elasticsearch': ensure => absent }", :catch_failures => true)
    end

    describe package(package_name) do
      it { should_not be_installed }
    end
  end

  context "Install via local file resource" do

    it 'should run successfully' do
      pp = "class { 'elasticsearch': package_url => 'file:#{local}', java_install => true, config => { 'node.name' => 'elasticsearch001' } }"

      # Run it twice and test for idempotency
      apply_manifest(pp, :catch_failures => true)
      sleep 10
      expect(apply_manifest(pp, :catch_failures => true).exit_code).to be_zero

    end

    describe package(package_name) do
      it { should be_installed }
    end

  end

  context "Clean" do
    it 'should run successfully' do
      apply_manifest("class { 'elasticsearch': ensure => absent }", :catch_failures => true)
    end

    describe package(package_name) do
      it { should_not be_installed }
    end
  end

  context "Install via Puppet resource" do

    it 'should run successfully' do
      pp = "class { 'elasticsearch': package_url => 'puppet:///modules/another/#{puppet}', java_install => true, config => { 'node.name' => 'elasticsearch001' } }"

      # Run it twice and test for idempotency
      apply_manifest(pp, :catch_failures => true)
      sleep 10
      expect(apply_manifest(pp, :catch_failures => true).exit_code).to be_zero

    end

    describe package(package_name) do
      it { should be_installed }
    end

  end

end

end
