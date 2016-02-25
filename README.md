beaver Cookbook
===============

Install [beaver](https://github.com/josegonzalez/beaver) - the python daemon that munches on logs and sends their
contents to logstash.

Requirements
------------

### Ohai and Chef:

This cookbook makes use of `node['platform_family']` to simplify
platform selection logic. This attribute was introduced in Ohai v0.6.12.

### Platform:

The following platform families are supported:

* Debian derivatives (Debian, Ubuntu, etc)
* RHEL derivatives (RHEL, CentOS, etc)

### Cookbooks

* poise-python (to use the python_package LWRP)

Attributes
----------

### beaver::default
|Key|Type|Description|Default|
|---|----|-----------|-------|
|<tt>['beaver']['version']</tt>|String|Version to install via pip|<tt>29</tt>|
|<tt>['beaver']['log_path']</tt>|String|Log path|<tt>/var/log</tt>|
|<tt>['beaver']['log_file']</tt>|String|Log file|<tt>beaver.log</tt>|
|<tt>['beaver']['generate_keypair']</tt>|Boolean|Whether to generate and expose keypair or not|<tt>false</tt>|
|<tt>['beaver']['ssh_key_file']</tt>|String|Basename of the keyfiles to generate|<tt>logger</tt>|
|<tt>['beaver']['config_path']</tt>|String|Configuration path|<tt>/etc/beaver</tt>|
|<tt>['beaver']['config_file']</tt>|String|Configuration file|<tt>beaver.conf</tt>|
|<tt>['beaver']['user']</tt>|String|User to run service as|<tt>root</tt>|
|<tt>['beaver']['group']</tt>|String|Group to run service as|<tt>root</tt>|
|<tt>['beaver']['configuration']</tt>|Hash|Key/Value [configuration pairs](https://github.com/josegonzalez/beaver#configuration-file-options)|<tt>{ 'respawn_delay' => 3, 'max_failure' => 7 }|
|<tt>['beaver']['files']</tt>|Array|Array containing hashes like `{ 'path' => '/var/log/syslog', 'type' => 'syslogs', 'tags' => 'sys, syslog' }` for files to watch|<tt>[]</tt>|
|<tt>['beaver']['input_type']['tcp/ampq/etc']</tt>|Hash|Key/Value [input_types](http://beaver.readthedocs.org/en/latest/search.html?q=type&check_keywords=yes&area=default)|
|<tt>['beaver']['output']</tt>|Hash|Key/Value|
|<tt>['poise-python']['beaver']['provider']</tt>|String|Python provider to install with. See poise-python for details.|<tt>system</tt>|
|<tt>['poise-python']['beaver']['version']</tt>|String|Python version to install. Blank means any. Beaver only supports 2 as of v36.|<tt>'2'</tt>|

Resources/Providers
-------------------

### Managing log files

This cookbook includes an LWRP for managing log files consumed by Beaver. It
does so by dropping configuration snippets for each log file into Beaver's conf.d
directory.

#### Actions

- :create: Creates a config file and restarts Beaver to load it. (This is the default action)
- :delete: Removes the config file.

#### Parameters

|Parameter|Type|Description|Default|
|---------|----|-----------|-------|
|<tt>name</tt>|String|Should be a name for the log file. e.g. 'syslog'|<tt></tt>|
|<tt>path</tt>|String|The path to the log file being monitored. (Required)|<tt></tt>|
|<tt>cookbook</tt>|String|Which cookbook contains the config file template, `beaver-tail.conf.erb`.|<tt>beaver</tt>|
|<tt>format</tt>|String|What Logstash format should be used to send the log data.|<tt>json\_event</tt>|
|<tt>type</tt>|String|What Logstash type to associate with the log data.|<tt>file</tt>|
|<tt>tags</tt>|Array|The Logstash tags to associate with the log data as an array of strings.|<tt>[]</tt>|
|<tt>add\_field</tt>|Array|The Logstash field(s) to associate with the log data. An array of strings in the form ['fieldname1', 'fieldvalue1'].|<tt>[]</tt>|
|<tt>exclude</tt>|String|Which log files to exclude. Useful if using a file glob in the `path` parameter. The value must be a valid Python regex string. |<tt></tt>|


#### Examples

    # Monitor /var/log/syslog
    beaver_tail "syslog" do
      path "/var/log/syslog"
      type "syslog"
      format "json_event"
    end

    # Follow all logs in /var/log except those with `messages` or `secure` in the name.
    beaver_tail "system logs" do
      path "/var/log/*log"
      type "syslog"
      tags: ["sys"]
      exclude "(messages|secure)"
    end

    # Stop monitoring syslog
    beaver_tail "syslog" do
      action :delete
    end

Usage
-----
#### beaver::default

Just include `beaver` in your node's `run_list`:

```json
{
  "name":"my_node",
  "run_list": [
    "recipe[beaver]"
  ]
}
```

And configure beaver either in role or on the node. If you set
`['beaver']['ssh']['generate_keypair']` to true the cokbook will create
a public-key pair in the `config_path` and will expose the public key on
the node. This key can then be searched by e.g. the logstash host and
grant password-free access to tunnel e.g. redis (or anything else)
through it.

#### Configuration example (role)

```json
{
  "name": "logstash-client",
  "description": "",
  "json_class": "Chef::Role",
  "chef_type": "role",
  "default_attributes": {
    "beaver": {
      "generate_keypair": true,
      "configuration": {
        "transport": "redis",
        "redis_url": "redis://localhost:6379/0",
        "redis_namespace": "logstash:beaver",
        "ssh_key_file": "remote_key",
        "ssh_tunnel": "logging@logs.example.net",
        "ssh_tunnel_port": 6379,
        "ssh_remote_host": "127.0.0.1",
        "ssh_remote_port": "6379"
      }
    }
  },
  "run_list": [
    "recipe[beaver]"
  ],
}
```

#### Input Type Configuration (Hash)
```
  node.set['beaver']['input_type']['amqp'] = {
  'name' => "logstash_queue",
  'type' => "direct",
  'host' => "10.0.0.1",
  'exchange' => "logstash-exchange",
  'key' => "logstash-key",
  'exclusive' => false,
  'durable' => false,
  'auto_delete' => false,
}
```

#### Output Type Configuration (Hash)
```
node.set['beaver']['output'] = {
    'output' => 'stdout { debug => true }'
}
```

Contributing
------------
1. Fork the repository on Github
2. Create a named feature branch (like `add_component_x`)
3. Write you change
4. Write tests for your change (if applicable)
5. Run the tests, ensuring they all pass
6. Submit a Pull Request using Github

Authors
-------

* Anthony Caiafa
* [Eugene Migolinets](https://github.com/rampire)
* [James Le Cuirot](https://github.com/chewi)
* [Pavel Yudin](https://github.com/kasen)
* [Daryl Robbins](https://github.com/darylrobbins)
* [rampire](https://github.com/rampire)
* [Tim Smith](https://github.com/tas50)
* [Mirko Kiefer](https://github.com/mirkokiefer)
* [Josh Pasqualetto](https://github.com/sniperd)
* [Jeff Ramnani](https://github.com/jramnani)
* [Andreas Lappe](https://github.com/alappe)

License
-------

Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
