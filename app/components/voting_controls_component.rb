class VotingControlsComponent < ViewComponent::Base
  def initialize(path:, score:, user_reaction: nil, signed_in: false)
    @path = path
    @score = score
    @user_reaction = user_reaction
    @signed_in = signed_in
  end

  private

  def upvote_class
    base = "inline-flex p-0 border-0 bg-transparent cursor-pointer text-base leading-none"
    color = @user_reaction&.value == 1 ? "text-accent" : "text-muted hover:text-accent"
    "#{base} #{color}"
  end

  def downvote_class
    base = "inline-flex p-0 border-0 bg-transparent cursor-pointer text-base leading-none"
    color = @user_reaction&.value == -1 ? "text-red-500" : "text-muted hover:text-red-500"
    "#{base} #{color}"
  end

  def score_class
    if @score > 0
      "text-accent"
    elsif @score < 0
      "text-red-500"
    else
      "text-muted"
    end
  end
end
