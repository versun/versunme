class RenameSettingsToSiteConfigInSites < ActiveRecord::Migration[8.1]
  def change
    rename_column :sites, :settings, :site_config
  end
end
