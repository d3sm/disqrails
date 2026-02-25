class AvatarComponent < ViewComponent::Base
  def initialize(user:, size: 16)
    @user = user
    @size = size
  end

  private

  def size_class
    "size-#{@size / 4}"
  end

  def show_image?
    @user&.avatar_url.present? && !@user.deleted?
  end

  def initial
    @user&.nickname&.first&.upcase || "?"
  end
end
