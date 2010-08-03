has-bit-field
=============

has-bit-field allows you to use one attribute of an object to store a bit field which stores the boolean state for multiple flags.

To use this with Active Record, you would first require this gem in `config/environment.rb`:

    config.gem "pjb3-has-bit-field", :lib => "has-bit-field", :source => "http://gems.github.com"

Now in one of your models, you define a bit field like this:

    class Person < ActiveRecord::Base
      has_bit_field :bit_field, :likes_ice_cream, :plays_golf, :watches_tv, :reads_books
    end

This means that your database will have an integer column called `bit_field` which will hold the actual bit field.  This will generate getter and setter methods for each of the fields.  It will also generate a method that has `_bit` as a suffix which will give you the decimal value of the bit that that field is represented by in the bit field.  Also there will be a named scope for that field, as well as a named scope prefixed with `not_`, if class you are adding the bit field to responds to `named_scope`.  You can use it like this:

    $ script/console 
    Loading development environment (Rails 2.3.2)
    p =>> p = Person.new
    => #<Person id: nil, bit_field: nil, created_at: nil, updated_at: nil>
    >> p.likes_ice_cream = "true"
    => "true"
    >> p.plays_golf = 1
    => 1
    >> p.save
    => true
    >> p = Person.find(p.id)
    => #<Person id: 1, bit_field: 3, created_at: "2009-07-18 03:04:06", updated_at: "2009-07-18 03:04:06">
    >> p.likes_ice_cream?
    => true
    >> p.reads_books?
    => false
    >> Person.plays_golf_bit
    => 4
    >> p = Person.likes_ice_cream.first
    => #<Person id: 1, bit_field: 3, created_at: "2009-07-18 03:04:06", updated_at: "2009-07-18 03:04:06">
    
One of the great advantages of this approach is that it is easy to add additional flags as your application evolves without the overhead of adding new table columns since a single integer will be able to store at least 31 boolean flags.  A simple amendment to the model will create the new flag on the existing integer column 'on-the-fly'.  However, the order of the flags is vitally important and you should only ever add new flags on the end.

    class Person < ActiveRecord::Base
      has_bit_field :bit_field, :likes_ice_cream, :plays_golf, :watches_tv, :reads_books, :nut_allergy
    end

The new flag will be evaluated as false for existing rows on the database table until their values are explicitly set.  Be careful with the peanuts!

Another gotcha to be aware of is when combining a bit field with Active Record's `validates_acceptance_of`.  When you call `validates_acceptance_of`, if there is no database column, Active Record will define an `attr_accessor` for that boolean field.  If you have already defined the bit field, this will clobber those methods.  Also, you need to set the value it's looking for to `true` instead of the default of `"1"`.  So here's an example of how to use it:

    class Person < ActiveRecord::Base
      validates_acceptance_of :read_books, :message => "You must agree to read", :accept => true
      has_bit_field :bit_field, :likes_ice_cream, :plays_golf, :watches_tv, :reads_books
    end
      
Copyright
---------

Copyright (c) 2009 Paul Barry. See LICENSE for details.
