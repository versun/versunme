class Admin::SitesController < Admin::BaseController
  before_action :set_site, only: [:show, :edit, :update, :destroy, :activate, :deactivate]

  def index
    @sites = Site.all.order(:name)
  end

  def show
  end

  def new
    @site = Site.new
  end

  def edit
  end

  def create
    @site = Site.new(site_params)

    respond_to do |format|
      if @site.save
        format.html { redirect_to admin_sites_path, notice: "站点创建成功: #{@site.name}" }
        format.json { render :show, status: :created, location: @site }
      else
        format.html { render :new }
        format.json { render json: @site.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @site.update(site_params)
        format.html { redirect_to admin_sites_path, notice: "站点更新成功: #{@site.name}" }
        format.json { render :show, status: :ok, location: @site }
      else
        format.html { render :edit }
        format.json { render json: @site.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    if @site.articles.any? || @site.pages.any?
      redirect_to admin_sites_path, alert: "无法删除站点 '#{@site.name}'，因为该站点下还有文章或页面。请先删除相关内容。"
    else
      @site.destroy
      redirect_to admin_sites_path, notice: "站点删除成功: #{@site.name}"
    end
  end

  def activate
    @site.update(is_active: true)
    redirect_to admin_sites_path, notice: "站点已激活: #{@site.name}"
  end

  def deactivate
    if Site.active.count > 1
      @site.update(is_active: false)
      redirect_to admin_sites_path, notice: "站点已停用: #{@site.name}"
    else
      redirect_to admin_sites_path, alert: "无法停用最后一个激活的站点"
    end
  end

  private

  def set_site
    @site = Site.find(params[:id])
  end

  def site_params
    params.require(:site).permit(:name, :subdomain, :description, :is_active, :site_config)
  end
end