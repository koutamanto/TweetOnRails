module SeoHelper
  APP_NAME        = "Robin"
  APP_HOST        = "https://robin.katskouta.one"
  DEFAULT_DESC    = "Robinで今起きていることをリアルタイムでチェック。ツイート、フォロー、発見。日本のソーシャルネットワーク。"
  DEFAULT_IMAGE   = "#{APP_HOST}/icons/icon-512x512.png"

  def seo_title
    if content_for?(:seo_title)
      "#{content_for(:seo_title)} | #{APP_NAME}"
    else
      APP_NAME
    end
  end

  def seo_description
    content_for?(:seo_desc) ? content_for(:seo_desc).strip.truncate(160) : DEFAULT_DESC
  end

  def seo_canonical
    content_for?(:seo_canonical) ? content_for(:seo_canonical) : "#{APP_HOST}#{request.path}"
  end

  def seo_og_image
    content_for?(:seo_image) ? content_for(:seo_image) : DEFAULT_IMAGE
  end

  def seo_og_type
    content_for?(:seo_og_type) ? content_for(:seo_og_type) : "website"
  end

  def absolute_avatar_url(user)
    return DEFAULT_IMAGE unless user&.avatar&.attached?
    url_for(user.avatar)
  rescue
    DEFAULT_IMAGE
  end

  # Render a BreadcrumbList JSON-LD script tag.
  # items: [{name: "ホーム", url: "https://..."}, ...]
  def breadcrumb_json_ld(items)
    list_elements = items.each_with_index.map do |item, i|
      el = { "@type" => "ListItem", "position" => i + 1, "name" => item[:name] }
      el["item"] = item[:url] if item[:url].present?
      el
    end
    schema = { "@context" => "https://schema.org", "@type" => "BreadcrumbList", "itemListElement" => list_elements }
    content_tag(:script, schema.to_json.html_safe, type: "application/ld+json")
  end

  # Render a FAQPage JSON-LD script tag.
  # pairs: [{q: "質問", a: "回答"}, ...]
  def faq_json_ld(pairs)
    entities = pairs.map do |pair|
      {
        "@type" => "Question",
        "name" => pair[:q],
        "acceptedAnswer" => { "@type" => "Answer", "text" => pair[:a] }
      }
    end
    schema = { "@context" => "https://schema.org", "@type" => "FAQPage", "mainEntity" => entities }
    content_tag(:script, schema.to_json.html_safe, type: "application/ld+json")
  end

  # Global Organization + WebSite schema rendered on every page.
  def global_structured_data_json
    [
      {
        "@context" => "https://schema.org",
        "@type" => "Organization",
        "@id" => "#{APP_HOST}/#organization",
        "name" => APP_NAME,
        "url" => APP_HOST,
        "logo" => {
          "@type" => "ImageObject",
          "@id" => "#{APP_HOST}/#logo",
          "url" => DEFAULT_IMAGE,
          "width" => 512,
          "height" => 512
        },
        "description" => DEFAULT_DESC,
        "inLanguage" => "ja",
        "sameAs" => [APP_HOST]
      },
      {
        "@context" => "https://schema.org",
        "@type" => "WebSite",
        "@id" => "#{APP_HOST}/#website",
        "name" => APP_NAME,
        "url" => APP_HOST,
        "inLanguage" => "ja",
        "publisher" => { "@id" => "#{APP_HOST}/#organization" },
        "potentialAction" => {
          "@type" => "SearchAction",
          "target" => {
            "@type" => "EntryPoint",
            "urlTemplate" => "#{APP_HOST}/search?q={search_term_string}"
          },
          "query-input" => "required name=search_term_string"
        }
      }
    ].to_json
  end
end
