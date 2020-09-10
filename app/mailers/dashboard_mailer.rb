class DashboardMailer < ApplicationMailer
  default from: 'no-reply@morphos.is'
 
  def welcome_email(user, password)
    @user = user
    @password = password
    mail(to: @user.email, subject: 'Welcome to Saver Dashboard')
  end
end