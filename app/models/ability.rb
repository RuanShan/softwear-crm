class Ability
  include CanCan::Ability

  # NOTE no authorization is currently actually performed.
  # see https://github.com/CanCanCommunity/cancancan for
  # details.
  def initialize(user)
    return if user.nil?

    can :manage, :all if user.role?(:admin, :developer)
  end
end
