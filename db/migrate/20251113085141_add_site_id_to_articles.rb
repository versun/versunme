class AddSiteId < ActiveRecord::Migration[8.1]
  def change
    add_reference :articles, :site, null: true, foreign_key: true
    add_index :articles, [:site_id, :slug], unique: true
    add_reference :sessions, :site, null: true, foreign_key: true
    add_reference :users, :site, null: true, foreign_key: true
    add_index :users, [:site_id, :user_name], unique: true
    add_reference :settings, :site, null: true, foreign_key: true
    add_reference :pages, :site, null: true, foreign_key: true
    add_index :pages, [:site_id, :slug], unique: true

    # 删除可能存在的索引，然后添加唯一索引
    remove_index :settings, :site_id if index_exists?(:settings, :site_id)
    add_index :settings, :site_id, unique: true

    # 为现有数据设置默认站点
    default_site = Site.first || Site.create!(name: "Default Site", subdomain: "www")
    Article.update_all(site_id: default_site.id)
    User.update_all(site_id: default_site.id)
    Session.update_all(site_id: default_site.id) if default_site
    Setting.update_all(site_id: default_site.id)
    Page.update_all(site_id: default_site.id)

    # 现在设置为not null
    change_column_null :articles, :site_id, false
    change_column_null :sessions, :site_id, false
    change_column_null :users, :site_id, false
    change_column_null :settings, :site_id, false
    change_column_null :pages, :site_id, false
  end
end
