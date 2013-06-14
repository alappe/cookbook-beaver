def whyrun_supported?
  true
end

action :delete do
  converge_by("Remove beaver conf.d entry for #{new_resource.name}") do
    file ::File.join(node['beaver']['config_path'], "conf.d", new_resource.name) do
      action :delete
      notifies :restart, "service[beaver]"
    end
  end
end

action :create do
  converge_by("Create beaver conf.d entry for #{new_resource.name}") do
    t = template ::File.join(node['beaver']['config_path'], "conf.d", new_resource.name) do
      source "beaver-tail.conf.erb"
      cookbook new_resource.cookbook
      mode "0644"
      variables({
        :name => new_resource.name,
        :add_field => new_resource.add_field.join(","),
        :exclude => new_resource.exclude,
        :format => new_resource.format,
        :path => new_resource.path,
        :tags => new_resource.tags.join(","),
        :type => new_resource.type
      })
      action :create
      notifies :restart, "service[beaver]"
    end
    new_resource.updated_by_last_action(t.updated_by_last_action?)
  end
end
