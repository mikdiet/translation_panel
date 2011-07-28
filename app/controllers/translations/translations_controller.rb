class Translations::TranslationsController < ApplicationController
  before_filter :check_rights

  def new
    params[:value] = nil if params[:value].empty?
    I18n.backend.store_translations params[:locale], {params[:key] => params[:value]}, {:escape => false}
    render :text => 'ok', :content_type => "text/plain"
  end

protected
  def check_rights
    unless translation_panel?
      render :text => 'error', :content_type => "text/plain", :status => 404
    end
  end
end
