# frozen_string_literal: true

class SubjectPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope.all
    end

    def resolve_admin
      @user.superadmin_role? ? scope.all : scope.joins(:groups).where('groups.id = ?', @user.group.id)
    end
  end

  def index?
    true
  end

  def show?
    true
  end

  def new?; end

  def edit?; end

  def create?
    superadmin?
  end

  def update?
    superadmin?
  end

  def destroy?
    superadmin?
  end

  private

  def superadmin?
    @user&.superadmin_role == true
  end
end
