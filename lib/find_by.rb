class Module
	def create_finder_methods(*attributes)
		# # Your code goes here!
		# # Hint: Remember attr_reader and class_eval
		attributes.each do |attr|
			self.class_eval("def self.find_by_#{attr}(arg); Product.all.select{|product| product.#{attr} == arg}[0] ; end")
		end
	end 
end
