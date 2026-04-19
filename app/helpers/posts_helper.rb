module PostsHelper
  def relative_time(time)
    return "" if time.nil?

    now = Time.current
    diff = (now - time).to_i

    case diff
    when 0..59
      "#{diff}秒前"
    when 60..3599
      "#{(diff / 60).to_i}分前"
    when 3600..86399
      "#{(diff / 3600).to_i}時間前"
    when 86400..604799
      "#{(diff / 86400).to_i}日前"
    else
      time.strftime("%Y年%m月%d日")
    end
  end

  def formatted_date(time)
    return "" if time.nil?
    time.strftime("%Y年%m月%d日 %H:%M")
  end
end
