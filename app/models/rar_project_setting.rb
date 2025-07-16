class RarProjectSetting < ActiveRecord::Base
  if Redmine::VERSION::MAJOR < 4 || (Redmine::VERSION::MAJOR == 4 && Redmine::VERSION::MINOR < 1)
    unloadable
  end

  if defined?(ProtectedAttributes) || ::ActiveRecord::VERSION::MAJOR < 4
    attr_accessible :project_id, :position, :show
  end
end
