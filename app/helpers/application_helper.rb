module ApplicationHelper
  def relative_time(time)
    return "" if time.nil?
    diff = (Time.current - time).to_i
    case diff
    when 0..59 then "#{diff}秒"
    when 60..3599 then "#{(diff / 60).to_i}分"
    when 3600..86399 then "#{(diff / 3600).to_i}時間"
    when 86400..604799 then "#{(diff / 86400).to_i}日"
    else time.strftime("%m月%d日")
    end
  end

  def format_tweet_body(body)
    return "" if body.blank?
    text = h(body)
    text = text.gsub(/@(\w+)/) do
      username = $1
      user = User.find_by(username: username)
      if user
        "<a href=\"#{user_path(username)}\" class=\"text-sky-500 hover:underline\">@#{username}</a>"
      else
        "@#{username}"
      end
    end
    text = text.gsub(/#(\w+)/, '<a href="/search?q=%23\1" class="text-sky-500 hover:underline">#\1</a>')
    text = text.gsub(%r{https?://\S+}, '<a href="\0" class="text-sky-500 hover:underline" target="_blank" rel="noopener">\0</a>')
    text.html_safe
  end

  def avatar_tag(user, size: :md)
    size_class = case size
                 when :xs then "w-6 h-6"
                 when :sm then "w-8 h-8"
                 when :md then "w-10 h-10"
                 when :lg then "w-16 h-16"
                 when :xl then "w-24 h-24"
                 else "w-10 h-10"
                 end

    if user.avatar.attached?
      image_tag url_for(user.avatar), class: "#{size_class} rounded-full object-cover flex-shrink-0"
    else
      content_tag(:div, class: "#{size_class} rounded-full bg-sky-500 flex items-center justify-center flex-shrink-0") do
        content_tag(:span, user.display_name[0].upcase, class: "text-white font-bold #{size == :sm ? 'text-xs' : 'text-sm'}")
      end
    end
  end

  def nav_link(path, label, icon_html, badge: nil)
    active = current_page?(path)
    content_tag(:a, href: path, class: "flex items-center gap-4 px-4 py-3 rounded-full hover:bg-gray-100 transition-colors group w-fit xl:w-full #{'font-bold' if active}") do
      icon = content_tag(:span, icon_html.html_safe, class: "w-6 h-6 #{'text-sky-500' if active}")
      text = content_tag(:span, label, class: "text-xl hidden xl:block #{active ? 'text-gray-900' : 'text-gray-700'}")
      badge_tag = badge.to_i > 0 ? content_tag(:span, badge > 99 ? "99+" : badge.to_s, class: "bg-sky-500 text-white text-xs rounded-full min-w-[18px] h-[18px] flex items-center justify-center px-1") : ""
      icon + text + badge_tag.html_safe
    end
  end
end
