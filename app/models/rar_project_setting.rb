# frozen_string_literal: true

# Model for storing README display settings per project
# Manages position and visibility preferences for README content
class RarProjectSetting < ActiveRecord::Base
  # Associations
  belongs_to :project

  # Validations
  validates :project_id, presence: true, uniqueness: true
  validates :position, inclusion: { in: [0, 1, 2] }
  validates :show, inclusion: {in: [0, 1] }
end
