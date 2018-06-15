# CustomSortBy

This gem provides a class CustomSort that seeks to simulate SQL-style sorting for any type that responds to `sort_by`.

## Usage

Suppose:

`list = ["One","Two","Three","Four","Five","Six","Seven","Eight","Nine","Ten"]`

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

## Options


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

