
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
