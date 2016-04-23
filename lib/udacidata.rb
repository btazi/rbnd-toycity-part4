require_relative 'find_by'
require_relative 'errors'
require 'csv'

class Udacidata
  # Your code goes here!
	
	def self.create(attributes={})
		data_path = File.dirname(__FILE__) + "/../data/data.csv"
		attributes = {brand: attributes[:brand], name: attributes[:name], price: attributes[:price]}
		product = self.new(attributes)
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
		objects = []
		CSV.foreach(data_path, headers: true).each do |row|
				object = self.new(id: row["id"], brand: row["brand"], name: row["product"], price: row["price"])
				objects << object
		end
		objects
	end

	def self.destroy(id)
		# snipet from http://stackoverflow.com/questions/26707169/how-to-remove-a-row-from-a-csv-with-ruboy
		raise ProductNotFound, "There is no product with id: #{id}" if id > self.all.length
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
		raise ProductNotFound, "There is no product with id: #{id}" if id > Product.all.length
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
		#change the attributes to the new ones
		values = self.instance_values
		self.class.destroy(id)
		new_values = {} 
		values.each do |key, value|
			new_values[key.to_sym] = opts.include?(key.to_sym) ? opts[key.to_sym] : value
		end
		self.class.create(new_values)
	end

	def instance_values # from http://apidock.com/rails/v4.2.1/Object/instance_values
		    Hash[instance_variables.map { |name| [name[1..-1], instance_variable_get(name)] }]
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
