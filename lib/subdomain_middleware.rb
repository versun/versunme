class SubdomainMiddleware
  def initialize(app)
    @app = app
  end

  def call(env)
    request = ActionDispatch::Request.new(env)
    subdomain = extract_subdomain(request.host)
    
    # 查找对应的站点
    if subdomain.present? && subdomain != 'www'
      site = Site.active.find_by(subdomain: subdomain)
    else
      # 使用默认站点
      site = Site.active.find_by(subdomain: 'www') || Site.active.first
    end
    
    # 设置当前站点
    if site
      Current.site = site
      env['current_site'] = site
    else
      # 如果没有找到站点，返回404
      return [404, { 'Content-Type' => 'text/html' }, ['Site not found']]
    end
    
    @app.call(env)
  ensure
    # 清理Current.site，防止污染下一个请求
    Current.site = nil
  end

  private

  def extract_subdomain(host)
    return nil if host.blank?
    
    # 移除端口号
    host = host.split(':').first
    
    # 如果是IP地址，返回nil
    return nil if host =~ /\A\d+\.\d+\.\d+\.\d+\z/
    
    # 获取主域名（移除顶级域名的最后两部分）
    parts = host.split('.')
    
    # 处理localhost特殊情况
    if host.include?('localhost')
      # localhost 或 *.localhost
      return parts.length > 1 ? parts[0] : nil
    end
    
    # 如果域名部分少于3个，说明没有子域名
    return nil if parts.length < 3
    
    # 返回子域名（除了最后两部分之外的所有部分）
    # 例如: blog.example.com -> blog
    #       www.blog.example.com -> www.blog
    parts[0..-3].join('.')
  end
end