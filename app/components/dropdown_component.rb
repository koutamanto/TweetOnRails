class DropdownComponent < ViewComponent::Base
  def initialize(id:, label: "Menu", position: :left)
    @id = id
    @label = label
    @position = position
  end

  def position_classes
    case @position
    when :right then "right-0"
    when :center then "left-1/2 -translate-x-1/2"
    else "left-0"
    end
  end
end
