# frozen_string_literal: true

module UsersHelper
  # Render Devise forms outside of Devise views

  def resource_name
    :user
  end

  def resource
    @resource ||= current_user
  end

  def devise_mapping
    @devise_mapping ||= Devise.mappings[:user]
  end

  def resource_class
    User
  end
end
