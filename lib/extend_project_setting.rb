# frozen_string_literal: true

# Module to extend ProjectsHelper with README at repositories settings tab
# Adds the plugin configuration tab to project settings
module ExtendProjectSetting
  # Extension module for adding README settings tab to project configuration
  module RarProjectSettingExtension
    def project_settings_tabs
      action = {
        name: 'readme_at_repositories',
        action: { controller: 'rar_project_settings', action: 'update' },
        partial: 'rar_project_settings/show',
        label: :label_project_setting_title
      }
      tabs = super
      tabs.push(action)
      tabs
    end
  end
end

# Include the extension in ProjectsHelper if not already included
unless ProjectsHelper.included_modules.include?(::ExtendProjectSetting::RarProjectSettingExtension)
  ProjectsHelper.prepend ::ExtendProjectSetting::RarProjectSettingExtension
end
