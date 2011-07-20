module TranslationPanel
  class Engine < Rails::Engine
    ActionController::Base.class_eval do
      around_filter TranslationPanel::Filter.new
      protected
      def translation_panel?
        true
      end
    end
  end
end
