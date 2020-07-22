module RequestSpecHelper
  def login_user(user = nil)
    @controller.instance_variable_set(:@current_user, user)
  end

  def logout_user
    @controller.instance_variable_set(:@current_user, nil)
  end
end
