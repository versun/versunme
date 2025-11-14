class Admin::BaseController < ApplicationController
  # 统一的Admin基类控制器
  # 所有后台管理控制器都应该继承此类

  # before_action :authenticate_user!
  # before_action :require_admin_privileges
  before_action :set_available_sites
  before_action :handle_site_switch
  
  layout "admin"
  private

  def set_available_sites
    @available_sites = Site.active.order(:name)
  end

  def handle_site_switch
    if params[:switch_site].present?
      new_site = Site.active.find_by(id: params[:switch_site])
      if new_site && can_switch_to_site?(new_site)
        session[:admin_site_id] = new_site.id
        redirect_to request.referer || admin_root_path, notice: "已切换到站点: #{new_site.name}"
      end
    end
  end

  def can_switch_to_site?(site)
    # 这里可以添加权限检查逻辑
    # 例如：只有超级管理员可以切换站点，或者用户有特定站点的访问权限
    true # 暂时允许所有用户切换站点
  end

  def current_admin_site
    @current_admin_site ||= begin
      if session[:admin_site_id].present?
        Site.active.find_by(id: session[:admin_site_id]) || current_site
      else
        current_site
      end
    end
  end
  helper_method :current_admin_site

  def require_admin_privileges
    # 这里可以添加权限检查逻辑
    # 例如：redirect_to root_path unless Current.user&.admin?
  end

  def fetch_articles(scope, sort_by: :created_at)
    @page = params[:page].present? ? params[:page].to_i : 1
    @per_page = 20
    @status = params[:status] || "publish"

    filtered_posts = filter_by_status(scope)
    filtered_posts.paginate(page: @page, per_page: @per_page).order(sort_by => :desc)
  end

  def filter_by_status(posts)
    case @status
    when "publish", "schedule", "shared", "draft", "trash"
      posts.by_status(@status.to_sym)
    else
      posts
    end
  end
end
