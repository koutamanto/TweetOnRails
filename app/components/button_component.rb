class ButtonComponent < ViewComponent::Base
  def initialize(label:, variant: :primary, size: :md)
    @label = label
    @variant = variant
    @size = size
  end

  def css_classes
    [base_classes, size_classes, variant_classes].join(" ")
  end

  private

  def base_classes
    "inline-flex items-center justify-center font-semibold rounded-lg transition-colors duration-200 focus:outline-none focus:ring-2 focus:ring-offset-2"
  end

  def size_classes
    case @size
    when :sm then "px-3 py-1.5 text-xs"
    when :md then "px-4 py-2 text-sm"
    when :lg then "px-6 py-3 text-base"
    else "px-4 py-2 text-sm"
    end
  end

  def variant_classes
    case @variant
    when :primary
      "bg-indigo-600 hover:bg-indigo-700 active:bg-indigo-800 text-white shadow-sm focus:ring-indigo-500"
    when :secondary
      "bg-white hover:bg-gray-50 text-gray-700 border border-gray-300 hover:border-gray-400 shadow-sm focus:ring-gray-400"
    when :danger
      "bg-red-600 hover:bg-red-700 active:bg-red-800 text-white shadow-sm focus:ring-red-500"
    when :ghost
      "bg-transparent hover:bg-gray-100 text-gray-600 hover:text-gray-900"
    else
      ""
    end
  end
end
