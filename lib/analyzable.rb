module Analyzable
  # Your code goes here!
	def average_price(products)
		average = products.map(&:price).map(&:to_f).reduce(:+)/products.length
		average.round(2)
	end

	def print_report(products)
		report = ""
		products.each do |product|
			report += "#{product.name}, brand: #{product.brand}, price: #{product.price} \n"
		end
		report
	end

	def create_count_by_methods(*attributes)
		attributes.each do |attr|
			self.class_eval %{def self.count_by_#{attr}(arg)
			counts = {} 
				Product.all.map(&:#{attr}).each do |#{attr}_value|
					counts[#{attr}_value] = Product.where(#{attr}: #{attr}_value).count 
				end
				counts
			end}
		end
	end

	def self.method_missing(method_name, arguments)
		if method_name.to_s.start_with?("count_by")
			attribute = method_name.to_s.gsub!("count_by_", "")
			create_count_by_methods(attribute)
			self.public_send(method_name, arguments)
		end
	end
end
