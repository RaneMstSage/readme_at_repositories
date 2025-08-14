# frozen_string_literal: true

# Migration to create project settings table for README display preferences
class CreateRarProjectSettings < ActiveRecord::Migration[7.2]
  def change
    create_table :rar_project_settings do |t|
      t.integer :project_id, null: false
      t.integer :position, default: 0, null: false
      t.integer :show, default: 1, null: false

      t.timestamps null: false
    end

    add_index :rar_project_settings, :project_id, unique: true
    add_foreign_key :rar_project_settings, :projects
  end
end
