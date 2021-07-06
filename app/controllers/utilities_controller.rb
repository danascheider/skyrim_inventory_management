# frozen_string_literal: true

class UtilitiesController < ApplicationController
  skip_before_action :validate_google_oauth_token

  def privacy
    render plain: PRIVACY, status: :ok
  end

  def tos
    render plain: TOS, status: :ok
  end

  private

  PRIVACY = <<~HEREDOC
    Thank you for using Skyrim Inventory Management. This app was intended
    for my personal use and offers no guarantees of security, privacy, or
    fitness for any purpose. We do not share your data with any third
    parties except Google as needed for authentication. (More accurately,
    Google shares information with us.) The personal information we keep
    about you is your name, your email, and your Google profile image, all
    of which we get from Google when you log in. That means the name, email,
    and profile image we have on file for you will be the ones associated
    with the Google account you use to log in. 
  HEREDOC

  TOS = <<~HEREDOC
    Skyrim Inventory Management is not intended for public use. By using it,
    you agree that not to do anything illegal or malicious, including
    taking over the server to serve malware or ads, attempting to access other
    users' data or data not intentionally exposed through the API according to
    the documentation, which may be found in the README at
    https://github.com/danascheider/skyrim_inventory_management.
  HEREDOC
end
