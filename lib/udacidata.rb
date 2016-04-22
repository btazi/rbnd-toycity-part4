require_relative 'find_by'
require_relative 'errors'
require 'csv'

class Udacidata
  # Your code goes here!
	
	def self.create(attributes={})
		data_path = File.dirname(__FILE__) + "/../data/data.csv"
		attributes = {brand: attributes[:brand], name: attributes[:name], price: attributes[:price]}
		product = Product.new(attributes)
		#check if product already exists
		unless product.exists?
			CSV.open(data_path, "a+") do |csv|
				csv << [product.id, product.brand, product.name, product.price]
			end
		end
		product
	end

	def self.all
		data_path = File.dirname(__FILE__) + "/../data/data.csv"
		products = []
		CSV.foreach(data_path, headers: true).each do |row|
				product = Product.new(id: row["id"], brand: row["brand"], name: row["product"], price: row["price"])
				products << product
		end
		products
	end

	def self.destroy(id)
		# snipet from http://stackoverflow.com/questions/26707169/how-to-remove-a-row-from-a-csv-with-ruboy
		product = Product.find(id)
		data_path = File.dirname(__FILE__) + "/../data/data.csv"
		table = CSV.table(data_path)
		table.delete_if do |row|
			row[:id] == id
		end
		File.open(data_path, 'w') do |f|
			f.write(table.to_csv)
		end
		product
	end

	def self.first(n=1)
		n == 1 ? self.all.first : self.all.first(n)
	end

	def self.last(n=1)
		n == 1 ? self.all.last: self.all.last(n)
	end

	def self.find(id)
		Product.all.select{|product| product.id == id}[0]
	end

	def self.where(opts={})
		selected_objects = []
		opts.each do |k, v|
			selected_objects << self.all.select{|object| object.send(k) == v}
		end
		selected_objects.flatten!
		#fix for duplicate objects
		final_selection = []
		selected_objects.each do |obj|
			final_selection << obj unless final_selection.include?(obj)
		end
		final_selection
	end

	def update(opts={})
		# data_path = File.dirname(__FILE__) + "/../data/data.csv"
		#change the attributes to the new ones
		brand = opts[:brand] unless opts[:brand].nil?
		name = opts[:name] unless opts[:name].nil?
		price = opts[:price] unless opts[:price].nil?
		self.class.destroy(id)
		self.class.create(id: id, brand: brand, name: name, price: price)
	end

	def exists?
		Product.all.any?{|product|  product.id == id && product.brand == brand && product.name == name && product.price.to_i == price}
	end

	def self.method_missing(method_name, arguments)
		if method_name.to_s.start_with?("find_by_")
			#first get the attributes
			attribute = method_name.to_s.gsub!("find_by_", "")
			create_finder_methods(attribute)
			self.public_send(method_name, arguments)
		end
	end
end
