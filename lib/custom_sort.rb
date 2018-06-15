class CustomSort

	def initialize(list, expression, options = {})
		@list = list
		check_expression(expression)
		@criteria = [{:expression => expression, :options => make_options(options)}]
		@terminated = false
	end

	def then_by(expression, options = {})
		check_not_terminated
		check_expression(expression)
		@criteria << {:expression => expression, :options => make_options(options)}
		self
	end

	def sort
		check_not_terminated
		@terminated = true
		@list.sort { |a,b| custom_compare(a,b) }
	end

	def sort!
		check_not_terminated
		@terminated = true
		@list.sort! { |a,b| custom_compare(a,b) }
	end

	private

	# Performs comparison of two objects using all given criteria.
	def custom_compare(a, b)
		@criteria.each do |criterion|
			comparison = apply_criterion(criterion,a,b)
			return comparison unless comparison.zero?
		end
		# None of the criteria resulted in non-zero. Attempt default comparison.
		begin
			tie_breaker = { :expression => :itself, :options => make_options({}) }
			return apply_criterion(tie_breaker,a,b)
		rescue
			return 0
		end
	end

	# Applies a single criterion {expression,options} hash to two objects.
	def apply_criterion(criterion, a, b)
		ascending = criterion[:options][:order] == :asc
		nulls_first = criterion[:options][:nulls] == :first
		left = apply_map(a,criterion[:expression]); right = apply_map(b,criterion[:expression])
		if left.nil? && !right.nil?
			nulls_first ? -1 : 1
		elsif !left.nil? && right.nil?
			nulls_first ? 1 : -1
		elsif !(left.nil? || right.nil?)
			if left < right
				ascending ? -1 : 1
			elsif left > right
				ascending ? 1 : -1
			else
				0
			end
		else
			0 # Both are nil
		end
	end

	# Return a complete options hash from the user options.
	def make_options(options)
		result = {
			:order => :asc,
			:nulls => :first
		}.merge(options)
		raise 'Invalid order given.' unless [:asc,:desc].include?(result[:order])
		raise 'Invalid null order given.' unless [:first,:last].include?(result[:nulls])
		raise 'Unrecognized options given.' unless result.size == 2
		result
	end

	# Attempt to apply the given expression to the object.
	def apply_map(object, expression)
		if expression.is_a?(Symbol) || expression.is_a?(String)
			if object.respond_to?(expression)
				return object.send(expression)
			end
		elsif expression.is_a?(Proc) && expression.arity == 1
			return expression.call(object)
		end
		raise StandardError, "Cannot apply criterion expression #{expression.to_s} to #{object.to_s}."
	end

	# Validates user expression
	def check_expression(expression)
		raise 'Expression cannot be nil.' if expression.nil?
	end

	def check_not_terminated
		raise "CustomSort is already completed." if @terminated
	end

end