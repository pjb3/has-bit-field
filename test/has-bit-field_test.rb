require File.join(File.dirname(__FILE__), 'test_helper')

require 'rubygems'
require 'activerecord'
require File.join(File.dirname(__FILE__), "../rails/init")

ActiveRecord::Base.establish_connection(
  :adapter => "sqlite3",
  :database  => ":memory:"
)

#ActiveRecord::Base.logger = Logger.new(STDOUT)

ActiveRecord::Base.connection.create_table(:people) do |t|
  t.integer :bit_field, :default => 0
end

class Person < ActiveRecord::Base
  extend HasBitField
  #attr_accessor :bit_field
  has_bit_field :bit_field, :likes_ice_cream, :plays_golf, :watches_tv, :reads_books
end

class HasBitFieldTest < Test::Unit::TestCase
  def test_bit_field
    p = Person.new
    [:likes_ice_cream, :plays_golf, :watches_tv, :reads_books].each do |f|
      assert p.respond_to?("#{f}?"), "Expected #{p.inspect} to respond to #{f}?"
      assert p.respond_to?("#{f}="), "Expected #{p.inspect} to respond to #{f}="
    end
    
    assert_equal Person.likes_ice_cream_bit, (1 << 0)
    assert_equal Person.plays_golf_bit, (1 << 1)
    assert_equal Person.watches_tv_bit, (1 << 2)
    assert_equal Person.reads_books_bit, (1 << 3)
    
    p.likes_ice_cream = true
    assert p.likes_ice_cream?
    assert !p.plays_golf?
    assert !p.watches_tv?
    assert !p.reads_books?

    p.likes_ice_cream = true
    assert p.likes_ice_cream?
    assert !p.plays_golf?
    assert !p.watches_tv?
    assert !p.reads_books?

    p.watches_tv = true
    assert p.likes_ice_cream
    assert !p.plays_golf
    assert p.watches_tv
    assert !p.reads_books

    p.watches_tv = false
    p.plays_golf = true
    assert p.likes_ice_cream?
    assert p.plays_golf?
    assert !p.watches_tv?
    assert !p.reads_books?

    p.watches_tv = "1"
    p.reads_books = "true"
    assert p.likes_ice_cream?
    assert p.plays_golf?
    assert p.watches_tv?
    assert p.reads_books?

    p.likes_ice_cream = nil
    p.plays_golf = 0
    p.watches_tv = "0"
    p.reads_books = "false"
    assert !p.likes_ice_cream?
    assert !p.plays_golf?
    assert !p.watches_tv?
    assert !p.reads_books?
  end

  def test_named_scopes
    Person.delete_all
    a = Person.new
    a.plays_golf = true
    a.reads_books = true
    assert a.save
    
    b = Person.new
    b.likes_ice_cream = true
    b.watches_tv = true
    assert b.save
    
    c = Person.create!

    assert_equal [b], Person.likes_ice_cream.all(:order => "id")    
    assert_equal [a,c], Person.not_likes_ice_cream.all(:order => "id")

    assert_equal [a], Person.plays_golf.all(:order => "id")
    assert_equal [b,c], Person.not_plays_golf.all(:order => "id")
    
    assert_equal [b], Person.watches_tv.all(:order => "id")
    assert_equal [a,c], Person.not_watches_tv.all(:order => "id")
    
    assert_equal [a], Person.reads_books.all(:order => "id")
    assert_equal [b,c], Person.not_reads_books.all(:order => "id")
  end
  def test_dirty_attributes
    Person.delete_all
    a = Person.new
    a.plays_golf = true
    a.reads_books = true
    assert a.save

    a.plays_golf = false
    assert_equal false, a.plays_golf
    assert_equal true, a.plays_golf_was
    assert a.plays_golf_changed?
    assert_equal true, a.reads_books
    assert_equal true, a.reads_books_was
    assert !a.reads_books_changed?
  end
end
