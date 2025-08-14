# frozen_string_literal: true

# Controller for displaying README content at repository index
# Part of the readme_at_repositories plugin for Redmine
class IndexController < ApplicationController
  def index
    @project = Project.find(params[:project_id])
  end
end
