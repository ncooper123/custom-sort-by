# CustomSortBy

This gem provides a class CustomSort that seeks to simulate SQL-style sorting for any type that responds to `sort_by`.

## Usage

Suppose:

```list = ["One","Two","Three","Four","Five","Six","Seven","Eight","Nine","Ten"]```

We perform a custom sort by telling CustomSortBy what properties/methods of each object will be used to perform the sort. For example, to sort by string length:

```
CustomSort.new(list,:size,:order => :desc).sort
=> ["Eight", "Seven", "Three", "Five", "Four", "Nine", "One", "Six", "Ten", "Two"] 
```

The search expression can be either a String/Symbol which will be invoked using `send`, or a lambda/Proc that specifies the mapping.

```
CustomSort.new(list,lambda{|d| d.size },:order => :asc).sort
=> ["One", "Six", "Ten", "Two", "Five", "Four", "Nine", "Eight", "Seven", "Three"] 
```

The mapping result should be sortable using `<=>`. Arbtirary number of tie-breakers can be specified using `then_by`:

```
vowels = lambda { |s| s.chars.select{|c| %w(a i o u y).include?(c) }.size }
CustomSort.new(list,:size).then_by(vowels,:order => :asc).sort
 => ["One", "Ten", "Six", "Two", "Five", "Nine", "Four", "Seven", "Three", "Eight"] 
```

When possible, any final ties are automatically broken using `<=>` on the elements themselves.

## Options

The final `options` hash parameter accepts the following settings:

`:order` as either `:asc` or `:desc`, specifying the search direction this criterion (default `:asc`).

`:nulls` as either `:first` or `:last`, specifying whether nil-mapped entries occur at the end or beginning (default `:first`).

Note that `:nulls` refers to null values in the criterion's map output, not the elements themselves. Nil entries in the original list must be handled manually.

## Additional Notes

You may wish to monkey-patch classes to make usage easier:

```
module Enumerable

	def custom_sort_by(criterion, order = :asc)
		CustomSort.new(self,criterion,order)
	end

end
```

Now we can just say:

```list.custom_sort_by(:size,:order => :desc).sort````

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

