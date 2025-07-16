module ExtendProjectSetting
  module RarProjectSettingExtension

    def project_settings_tabs
      action = {
        :name => 'readme_at_repositories',
        :action => {:controller => 'rar_project_settings', :action => 'update'},
        :partial => 'rar_project_settings/show',
        :label => :label_project_setting_title
      }
      tabs = super
      #if User.current.allowed_to?(action, @project)
      tabs.push(action)
      #end
      return tabs
    end

  end
end


unless ProjectsHelper.included_modules.include?(::ExtendProjectSetting::RarProjectSettingExtension)
  ProjectsHelper.send(:prepend, ::ExtendProjectSetting::RarProjectSettingExtension)
end