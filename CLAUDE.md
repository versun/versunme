# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

VersunCMS is a Ruby on Rails 8.1.1 content management system designed for personal websites with advanced multisite functionality. It supports subdomain-based sites where each site can have its own content while sharing authentication and core infrastructure.

## Essential Commands

### Development
```bash
# Start development server
bin/rails server

# Run code linting
bin/rubocop -A

# Database operations
bin/rails db:prepare
bin/rails db:migrate
bin/rails db:seed

# Run tests
bin/rails test
bin/rails test test/models/article_test.rb  # Run specific test file
```

### Deployment
```bash
# Docker build
docker build -t versuncms .

# Multisite development environment
docker-compose -f docker-compose.multisite.yml up

# Kamal deployment
bin/kamal deploy -c config/deploy.yml
bin/kamal deploy -c config/deploy_multisite.yml  # For multisite setup
```

## Architecture Overview

### Multisite System
The application uses a subdomain-based multisite architecture where:
- Each site runs on its own subdomain (e.g., `blog.example.com`, `tech.example.com`)
- Content is isolated by `site_id` foreign keys in the database
- Users can authenticate across all sites
- Site-specific settings are stored in the `Site` model

Key components:
- `SubdomainMiddleware`: Routes requests to appropriate sites based on subdomain
- `Site` model: Central model managing site configuration
- Site-scoped queries: All content models (Article, Page) are scoped by site_id

### Database Structure
Uses a multi-database Rails setup:
- Primary database: Main application data
- Cache database: Solid Cache for Redis-like caching
- Queue database: Solid Queue for background jobs
- Cable database: Action Cable for WebSocket connections

### Content Models
- `Article`: Blog posts with markdown support, social media integration, and newsletter features
- `Page`: Static pages with similar features to articles
- `User`: Authentication system with BCrypt
- `Setting`: Site-specific configuration storage
- `SocialMediaPost`: Crossposting to Mastodon and Twitter/X

### Controller Organization
- Public controllers: Handle public-facing functionality (ArticlesController, PagesController)
- Admin namespace: All administrative functions under `Admin::` prefix
- Authentication: Session-based auth with `Authentication` concern
- Multisite: Automatic site scoping through `Current.site`

### Background Processing
Uses Solid Queue for background jobs:
- Social media crossposting
- Newsletter sending
- RSS feed generation
- Sitemap updates

### Frontend Stack
- Hotwire (Turbo + Stimulus) for reactive UI
- Importmap for JavaScript management
- Propshaft for asset pipeline
- Custom CSS with Rails asset pipeline

## Key Implementation Patterns

### Site Scoping
All content queries should be scoped to the current site:
```ruby
# Good
Article.where(site: Current.site)

# Better - use the default scope
Current.site.articles
```

### Authentication
Use the `Authentication` concern in controllers:
```ruby
class Admin::BaseController < ApplicationController
  include Authentication
  before_action :require_authentication
end
```

### Caching
Site-specific caching is implemented through cache keys that include the site ID:
```ruby
Rails.cache.fetch("site_#{Current.site.id}_key") do
  # Expensive operation
end
```

### Environment Variables
Critical environment variables:
- `DEFAULT_DOMAIN`: Base domain for multisite (e.g., "example.com")
- `MULTISITE_ENABLED`: Enable/disable multisite features
- `SECRET_KEY_BASE`: Rails secret key
- `SOLID_QUEUE_IN_PUMA`: Enable background job processing
- Database credentials: `PGHOST`, `PGUSER`, `PGPASSWORD`

## Testing Approach
- Uses Rails default testing framework (not RSpec)
- Test files in `/test/` directory
- System tests with Capybara and Selenium
- Custom test data creation: `rake test:create_test_data`

## Common Development Tasks

### Adding New Site-Scoped Models
1. Add `site_id:integer` to migration
2. Add `belongs_to :site` association
3. Add `has_many :model_name, dependent: :destroy` to Site model
4. Use `Current.site.model_name` for scoping

### Working with Subdomains
- Development: Use `lvh.me` domain (resolves to localhost)
- Test different subdomains: `blog.lvh.me:3000`, `tech.lvh.me:3000`
- Production: Configure DNS with wildcard subdomain

### Social Media Integration
- Mastodon: Configure in site settings with access token
- Twitter/X: Requires API credentials in settings
- Crossposting happens asynchronously via background jobs

### Newsletter Functionality
- Integrates with Listmonk for email campaigns
- Article-based newsletter sending
- Configurable per site through settings