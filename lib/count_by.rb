class Module
	def create_count_by_methods(*attributes)
		attributes.each do |attr|
			self.class_eval("def self.count_by_#{attr}(arg); Product.all.select{|product| product.#{attr} == arg}.count ; end")
		end
	end
end
