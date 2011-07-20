class ApplicationController < ActionController::Base
  protect_from_forgery

protected
  def translation_panel?
    params[:translator].present?
  end
end
