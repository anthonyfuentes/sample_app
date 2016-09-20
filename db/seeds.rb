
User.create!( name:   "Admin",
              email:  "admin@example.com",
              password:               "password",
              password_confirmation:  "password",
              admin: true)

77.times do |n|
  name = Faker::Name.name
  email = "example-#{ n }@example.com"
  password = "password"
  User.create!(name:  name,
               email: email,
               password:               password,
               password_confirmation:  password)
end
