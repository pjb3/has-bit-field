require File.join(File.dirname(__FILE__), 'test_helper')

class Person
  extend HasBitField
  attr_accessor :bit_field
  has_bit_field :bit_field, :likes_ice_cream, :plays_golf, :watches_tv, :reads_books
end

class HasBitFieldTest < Test::Unit::TestCase
  def test_bit_field
    p = Person.new
    [:likes_ice_cream, :plays_golf, :watches_tv, :reads_books].each do |f|
      assert p.respond_to?("#{f}?"), "Expected #{p.inspect} to respond to #{f}?"
      assert p.respond_to?("#{f}="), "Expected #{p.inspect} to respond to #{f}="
    end
    
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

end
