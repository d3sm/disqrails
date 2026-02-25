class AuthorComponent < ViewComponent::Base
  def initialize(user:, author_text:, show_avatar: true)
    @user = user
    @author_text = author_text
    @show_avatar = show_avatar
  end

  private

  def linkable?
    @user.present? && !@user.deleted?
  end

  def display_name
    linkable? ? @user.nickname : (@author_text.presence || "[deleted]")
  end
end
