# frozen_string_literal: true

# Routes for README at repositories plugin
Rails.application.routes.draw do
  post 'rar_project_settings/update(/:id(/:tab))', to: 'rar_project_settings#update'
end
