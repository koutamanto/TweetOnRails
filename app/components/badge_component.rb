class BadgeComponent < ViewComponent::Base
  def initialize(text:, variant: :primary, size: :md)
    @text = text
    @variant = variant
    @size = size
  end

  def css_classes
    base_classes = "inline-flex items-center justify-center font-semibold rounded-full"

    size_classes = case @size
                   when :sm then "px-2 py-0.5 text-xs"
                   when :md then "px-3 py-1 text-sm"
                   when :lg then "px-4 py-1.5 text-base"
                   else "px-3 py-1 text-sm"
                   end

    variant_classes = case @variant
                      when :primary
                        "bg-indigo-100 text-indigo-800"
                      when :secondary
                        "bg-gray-100 text-gray-800"
                      when :success
                        "bg-emerald-100 text-emerald-800"
                      when :danger
                        "bg-red-100 text-red-800"
                      when :warning
                        "bg-amber-100 text-amber-800"
                      when :outline
                        "border border-gray-300 text-gray-700 bg-transparent"
                      else
                        "bg-indigo-100 text-indigo-800"
                      end

    "#{base_classes} #{size_classes} #{variant_classes}"
  end
end
