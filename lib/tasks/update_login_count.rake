namespace :users do
  desc "Update login count for users where login_count is 0"
  task update_login_count: :environment do
    # 更新前の状態を確認
    users_to_update = User.where(login_count: 0)
    before_count = users_to_update.count
    
    # login_count が 0 のユーザーを更新
    updated_count = users_to_update.update_all(login_count: 1)
    
    puts "Found #{before_count} users with login_count = 0"
    puts "Updated login count for #{updated_count} users."
    puts "Current status:"
    puts "- Users with login_count = 0: #{User.where(login_count: 0).count}"
    puts "- Users with login_count = 1: #{User.where(login_count: 1).count}"
  end
end
  