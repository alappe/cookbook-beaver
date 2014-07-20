def whyrun_supported?
  true
end

action :delete do
  converge_by("Remove beaver conf.d entry for #{new_resource.name}") do
    file ::File.join(node['beaver']['config_path'], 'conf.d', new_resource.name) do
      action :delete
      notifies :restart, 'service[beaver]'
    end
  end
end

action :create do
  converge_by("Create beaver conf.d entry for #{new_resource.name}") do
    t = template ::File.join(node['beaver']['config_path'], 'conf.d', new_resource.name) do
      source 'beaver-tail.conf.erb'
      cookbook new_resource.cookbook
      user node['beaver']['user']
      group node['beaver']['group']
      mode '0644'
      variables(
        :name => new_resource.name,

        # convert hashes into [key-1, value-1, key-2, value-2, ...] arrays
        :add_field => new_resource.add_field.to_a.flatten,
        :add_field_env => new_resource.add_field_env.to_a.flatten,
        :exclude => new_resource.exclude,
        :format => new_resource.format,
        :path => [new_resource.path].flatten,
        :tags => new_resource.tags,
        :type => new_resource.type,
        :multiline_regex_before => new_resource.multiline_regex_before,
        :multiline_regex_after => new_resource.multiline_regex_after
      )
      action :create
      notifies :restart, 'service[beaver]'
    end
    new_resource.updated_by_last_action(t.updated_by_last_action?)
  end
end
