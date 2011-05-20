require File.join(File.dirname(__FILE__), 'test_helper')

ActiveRecord::Base.establish_connection(
  :adapter => "sqlite3",
  :database  => ":memory:"
)

#ActiveRecord::Base.logger = Logger.new(STDOUT)

ActiveRecord::Base.connection.create_table(:people) do |t|
  t.integer :bit_field, :null => true
end

class Person < ActiveRecord::Base
  extend HasBitField

  has_bit_field :bit_field, :likes_ice_cream, :plays_golf, :watches_tv, :reads_books
end


ActiveRecord::Base.connection.create_table(:skills) do |t|
  t.integer :outdoor_bit_field, :default => 0, :null => false
  t.integer :indoor_bit_field, :default => 0, :null => false
end

class Skill < ActiveRecord::Base
  extend HasBitField

  validates_acceptance_of :chops_trees, :message => "You have to be a lumberjack", :accept => true
  validates_acceptance_of :plays_piano, :message => "You must be a pianist", :accept => true

  has_bit_field :outdoor_bit_field, :chops_trees, :builds_fences, :cuts_hedges
  has_bit_field :indoor_bit_field, :plays_piano, :mops_floors, :makes_soup
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

  def test_named_scopes_on_nullable_column
    Person.delete_all
    a = Person.new
    a.plays_golf = true
    a.reads_books = true
    assert a.save

    b = Person.new
    b.likes_ice_cream = true
    b.watches_tv = true
    assert b.save

    c = Person.create! :bit_field => 0

    assert_equal [b], Person.likes_ice_cream.all(:order => "id")
    assert_equal [a,c], Person.not_likes_ice_cream.all(:order => "id")

    assert_equal [a], Person.plays_golf.all(:order => "id")
    assert_equal [b,c], Person.not_plays_golf.all(:order => "id")

    assert_equal [b], Person.watches_tv.all(:order => "id")
    assert_equal [a,c], Person.not_watches_tv.all(:order => "id")

    assert_equal [a], Person.reads_books.all(:order => "id")
    assert_equal [b,c], Person.not_reads_books.all(:order => "id")
  end

  def test_named_scopes_on_non_nullable_column
    Skill.delete_all
    a = Skill.new
    a.plays_piano = true
    a.chops_trees = true
    a.mops_floors = true
    assert a.save, a.errors.full_messages.join(", ")

    b = Skill.new
    b.plays_piano = true
    b.chops_trees = true
    b.makes_soup = true
    assert b.save, b.errors.full_messages.join(", ")

    c = Skill.create! :plays_piano => true, :chops_trees => true

    assert_equal [a,b,c], Skill.plays_piano.all(:order => "id")
    assert_equal [], Skill.not_plays_piano.all(:order => "id")

    assert_equal [a], Skill.mops_floors.all(:order => "id")
    assert_equal [b,c], Skill.not_mops_floors.all(:order => "id")

    assert_equal [b], Skill.makes_soup.all(:order => "id")
    assert_equal [a,c], Skill.not_makes_soup.all(:order => "id")
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

  def test_ar_validations_no_default
    s = Skill.new(:plays_piano => true, :builds_fences => true, :cuts_hedges => false)

    assert_equal false, s.chops_trees?
    assert_equal false, s.chops_trees
    assert s.builds_fences?
    assert !s.cuts_hedges?
    assert !s.cuts_hedges

    assert !s.valid?
    assert s.errors[:chops_trees]

    s.chops_trees = false
    assert !s.chops_trees?
    assert !s.valid?
    assert s.errors[:chops_trees]

    s.chops_trees = true
    assert s.chops_trees?
    assert s.valid?
    assert s.errors[:chops_trees].blank?
    assert s.save
  end

  def test_ar_validations_with_default
    s = Skill.new(:chops_trees => true, :mops_floors => true, :makes_soup => false)

    assert_equal false, s.plays_piano?
    assert_equal false, s.plays_piano
    assert s.mops_floors?
    assert !s.makes_soup?
    assert !s.makes_soup

    assert !s.valid?
    assert s.errors[:plays_piano]

    s.plays_piano = false
    assert !s.plays_piano?
    assert !s.valid?
    assert s.errors[:plays_piano]

    s.plays_piano = true
    assert s.plays_piano?
    assert s.valid?
    assert s.errors[:plays_piano].blank?
    assert s.save
  end

end
