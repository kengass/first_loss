class Security < ActiveRecord::Base
  has_many :fldates, :dependent => :delete_all
  validates_uniqueness_of :cusip, :scope=> [:date,:fund]
  
  #before_destroy { |record| Fldates.destroy_all "security_id = #{record.id}" }
  

 end
