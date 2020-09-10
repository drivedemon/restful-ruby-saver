role_super_admin = Role.where(alias: "super_admin").first_or_create name: "Super Admin", alias: "super_admin"
role_admin = Role.where(alias: "admin").first_or_create name: "Admin", alias: "admin"
role_sales = Role.where(alias: "sales").first_or_create name: "Sales", alias: "sales"
region_no = Region.where(country_iso: "no").first_or_create country_iso: "no", timezone: "Europe/Oslo"
region_th = Region.where(country_iso: "th").first_or_create country_iso: "th", timezone: "Asia/Bangkok"

DashboardUser.create(
  email: 'test-user@mailinator.com', 
  password: '12341234', 
  username: 'testuser1', 
  role: role_super_admin,
  first_name: "test",
  last_name: "user",
  region: region_no
)