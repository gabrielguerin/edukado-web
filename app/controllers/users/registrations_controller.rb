# frozen_string_literal: true

module Users
  class RegistrationsController < Devise::RegistrationsController
    # Layout

    layout :determine_layout

    # Set layout based on action

    def determine_layout
      case action_name

      when 'edit'

        'scaffold'

      when 'new'

        'statics'

      end
    end

    # POST /resource

    def create
      # Needed for Merit

      @user = build_resource

      super
    end

    # PUT /resource

    def update
      # Needed for Merit

      @user = resource

      super
    end

    protected

    def update_resource(resource, params)
      # Require current password if user is trying to change password.

      return super if params['password']&.present?

      # Allows user to update registration information without password.

      resource.update_without_password(params.except('current_password'))
    end

    # before_action :configure_sign_up_params, only: [:create]

    # before_action :configure_account_update_params, only: [:update]

    # GET /resource/sign_up

    # def new

    #   super

    # end

    # GET /resource/edit

    # def edit

    #   super

    # end

    # DELETE /resource

    # def destroy

    #   super

    # end

    # GET /resource/cancel

    # Forces the session data which is usually expired after sign

    # in to be expired now. This is useful if the user wants to

    # cancel oauth signing in/up in the middle of the process,

    # removing all OAuth session data.

    # def cancel

    #   super

    # end

    # protected

    # If you have extra params to permit, append them to the sanitizer.

    # def configure_sign_up_params

    #   devise_parameter_sanitizer.permit(:sign_up, keys: [:attribute])

    # end

    # If you have extra params to permit, append them to the sanitizer.

    # def configure_account_update_params

    #   devise_parameter_sanitizer.permit(:account_update, keys: [:attribute])

    # end

    # The path used after sign up.

    # def after_sign_up_path_for(resource)

    #   super(resource)

    # end

    # The path used after sign up for inactive accounts.

    # def after_inactive_sign_up_path_for(resource)

    #   super(resource)

    # end

    before_action :resource_params, if: :devise_controller?

    def resource_params
      devise_parameter_sanitizer.permit(:sign_up) do |user|
        user.permit(
          :first_name,
          :last_name,
          :email,
          :gender,
          :description,
          :avatar,
          :password,
          :password_confirmation,
          :group_id,
          :terms_of_service
        )
      end

      devise_parameter_sanitizer.permit(:account_update) do |user|
        user.permit(
          :first_name,
          :last_name,
          :email,
          :gender,
          :description,
          :avatar,
          :password,
          :password_confirmation,
          :current_password,
          :group_id
        )
      end
    end
  end
end
