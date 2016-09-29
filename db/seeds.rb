
User.create!( name:   "Admin",
              email:  "admin@example.com",
              password:               "password",
              password_confirmation:  "password",
              admin:      true,
              activated:  true,
              activated_at: Time.zone.now)

77.times do |n|
  name = Faker::Name.name
  email = "example-#{ n }@example.com"
  password = "password"
  User.create!(name:  name,
               email: email,
               password:               password,
               password_confirmation:  password,
               activated: true,
               activated_at: Time.zone.now)
end

users = User.order(:created_at).take(6)
36.times do
  content = Faker::Hacker.say_something_smart
  users.each { |user| user.microposts.create!(content: content) }
end
