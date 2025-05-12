class IndexController < ApplicationController

  if Redmine::VERSION::MAJOR < 4 || (Redmine::VERSION::MAJOR == 4 && Redmine::VERSION::MINOR < 1)
    unloadable
  end

  def index
    @project = Project.find(params[:project_id])
  end
end
