name             'beaver'
maintainer       'kaeufli.ch'
maintainer_email 'nd@kaeufli.ch'
license          'Apache 2.0'
description      'Installs/Configures beaver'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '1.1.0'
recipe           'beaver', 'Installs and configures beaver to ship logs to logstash'
%w{ python }.each do |cookbook|
  depends cookbook
end

%w{ ubuntu }.each do |os|
  supports os
end
