actions :create, :delete

default_action :create

attribute :name, :kind_of => String, :name_attribute => true
attribute :add_field, :kind_of => Array, :default => []
attribute :cookbook, :kind_of => String, :default => "beaver"
attribute :exclude, :kind_of => String
attribute :format, :kind_of => String, :default => "json_event"
attribute :path, :kind_of => String, :required => true
attribute :tags, :kind_of => Array, :default => []
attribute :type, :kind_of => String, :default => "file"
