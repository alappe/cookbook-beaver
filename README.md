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

* Debian

### Cookbooks

* python (to use the pip LWRP)

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
|<tt>['beaver']['configuration']</tt>|Hash|Key/Value [configuration pairs](https://github.com/josegonzalez/beaver#configuration-file-options)|<tt>{ 'respawn_delay' => 3, 'max_failure' => 7 }|
|<tt>['beaver']['files']</tt>|Array|Array containing hashes like `{ 'path' => '/var/log/syslog', 'type' => 'syslogs', 'tags' => 'sys, syslog' }` for files to watch|<tt>[]</tt>|

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

* Jeff Ramnani
* Andreas Lappe

License
-------

Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
