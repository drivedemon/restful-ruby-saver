module Customer::CustomersHelper
  def fullname(first_name = "", last_name = "")
    "#{first_name} #{last_name}"
  end

  def total_amount_of_user(total_price = [])
    total_price.inject(0, :+)
  end
end
