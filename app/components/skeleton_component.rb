class SkeletonComponent < ViewComponent::Base
  def initialize(type: :card, count: 1)
    @type = type
    @count = count
  end

  def css_classes
    case @type
    when :card
      "bg-white border border-gray-200 rounded-xl p-5 space-y-3 animate-pulse"
    when :line
      "h-4 bg-gray-200 rounded animate-pulse"
    when :text
      "space-y-2 animate-pulse"
    when :avatar
      "w-10 h-10 bg-gray-200 rounded-full animate-pulse"
    else
      "bg-white border border-gray-200 rounded-xl p-5 space-y-3 animate-pulse"
    end
  end
end
