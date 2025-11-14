namespace :multisite do
  desc "Create test data for multisite functionality"
  task create_test_data: :environment do
    puts "Creating test data for multisite functionality..."
    
    # Get all sites
    sites = Site.all
    
    sites.each do |site|
      puts "\nSetting up test data for #{site.name} (#{site.subdomain})..."
      
      # Create test articles for each site
      3.times do |i|
        article = Article.create!(
          title: "#{site.name} - Test Article #{i + 1}",
          description: "Test excerpt for #{site.name} article #{i + 1}",
          slug: "#{site.subdomain}-article-#{i + 1}",
          status: :publish,
          site: site,
          created_at: Time.current - i.days
        )
        # Add rich text content
        article.content = "<p>This is a test article for <strong>#{site.name}</strong>.</p><p>Site ID: #{site.id}, Subdomain: #{site.subdomain}</p>"
        article.save!
        puts "  Created article: #{article.title}"
      end
      
      # Create test pages for each site
      2.times do |i|
        page = Page.create!(
          title: "#{site.name} - Test Page #{i + 1}",
          content: "This is a test page for #{site.name}. Site ID: #{site.id}, Subdomain: #{site.subdomain}",
          slug: "#{site.subdomain}-page-#{i + 1}",
          page_order: i + 1,
          status: :publish,
          site: site
        )
        puts "  Created page: #{page.title}"
      end
      
      # Create site-specific settings
      setting = Setting.create!(
        site: site,
        title: "#{site.name} Blog",
        author: "#{site.name} Author",
        description: "This is the #{site.name} blog description",
        url: "https://#{site.subdomain}.example.com"
      )
      puts "  Created settings for #{site.name}"
    end
    
    puts "\n✅ Test data creation completed!"
    puts "\nYou can now test the multisite functionality:"
    puts "- Main site: http://www.localhost:3000/admin"
    puts "- Blog site: http://blog.localhost:3000/admin" 
    puts "- Tech site: http://tech.localhost:3000/admin"
    puts "\nOr switch between sites in the admin interface using the site selector."
  end
  
  desc "Clear all test data from multisite"
  task clear_test_data: :environment do
    puts "Clearing test data..."
    
    # Delete all articles, pages, and settings
    Article.destroy_all
    Page.destroy_all
    Setting.destroy_all
    
    puts "✅ All test data cleared!"
  end
end