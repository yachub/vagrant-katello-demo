# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|

  config.vm.box = "genebean/centos-7-puppet5"

  config.vm.define "foreman" do |foreman|
    foreman.vm.hostname = "foreman.localdomain"

    foreman.vm.network "private_network", ip: "172.28.128.22"

    foreman.vm.network "forwarded_port", guest:  443, host: 8443
    foreman.vm.network "forwarded_port", guest: 80, host: 8080

    foreman.vm.provider :virtualbox do |vb|
      vb.customize ["modifyvm", :id, "--memory", "8192"]
      vb.customize ["modifyvm", :id, "--cpus", "2"]
    end

    # Installs Foreman and Katello via Forklift
    foreman.vm.provision "shell", inline: "git clone https://github.com/theforeman/forklift.git"
    foreman.vm.provision "shell", inline: "yum install -y ansible"
    foreman.vm.provision "shell", inline: "cd forklift; ansible-playbook -l localhost playbooks/katello.yml -e puppet_repositories_version=5 -e foreman_repositories_version=1.20 -e katello_repositories_version=3.10 | exit 0"
    # The first run errors out. Run again to install successfully
    foreman.vm.provision "shell", inline: "cd forklift; ansible-playbook -l localhost playbooks/katello.yml -e puppet_repositories_version=5 -e foreman_repositories_version=1.20 -e katello_repositories_version=3.10"

    # Sets up a small demo set of lifecycle environments, repositories, products, content views, and activation keys    
    foreman.vm.provision "shell", inline: <<-EOF
      hammer lifecycle-environment create --organization-id 1 --name "Development" --prior "Library"
      hammer lifecycle-environment create --organization-id 1 --name "Production" --prior "Development"
      hammer product create --organization-id 1 --name "Duo"
      hammer repository create --organization-id 1 --content-type "yum" --name "Duo CentOS 6 x86_64" --product "Duo" --url "http://pkg.duosecurity.com/CentOS/6/x86_64"
      hammer repository create --organization-id 1 --content-type "yum" --name "Duo CentOS 7 x86_64" --product "Duo" --url "http://pkg.duosecurity.com/CentOS/7/x86_64"
      hammer product create --organization-id 1 --name "Puppet 5"
      hammer repository create --organization-id 1 --content-type "yum" --name "Puppet 5 EL6 x86_64" --product "Puppet 5" --url "http://yum.puppetlabs.com/puppet5/el/6/x86_64"
      hammer repository create --organization-id 1 --content-type "yum" --name "Puppet 5 EL7 x86_64" --product "Puppet 5" --url "http://yum.puppetlabs.com/puppet5/el/7/x86_64"
      hammer repository create --organization-id 1 --content-type "yum" --name "Puppet 5 EL8 x86_64" --product "Puppet 5" --url "http://yum.puppetlabs.com/puppet5/el/8/x86_64"
      hammer product create --organization-id 1 --name "PostgreSQL 9.6"
      hammer repository create --organization-id 1 --content-type "yum" --name "PostgreSQL 9.6 EL6 x86_64" --product "PostgreSQL 9.6" --url "https://yum.postgresql.org/9.6/redhat/rhel-6-x86_64"
      hammer repository create --organization-id 1 --content-type "yum" --name "PostgreSQL 9.6 EL7 x86_64" --product "PostgreSQL 9.6" --url "https://yum.postgresql.org/9.6/redhat/rhel-7-x86_64"
      hammer product synchronize --organization-id 1 --name "Duo"
      hammer product synchronize --organization-id 1 --name "Puppet 5"
      hammer product synchronize --organization-id 1 --name "PostgreSQL 9.6"

      hammer content-view create --organization-id 1 --name "Base CentOS 6 Repos"
      hammer content-view add-repository --organization-id 1 --name "Base CentOS 6 Repos" --repository "Duo CentOS 6 x86_64"
      hammer content-view add-repository --organization-id 1 --name "Base CentOS 6 Repos" --repository "Puppet 5 EL6 x86_64"
      hammer content-view create --organization-id 1 --name "Base CentOS 7 Repos"
      hammer content-view add-repository --organization-id 1 --name "Base CentOS 7 Repos" --repository "Duo CentOS 7 x86_64"
      hammer content-view add-repository --organization-id 1 --name "Base CentOS 7 Repos" --repository "Puppet 5 EL7 x86_64"
      hammer content-view create --organization-id 1 --name "PostgreSQL 9.6 CentOS 7 Repos"
      hammer content-view add-repository --organization-id 1 --name "PostgreSQL 9.6 CentOS 7 Repos" --repository "PostgreSQL 9.6 EL7 x86_64"
      hammer content-view publish --organization-id 1 --name "Base CentOS 6 Repos"
      hammer content-view publish --organization-id 1 --name "Base CentOS 7 Repos"
      hammer content-view publish --organization-id 1 --name "PostgreSQL 9.6 CentOS 7 Repos"

      hammer content-view version promote --organization-id 1 --content-view "Base CentOS 6 Repos" --to-lifecycle-environment "Development" --version "1.0"
      hammer content-view version promote --organization-id 1 --content-view "Base CentOS 6 Repos" --to-lifecycle-environment "Production" --version "1.0"
      hammer content-view publish --organization-id 1 --name "Base CentOS 6 Repos"
      hammer content-view version promote --organization-id 1 --content-view "Base CentOS 6 Repos" --to-lifecycle-environment "Development" --version "2.0"

      hammer content-view version promote --organization-id 1 --content-view "Base CentOS 7 Repos" --to-lifecycle-environment "Development" --version "1.0"
      hammer content-view version promote --organization-id 1 --content-view "Base CentOS 7 Repos" --to-lifecycle-environment "Production" --version "1.0"
      hammer content-view version promote --organization-id 1 --content-view "PostgreSQL 9.6 CentOS 7 Repos" --to-lifecycle-environment "Development" --version "1.0"
      hammer content-view version promote --organization-id 1 --content-view "PostgreSQL 9.6 CentOS 7 Repos" --to-lifecycle-environment "Production" --version "1.0"
      hammer content-view create --organization-id 1 --composite --name "PostgreSQL 9.6 CentOS 7 Server"

      hammer content-view component add --organization-id 1 --composite-content-view "PostgreSQL 9.6 CentOS 7 Server" --component-content-view "Base CentOS 7 Repos" --latest
      hammer content-view component add --organization-id 1 --composite-content-view "PostgreSQL 9.6 CentOS 7 Server" --component-content-view "PostgreSQL 9.6 CentOS 7 Repos" --latest
      hammer content-view publish --organization-id 1 --name "PostgreSQL 9.6 CentOS 7 Server"
      hammer content-view version promote --organization-id 1 --content-view "PostgreSQL 9.6 CentOS 7 Server" --to-lifecycle-environment "Development" --version "1.0"
      hammer content-view version promote --organization-id 1 --content-view "PostgreSQL 9.6 CentOS 7 Server" --to-lifecycle-environment "Production" --version "1.0"



      hammer content-view publish --organization-id 1 --name "Base CentOS 7 Repos"
      hammer content-view version promote --organization-id 1 --content-view "Base CentOS 7 Repos" --to-lifecycle-environment "Development" --version "2.0"
      hammer content-view publish --organization-id 1 --name "PostgreSQL 9.6 CentOS 7 Repos"
      hammer content-view version promote --organization-id 1 --content-view "PostgreSQL 9.6 CentOS 7 Repos" --to-lifecycle-environment "Development" --version "2.0"
      hammer content-view publish --organization-id 1 --name "PostgreSQL 9.6 CentOS 7 Server"
      hammer content-view version promote --organization-id 1 --content-view "PostgreSQL 9.6 CentOS 7 Server" --to-lifecycle-environment "Development" --version "2.0"
      
      
      hammer activation-key create --organization-id 1 --name "Generic CentOS 6 Server" --lifecycle-environment "Production" --content-view "Base CentOS 6 Repos"
      hammer activation-key create --organization-id 1 --name "Generic CentOS 7 Server" --lifecycle-environment "Production" --content-view "Base CentOS 7 Repos"
      hammer activation-key create --organization-id 1 --name "PostgreSQL 9.6 CentOS 7 Server" --lifecycle-environment "Production" --content-view "PostgreSQL 9.6 CentOS 7 Server"

      hammer activation-key add-subscription --organization-id 1 --name "Generic CentOS 6 Server" --subscription-id 1
      hammer activation-key add-subscription --organization-id 1 --name "Generic CentOS 6 Server" --subscription-id 2
      hammer activation-key add-subscription --organization-id 1 --name "Generic CentOS 7 Server" --subscription-id 1
      hammer activation-key add-subscription --organization-id 1 --name "Generic CentOS 7 Server" --subscription-id 2
      hammer activation-key add-subscription --organization-id 1 --name "PostgreSQL 9.6 CentOS 7 Server" --subscription-id 1
      hammer activation-key add-subscription --organization-id 1 --name "PostgreSQL 9.6 CentOS 7 Server" --subscription-id 2
      hammer activation-key add-subscription --organization-id 1 --name "PostgreSQL 9.6 CentOS 7 Server" --subscription-id 3
      hammer organization add-environment --id 1 --environment "production"
    EOF

    # Install the katello-agent
    # Install and configure remote execution
    # Also fix a bug with job invocations
    foreman.vm.provision "shell", inline: <<-EOF
      yum install -y https://yum.theforeman.org/client/1.20/el7/x86_64/foreman-client-release.rpm
      yum install -y tfm-rubygem-foreman_remote_execution rubygem-smart_proxy_remote_execution_ssh tfm-rubygem-hammer_cli_foreman_remote_execution tfm-rubygem-hammer_cli_foreman_ssh
      yum install -y https://foreman.localdomain/pub/katello-ca-consumer-latest.noarch.rpm
      subscription-manager register --org="Default_Organization" --activationkey="Generic CentOS 7 Server"
      yum install -y katello-agent
      chown foreman-proxy ~foreman-proxy/.ssh
      sudo -u foreman-proxy ssh-keygen -f ~foreman-proxy/.ssh/id_rsa_foreman_proxy -N ''
      restorecon -RvF ~foreman-proxy/.ssh
      hammer proxy refresh-features --organization-id 1 --name "foreman.localdomain"
      sshpass -p vagrant ssh-copy-id -i ~foreman-proxy/.ssh/id_rsa_foreman_proxy.pub -o StrictHostKeyChecking=no root@localhost
      sed -i 's~http:\/\/localhost:3000~https:\/\/foreman.localdomain:443~g' /etc/smart_proxy_dynflow_core/settings.yml
      echo ":foreman_ssl_ca: /etc/foreman-proxy/foreman_ssl_ca.pem" >> /etc/smart_proxy_dynflow_core/settings.yml
      echo ":foreman_ssl_key: /etc/foreman-proxy/foreman_ssl_key.pem" >> /etc/smart_proxy_dynflow_core/settings.yml
      echo ":foreman_ssl_cert: /etc/foreman-proxy/foreman_ssl_cert.pem" >> /etc/smart_proxy_dynflow_core/settings.yml
      foreman-maintain service restart
      hammer proxy refresh-features --organization-id 1 --name "foreman.localdomain"
      hammer job-invocation create --organization-id 1 --job-template "Run Command - SSH Default"  --inputs command="uname -r" --search-query="foreman.localdomain"
    EOF

  end

end
