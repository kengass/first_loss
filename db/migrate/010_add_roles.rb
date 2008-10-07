class AddRoles < ActiveRecord::Migration
  def self.up
    if !Role.find(:first, :conditions => 'rolename = shareholder')
      Role.create(rolename => 'shareholder')
    end
    if !Role.find(:first, :conditions => 'rolename = serparate_account')
      Role.create(rolename => 'serparate_account')
    end    
  end

  def self.down
  end
end
