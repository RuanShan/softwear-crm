class ArtistMailer < ActionMailer::Base
  default from: "noreply@softwearcrm.com"

  def notify_artist(salesperson, artwork_request, artist, action)
    @salesperson = salesperson
    @artist = artist
    @artwork_request = artwork_request
    @action = action
    mail to: @artist.email, subject: 'Notification regarding your Artwork Requests'
  end
end

