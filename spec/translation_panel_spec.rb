require 'spec_helper'

describe TranslationPanel do
  it "should be valid" do
    TranslationPanel.should be_a(Module)
  end
end

describe HomeController, :type => :controller do
  render_views
  describe "index" do
    before :all do
      I18n.backend.store.flushdb
    end

    describe "normal processing" do
      it "doesn't call TranslationPanel in filters" do
        TranslationPanel.should_not_receive(:show!)
        TranslationPanel.should_not_receive(:kill!)
        get :index
      end
    end

    describe "processing with TranslationPanel" do
      it "shows links to TranslationPanel assets" do
        get :index, :translator => true
        response.body.should have_selector("link", :href => "/assets/redis_translator.css")
        response.body.should have_selector("script", :src => "/assets/redis_translator.js")
      end
    end

    describe "both processings" do
      before :all do
        I18n.backend.store_translations "ru", :some_i18n_key => "Some Key!"
        I18n.backend.store_translations "ru", :html_part => "<b>Some HTML</b>"
      end

      it "shows existing tanslates" do
        get :index
        response.body.should include("Some Key!")
        response.body.should have_selector("b") do |bold|
          bold.should include("Some HTML")
        end
      end

      it "shows stubs for absent translates" do
        get :index
        response.body.should have_selector("span.translation_missing",
                      :title => "translation missing: ru.long.chain.of.keys")
      end
    end
  end

  describe "without_head" do
    render_views
    before :all do
      I18n.backend.store.flushdb
    end

    it "is successfull" do
      lambda{ get :without_head, :translator => true }.should_not raise_error
    end

    it "isn't show panel" do
      get :without_head, :translator => true
      response.body.should_not have_selector("script")
    end
  end
end
