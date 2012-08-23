class CreateRequestEnvironmentRules < ActiveRecord::Migration
  def change
    create_table :request_environment_rules do |t|
      t.integer :redirect_rule_id, :null => false
      t.string :environment_key_name, :null => false
      t.string :environment_value, :null => false
      t.boolean :environment_value_is_regex, :null => false, :default => false
      t.boolean :environment_value_is_case_sensitive, :null => false, :default => true
      t.timestamps
    end
    add_index :request_environment_rules, :redirect_rule_id
  end
end