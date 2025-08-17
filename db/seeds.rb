# frozen_string_literal: true

User.destroy_all
Product.destroy_all

# Create default admin user
admin_username = ENV.fetch('ADMIN_USERNAME', 'admin')
admin_password = ENV.fetch('ADMIN_PASSWORD', 'password')

User.create!(username: admin_username, password: admin_password)

['First product', 'Second product'].each do |product_name|
  Product.create!(name: product_name)
end
