require 'faker'

1000.times do
  User.create(first_name: Faker::Name.first_name, last_name: Faker::Name.last_name)
end