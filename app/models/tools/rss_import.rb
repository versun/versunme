module Tools
  class RssImport
    require "feedjira"
    require "cgi"
    require "open-uri"
    require "nokogiri"
    require "securerandom"
    # include ActiveStorage::SetCurrent
    def initialize(url, import_images = false)
      @url = url
      @import_images = import_images ? true : false
      @error_message = nil
    end

    def import_data
      ActivityLog.create!(
        action: "import",
        target: "import",
        level: :info,
        description: "Start Import from: #{@url}, import images: #{@import_images}"
      )

      # 使用更现代的方式获取RSS内容
      uri = URI.parse(@url)
      response = uri.open
      feed = Feedjira.parse(response.read)

      # 检查是否有条目
      if feed.entries.empty?
        ActivityLog.create!(
          action: "import",
          target: "import",
          level: :warn,
          description: "No entries found in RSS feed from: #{@url}"
        )
        return true
      end

      feed.entries.each do |item|
        next if item.url.blank?

        entry_url     = CGI.unescape(item.url.to_s)
        title         = (item.title || item.published || "Untitled").to_s
        slug_source   = entry_url.split("/").last.presence || title
        slug          = slug_source.parameterize.presence || "article-#{Time.current.to_i}"
        item_content  = item.content || item.summary || item.description || ""

        doc = Nokogiri::HTML::DocumentFragment.parse(item_content)

        if @import_images
          begin
            doc, _attachables = import_images(doc, title, base_url: entry_url)
          rescue => e
            Rails.logger.error "Image import failed for '#{title}': #{e.message}"
          end
        end

        processed_content = doc.to_html

        article = Article.new(
          status: :publish,
          title: title,
          created_at: item.published || Time.current,
          slug: slug,
          description: item.summary || ""
        )
        # 关键：通过 Action Text 赋值，而不是同名列
        article.content = processed_content
        article.save!
      end
      ActivityLog.create!(
        action: "import",
        target: "import",
        level: :info,
        description: "Import successfully from: #{@url}, import images: #{@import_images}"
      )
      true
    rescue StandardError => e
      @error_message = e.message
      ActivityLog.create!(
        action: "import",
        target: "import",
        level: :error,
        description: "Import failed from: #{@url}, import images: #{@import_images}, error: #{e.message}"
      )
      false
    end

    def import_images(doc, title)
      attachables = []
      doc.css("img").each do |img|
        src = img["src"]
        next unless src.present?

        # 跳过数据URI和数据URL
        next if src.start_with?('data:')

        # 确保URL是完整的
        full_src = src.start_with?('http') ? src : URI.join(@url, src).to_s

        begin
          URI.open(full_src) do |io|
            # 获取内容类型和文件扩展名
            content_type = io.content_type || 'application/octet-stream'
            extension = content_type.split("/").last

            # 处理特殊的content_type
            case extension
            when 'jpeg'
              extension = 'jpg'
            when 'svg+xml'
              extension = 'svg'
            end

            filename = "#{title.parameterize}-#{SecureRandom.hex(4)}.#{extension}"

            blob = ActiveStorage::Blob.create_and_upload!(
              io: io,
              filename: filename,
              content_type: content_type
            )
            attachables << blob

            # Update image URL in content - 使用ActionText附件格式
            attachment = ActionText::Attachment.from_attachable(blob)
            img.replace(attachment.node.to_html)
          end
        rescue StandardError => e
          Rails.logger.error "Failed to download image: #{full_src} - #{e.message}"
          # 不中断整个过程，只是记录错误
          next
        end
      end
      return doc, attachables
    end

    def error_message
      @error_message
    end
  end
end
