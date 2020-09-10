# lib/tasks/custom_seed.rake
namespace :migrate do
  desc "migrate user status"
  task user_status: :environment do

    users = User.all
    users.each{ |e|
      if e.first_name == "anonymous"
        e.update(status: 1)
      end
    }

  end
end
