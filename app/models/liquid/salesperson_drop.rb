class SalespersonDrop < Liquid::Drop

  def initialize(user)
    @user = user
  end

  def first_name
    @user.first_name
  end

  def last_name
    @user.last_name
  end

  def full_name
    @user.full_name
  end

  def email
    @user.email
  end

  def profile_picture
    @user.try(:profile_picture).try(:file).try(:url, :medium) || ''
  end

end
