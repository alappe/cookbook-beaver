actions :create, :delete

default_action :create

attribute :name, :kind_of => String, :name_attribute => true
attribute :add_field, :kind_of => [Array, Hash], :default => []
attribute :add_field_env, :kind_of => [Array, Hash], :default => []
attribute :cookbook, :kind_of => String, :default => 'beaver'
attribute :exclude, :kind_of => [String, NilClass]
attribute :format, :kind_of => [String, NilClass], :default => node['beaver']['default_tail_format']
attribute :path, :kind_of => [String, Array], :required => true
attribute :tags, :kind_of => Array, :default => []
attribute :type, :kind_of => String, :default => 'file'
attribute :multiline_regex_after, :kind_of => [String, NilClass]
attribute :multiline_regex_before, :kind_of => [String, NilClass]
