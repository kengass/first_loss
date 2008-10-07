class CreateSecurities < ActiveRecord::Migration
  def self.up
    create_table :securities do |t|
      t.string :cusip
      t.string :fund
      t.date :date
      t.string :title
      t.string :filename      
      t.string :moodys
      t.string :s_p
      t.string :fitch
      t.decimal :ce_orig, :precision => 8, :scale => 2
      t.decimal :ce_cur, :precision => 8, :scale => 2
      t.decimal :qtr_cdr, :precision => 8, :scale => 2
      t.decimal :qtr_severity, :precision => 8, :scale => 2
      t.string :forclosure_reo
      t.string :delinq_30_60_90     
      t.decimal :total_principal, :precision => 15, :scale => 2      

      t.timestamps
    end
  end

  def self.down
    drop_table :securities
  end
end
