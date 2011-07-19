class ApplicationController < ActionController::Base
  protect_from_forgery
  respond_to :html
  around_filter TranslationPanel::Filter.new('/admin/translations/new', :show_translator?)

protected
  def show_translator?
    params[:translator].present?
  end
end
