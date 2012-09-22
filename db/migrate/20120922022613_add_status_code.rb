class AddStatusCode < ActiveRecord::Migration
  def up
    change_table :redirect_rules do |t|
      t.integer :status_code, :default => 301
    end
  end

  def down
    remove_column :redirect_rules, :status_code
  end
end
