module AuthHelper
  def profile_picture_of(user = nil, options = {})
    options[:class] ||= ''
    options[:class] += ' media-object img-circle'
    options[:alt] ||= "#{user.try(:full_name) || '(Unknown)'}'s Avatar"

    image_tag user.try(:profile_picture_url) || 'avatar/masarie.jpg', options
  end
end
