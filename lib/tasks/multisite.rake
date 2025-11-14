namespace :multisite do
  desc "Setup default site and migrate existing data"
  task setup: :environment do
    puts "Setting up multi-site functionality..."
    puts "=" * 50
    
    # 创建默认站点
    default_site = Site.find_by(subdomain: "www")
    if default_site.nil?
      default_site = Site.create!(
        name: "Main Site",
        subdomain: "www",
        description: "Main website",
        is_active: true
      )
      puts "✅ Created default site: #{default_site.name}"
    else
      puts "ℹ️  Default site already exists: #{default_site.name}"
    end
    
    # 迁移现有数据到默认站点
    migrate_data_to_site(default_site)
    
    puts "\n" + "=" * 50
    puts "Multi-site setup completed!"
    puts "\nSummary:"
    puts "  Default site: #{default_site.name} (#{default_site.subdomain})"
    puts "  Articles: #{default_site.articles.count}"
    puts "  Pages: #{default_site.pages.count}"
    puts "  Settings: #{default_site.site_settings.count}"
    puts "  Users: #{default_site.users.count}"
    puts "  Sessions: #{default_site.sessions.count}"
  end
  
  desc "Create a new site"
  task :create_site, [:name, :subdomain] => :environment do |t, args|
    name = args[:name]
    subdomain = args[:subdomain]
    
    if name.blank? || subdomain.blank?
      puts "❌ Usage: rake multisite:create_site['Site Name','subdomain']"
      exit 1
    end
    
    site = Site.create!(
      name: name,
      subdomain: subdomain,
      description: "#{name} website",
      is_active: true
    )
    
    puts "✅ Created new site: #{site.name} (#{site.subdomain})"
    puts "Site ID: #{site.id}"
  end
  
  desc "List all sites and their data"
  task status: :environment do
    puts "Multi-site Status Report"
    puts "=" * 60
    
    Site.all.each do |site|
      puts "\n#{site.name} (#{site.subdomain})"
      puts "  ID: #{site.id}"
      puts "  Active: #{site.is_active ? 'Yes' : 'No'}"
      puts "  Articles: #{site.articles.count}"
      puts "  Pages: #{site.pages.count}"
      puts "  Settings: #{site.site_settings.count}"
      puts "  Users: #{site.users.count}"
      puts "  Sessions: #{site.sessions.count}"
      
      if site.site_config.present?
        puts "  Config keys: #{site.site_config.keys.join(', ')}"
      end
    end
    
    puts "\n" + "=" * 60
    puts "Total Sites: #{Site.count}"
    puts "Active Sites: #{Site.active.count}"
  end
  
  desc "Migrate data from one site to another"
  task :migrate_data, [:from_site_id, :to_site_id] => :environment do |t, args|
    from_site_id = args[:from_site_id]
    to_site_id = args[:to_site_id]
    
    if from_site_id.blank? || to_site_id.blank?
      puts "❌ Usage: rake multisite:migrate_data[1,2]"
      exit 1
    end
    
    from_site = Site.find(from_site_id)
    to_site = Site.find(to_site_id)
    
    puts "Migrating data from #{from_site.name} to #{to_site.name}..."
    
    migrate_data_to_site(from_site, to_site)
    
    puts "✅ Data migration completed!"
  end
  
  desc "Clean up orphaned data"
  task cleanup: :environment do
    puts "Cleaning up orphaned data..."
    
    # 清理没有site_id的数据
    orphaned_articles = Article.unscope(:where).where(site_id: nil)
    orphaned_pages = Page.unscope(:where).where(site_id: nil)
    orphaned_settings = Setting.unscope(:where).where(site_id: nil)
    orphaned_users = User.unscope(:where).where(site_id: nil)
    orphaned_sessions = Session.unscope(:where).where(site_id: nil)
    
    puts "Orphaned data found:"
    puts "  Articles: #{orphaned_articles.count}"
    puts "  Pages: #{orphaned_pages.count}"
    puts "  Settings: #{orphaned_settings.count}"
    puts "  Users: #{orphaned_users.count}"
    puts "  Sessions: #{orphaned_sessions.count}"
    
    if orphaned_articles.count > 0 || orphaned_pages.count > 0
      puts "\nAssigning orphaned data to default site..."
      default_site = Site.find_by(subdomain: "www") || Site.first
      
      orphaned_articles.update_all(site_id: default_site.id)
      orphaned_pages.update_all(site_id: default_site.id)
      orphaned_settings.update_all(site_id: default_site.id)
      orphaned_users.update_all(site_id: default_site.id)
      orphaned_sessions.update_all(site_id: default_site.id)
      
      puts "✅ Orphaned data assigned to #{default_site.name}"
    else
      puts "✅ No orphaned data found"
    end
  end
  
  private
  
  def migrate_data_to_site(target_site, source_site = nil)
    if source_site
      # 从指定站点迁移数据
      migrate_site_data(source_site, target_site)
    else
      # 迁移所有无站点数据到目标站点
      migrate_orphaned_data(target_site)
    end
  end
  
  def migrate_site_data(source_site, target_site)
    puts "Migrating data from #{source_site.name} to #{target_site.name}..."
    
    # 迁移文章
    article_count = source_site.articles.update_all(site_id: target_site.id)
    puts "  Migrated #{article_count} articles"
    
    # 迁移页面
    page_count = source_site.pages.update_all(site_id: target_site.id)
    puts "  Migrated #{page_count} pages"
    
    # 迁移设置（如果有的话）
    if source_site.site_settings.any?
      setting_count = source_site.site_settings.update_all(site_id: target_site.id)
      puts "  Migrated #{setting_count} settings"
    end
    
    # 迁移用户
    user_count = source_site.users.update_all(site_id: target_site.id)
    puts "  Migrated #{user_count} users"
    
    # 迁移会话
    session_count = source_site.sessions.update_all(site_id: target_site.id)
    puts "  Migrated #{session_count} sessions"
  end
  
  def migrate_orphaned_data(target_site)
    puts "Migrating orphaned data to #{target_site.name}..."
    
    # 查找并迁移无site_id的数据
    orphaned_articles = Article.unscope(:where).where(site_id: nil).update_all(site_id: target_site.id)
    orphaned_pages = Page.unscope(:where).where(site_id: nil).update_all(site_id: target_site.id)
    orphaned_settings = Setting.unscope(:where).where(site_id: nil).update_all(site_id: target_site.id)
    orphaned_users = User.unscope(:where).where(site_id: nil).update_all(site_id: target_site.id)
    orphaned_sessions = Session.unscope(:where).where(site_id: nil).update_all(site_id: target_site.id)
    
    puts "  Migrated #{orphaned_articles} orphaned articles"
    puts "  Migrated #{orphaned_pages} orphaned pages"
    puts "  Migrated #{orphaned_settings} orphaned settings"
    puts "  Migrated #{orphaned_users} orphaned users"
    puts "  Migrated #{orphaned_sessions} orphaned sessions"
  end
end