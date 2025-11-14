class CreateSites < ActiveRecord::Migration[8.1]
  def change
    create_table :sites do |t|
      t.string :name, null: false
      t.string :subdomain, null: false
      t.text :description
      t.text :settings
      t.boolean :is_active, default: true, null: false
      t.string :default_theme, default: 'default'

      t.timestamps
    end

    add_index :sites, :subdomain, unique: true
    add_index :sites, :is_active
  end
end
