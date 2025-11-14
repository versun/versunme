require "will_paginate/array"
class ArticlesController < ApplicationController
  allow_unauthenticated_access only: %i[ index show ] # %i 是一种字面量符号数组的简写方式，表示[:index]
  before_action :set_article, only: %i[ show edit update destroy ]

  # GET / or /articles.json
  def index
    respond_to do |format|
      format.html {
        @page = params[:page].present? ? params[:page].to_i : 1
        @per_page = 10
        
        # Use site-specific caching for better performance
        cache_key = params[:q].present? ? "articles_search_#{params[:q]}_page_#{@page}" : "articles_page_#{@page}"
        
        cache_site_fragment(cache_key) do
          if params[:q].present?
            # Use SQLite search with caching
            @articles = Article.search_content(params[:q])
                               .published
                               .includes(:rich_text_content)
                               .order(created_at: :desc)
                               .paginate(page: @page, per_page: @per_page)
            @total_count = @articles.total_entries
          else
            # Use cached article list for better performance
            cached_articles = Article.cache_with_site("articles_list") do
              Article.published
                     .includes(:rich_text_content)
                     .order(created_at: :desc)
                     .limit(100) # Cache first 100 articles
            end
            
            # Get total count for pagination
            @total_count = Article.published.count
            
            # Create WillPaginate::Collection for proper pagination
            @articles = WillPaginate::Collection.create(@page, @per_page, @total_count) do |pager|
              offset = (@page - 1) * @per_page
              pager.replace(cached_articles.offset(offset).limit(@per_page))
            end
          end
        end
      }

      format.rss {
        @articles = Article.cache_with_site("rss_feed") do
          Article.published.order(created_at: :desc).limit(50)
        end
        headers["Content-Type"] = "application/xml; charset=utf-8"
        render layout: false
      }
    end
  end

  # GET /1 or /1.json
  def show
    if @article.nil? || (!%w[publish shared].include?(@article.status) && !authenticated?)
      render_error_page(404, "Article Not Found", "The article you requested could not be found.")
      return
    end
    
    # Add site context to the response
    response.headers["X-Site-Name"] = current_site.name
    response.headers["X-Site-Subdomain"] = current_site.subdomain
    
    # Cache article view count and related data
    cache_site_fragment("article_#{@article.id}_show") do
      # Increment view count (if you have such functionality)
      # @article.increment!(:view_count) if @article.respond_to?(:view_count)
      
      # Preload related content for better performance
      @related_articles = Article.cache_with_site("related_articles_#{@article.id}") do
        Article.published
               .where.not(id: @article.id)
               .order(created_at: :desc)
               .limit(5)
      end
    end
  end

  # GET /articles/new
  def new
    @article = Article.new
    @article.site = current_site # Pre-populate site association
  end

  # GET /1/edit
  def edit
    render "admin/articles/edit"
  end

  # POST / or /articles.json
  def create
    @article = Article.new(article_params)
    @article.site = current_site # Associate with current site
    
    respond_to do |format|
      if @article.save
        format.html { redirect_to admin_articles_path, notice: "Created successfully." }
        format.json { render :show, status: :created, location: @article }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @article.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /1 or /1.json
  def update
    respond_to do |format|
      if @article.update(article_params)
        format.html { redirect_to admin_articles_path, notice: "Updated successfully." }
        format.json { render :show, status: :ok, location: @article }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @article.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /1 or /1.json
  def destroy
    notice_message = if @article.status != "trash"
      @article.update(status: "trash")
      "Article was successfully moved to trash."
    else
      @article.destroy!
      "Article was successfully destroyed."
    end

    respond_to do |format|
      format.html { redirect_to admin_articles_path, status: :see_other, notice: notice_message }
      format.json { head :no_content }
    end
  end

  private

  def set_article
    @article = Article.find_by(slug: params[:slug])
    
    # Verify the article belongs to current site
    if @article && @article.site_id != current_site.id
      @article = nil
      return
    end
  end

  def article_params
    params.expect(article: [ :title,
                            :content,
                            :status,
                            :slug,
                            :description,
                            :scheduled_at,
                            :crosspost_mastodon,
                            :crosspost_twitter,
                            :crosspost_bluesky,
                            :send_newsletter,
                            :created_at,
                            social_media_posts_attributes: [ [ :id, :_destroy, :platform, :url ] ] ])
  end
end
