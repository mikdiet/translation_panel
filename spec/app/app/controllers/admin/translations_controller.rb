class Admin::TranslationsController < ApplicationController
  def new
    params[:value] = nil if params[:value].empty?
    I18n.backend.store_translations params[:locale], {params[:key] => params[:value]}, :escape => false
    render :text => 'ok', :content_type => "text/plain"
  end
end
