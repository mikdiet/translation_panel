module TranslationPanel
  class InstallGenerator < Rails::Generators::Base
    source_root File.expand_path("../../../../app/assets", __FILE__)
    desc "copies TranslationPanel's javascript and stylesheet into vendor/assets"
    
    def copy_asset_files
      copy_file "javascripts/translation_panel.js.coffee",
                "vendor/assets/javascripts/translation_panel.js.coffee"
      copy_file "stylesheets/translation_panel.css.scss",
                "vendor/assets/stylesheets/translation_panel.css.scss"
    end
  end
end
