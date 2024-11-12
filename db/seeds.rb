admin_user = User.find_or_initialize_by(email: ENV['ADMIN_EMAIL'])
if admin_user.new_record?
  admin_user.assign_attributes(
    name: ENV['ADMIN_USERNAME'],
    password: ENV['ADMIN_PASSWORD'],
    password_confirmation: ENV['ADMIN_PASSWORD_CONFIRMATION'],
    role: ENV['ADMIN_ROLE']
  )
  if admin_user.save
    puts "Admin user created successfully"
  else
    puts "Failed to create admin user: #{admin_user.errors.full_messages.join(', ')}"
  end
else
  puts "Admin user already exists"
end
