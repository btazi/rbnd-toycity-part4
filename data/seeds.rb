require 'faker'

# This file contains code that populates the database with
# fake data for testing purposes

def db_seed
	20.times do
		Product.create(brand: "#{Faker::Company.name} #{Faker::Company.suffix}", name: Faker::Commerce.product_name, price: rand(5.1...99.9))
	end
end
