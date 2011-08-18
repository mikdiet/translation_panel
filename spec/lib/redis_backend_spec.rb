# encoding: utf-8
require 'spec_helper'

describe TranslationPanel::RedisBackend do
  before :all do
    Redis_backend.store.flushdb
  end

  it "stores data, represented by pair key-value" do
    I18n.backend.store_translations "ru", {"simple.key" => "Simple key"}, :escape => false
    I18n.translate("simple.key").should == "Simple key"
  end

  it "stores data, represented by hash" do
    I18n.backend.store_translations "ru", :hashed => {:value => "Hashed Value"}
    I18n.translate("hashed.value").should == "Hashed Value"
  end

  it "stores data, when some pairs" do
    I18n.backend.store_translations "ru", {"first.key" => "First", "second.key" => "Second"}, :escape => false
    I18n.translate("first.key").should == "First"
    I18n.translate("second.key").should == "Second"
  end

  it "stores data, when some translations in hash" do
    I18n.backend.store_translations "ru", :one => {:two => "Two", :three => "Three"}
    I18n.translate("one.two").should == "Two"
    I18n.translate("one.three").should == "Three"
  end

  it "searches in scope" do
    I18n.translate(:key, :scope => :simple).should == "Simple key"
    I18n.translate(:value, :scope => :hashed).should == "Hashed Value"
  end

  it "searches some results in one scope" do
    I18n.translate([:two, :three], :scope =>:one).should == ["Two","Three"]
  end

  it "searches in namespace" do
    I18n.translate(:one).should include(:two => "Two", :three => "Three")
  end

  it "searches deep in namespace" do
    I18n.backend.store_translations "ru", :one => {:four => {:five => "Five"}}
    I18n.translate(:one).should include(:four => {:five => "Five"})
  end

  it "interpolates strings" do
    I18n.backend.store_translations "ru", :hello => "Hello %{name}!"
    I18n.translate(:hello, :name => 'Mik').should == "Hello Mik!"
  end

  it "pluralizes translations" do
    I18n.backend.store_translations "ru", :bug => {:one => "1 bug", :other => "%{count} bugs"}
    I18n.translate(:bug, :count => 1).should == "1 bug"
    I18n.translate(:bug, :count => 5).should == "5 bugs"
  end

  it 'deletes existing translation with nil value' do
    I18n.backend.store_translations "ru", "simple.key" => nil
    Redis_backend.store["simple.key"].should be_nil
  end

  describe "#pluralisation" do
    it "translates from simple, if no keys in redis" do
      I18n.translate("some.test", :count => 21).should == "21 тест"
      I18n.translate("some.test", :count => 23).should == "23 теста"
      I18n.translate("some.test", :count => 11).should == "11 тестов"
    end

    it "translates from redis, but absented keys takes from simple" do
      I18n.backend.store_translations "ru", {"some.test.few" => "%{count} испытания"}, :escape => false
      I18n.translate("some.test", :count => 21).should == "21 тест"
      I18n.translate("some.test", :count => 23).should == "23 испытания"
      I18n.translate("some.test", :count => 11).should == "11 тестов"
    end

    it "creates empty keys in redis if no such keys in both backends" do
      I18n.backend.store_translations "ru", {"some.missing.few" => "%{count} пропажи"}, :escape => false
      I18n.translate("some.missing", :count => 21).should == "21 пропажа"
      I18n.translate("some.missing", :count => 23).should == "23 пропажи"
      I18n.translate("some.missing", :count => 11).should == ""
    end

    it "returns default value for empty translate" do
      I18n.translate("all.missing", :count => 21, :default => "Abc").should == "Abc"
    end
  end
end