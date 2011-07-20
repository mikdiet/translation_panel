class ApplicationController < ActionController::Base
  protect_from_forgery
  around_filter TranslationPanel::Filter.new

protected
  def translation_panel?
    params[:translator].present?
  end
end
