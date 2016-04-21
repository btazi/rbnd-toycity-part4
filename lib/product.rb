require_relative 'udacidata'

class Product < Udacidata
  attr_reader :id, :price, :brand, :name

  def initialize(opts={})
    # Get last ID from the database if ID exists
    get_last_id
    # Set the ID if it was passed in, otherwise use last existing ID
    @id = opts[:id] ? opts[:id].to_i : @@count_class_instances
    # Increment ID by 1
    auto_increment if !opts[:id]
    # Set the brand, name, and price normally
    @brand = opts[:brand]
    @name = opts[:name]
    @price = opts[:price]
  end

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

	def self.first
		self.all.first
	end

	def exists?
		Product.all.any?{|product|  product.id == id && product.brand == brand && product.name == name && product.price.to_i == price}
	end

  private

    # Reads the last line of the data file, and gets the id if one exists
    # If it exists, increment and use this value
    # Otherwise, use 0 as starting ID number
    def get_last_id
      file = File.dirname(__FILE__) + "/../data/data.csv"
      last_id = File.exist?(file) ? CSV.read(file).last[0].to_i + 1 : nil
      @@count_class_instances = last_id || 0
    end

    def auto_increment
      @@count_class_instances += 1
    end

end
