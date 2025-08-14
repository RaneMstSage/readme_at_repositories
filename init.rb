# frozen_string_literal: true
require 'redmine'

Redmine::Plugin.register :readme_at_repositories do
  name 'Readme At Repositories plugin'
  author 'Tsubasa Nagasawa (original), Kenneth Schuetz (Redmine 6.0+ compatibility)'
  description 'Display "README" at repository tab'
  version '0.4.0'
  url 'https://github.com/RaneMstSage/readme_at_repositories'
  author_url 'https://github.com/RaneMstSage'

  project_module :readme_at_repository do
    permission :manage, :rar_project_settings => [:update], :require => :member
  end
end

Rails.application.config.to_prepare do
  require_dependency 'display_readme'
  require_dependency 'extend_project_setting'
end
