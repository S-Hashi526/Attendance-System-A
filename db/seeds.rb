# coding: utf-8

User.create!(
  [
    {
      name: "管理者",
      email: "sample@email.com",
      employee_number: "0001",
      card_id: "0001",
      password: "password",
      password_confirmation: "password",
      admin: true
    },
    {
      name: "上長A",
      email: "superior-a@email.com",
      employee_number: "1001",
      card_id: "1001",
      password: "password",
      password_confirmation: "password",
      admin: false,
      superior: true
    },
    {
      name: "上長B",
      email: "superior-b@email.com",
      employee_number: "1002",
      card_id: "1002",
      password: "password",
      password_confirmation: "password",
      admin: false,
      superior: true
    },
  ]
)  
  
3.times do |n|
  name = Faker::Name.name
  email = "sample-#{n+1}@email.com"
  password = "password"
  User.create!(name: name,
               email: email,
               employee_number: n+1101,
               card_id: n+1101,
               password: password,
               password_confirmation: password,
               admin: false,
               superior: false
              )
end