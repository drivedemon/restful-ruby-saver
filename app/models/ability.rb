# frozen_string_literal: true

class Ability
  include CanCan::Ability

  def initialize(dashboard_user)
    if dashboard_user.present?
      #homepage
      can :read, :homepage
      #customer
      can :read, :customer
      can :request_history, :customer
      can :offer_history, :customer
      can :spending_history, :customer
      can :earning_history, :customer
      can :export_csv, :customer
      can :export_csv_information, :customer
      #dashboard_user
      can :read, :dashboard_user
      #earning_history
      can :read, :earning_history
      can :export_csv, :earning_history
      #spending_history
      can :read, :spending_history
      can :export_csv, :spending_history
      #request
      can :read, :request
      can :export_csv, :request
      #request_by_location
      can :read, :requests_by_location
      can :export_csv, :requests_by_location
      #report
      can :read, :report
      can :export_csv, :report
      can :export_csv_information, :report

      #admin
      if dashboard_user.admin?
        can :manage, :all

        cannot :destroy, :dashboard_user
        cannot :edit, :dashboard_user
        cannot :create, :dashboard_user
      end

      #super_admin
      if dashboard_user.super_admin?
        can :manage, :all
      end
    end
  end
end
