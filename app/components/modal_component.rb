class ModalComponent < ViewComponent::Base
  def initialize(id:, title: nil, variant: :default)
    @id = id
    @title = title
    @variant = variant
  end

  def css_classes
    "relative z-50 hidden"
  end
end
