#
# Schema needed to test validatious_on_rails.
#
ActiveRecord::Schema.define :version => 0 do
  #
  # Just a stupid table that adds columns that can be validated with
  # a wide variety of validators.
  #
  create_table :bogus_items, :force => true do |t|
    t.string :url
    t.string :name
    t.string :email
    t.string :num
    t.string :num2
    t.string :num3
  end
end
