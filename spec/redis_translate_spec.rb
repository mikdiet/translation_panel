# encoding: utf-8
require 'spec_helper'
require File.expand_path(File.join(File.dirname(__FILE__), '../app/models/redis_translate'))

describe RedisTranslate do
  before do
    Redis_backend.store.flushdb
    I18n.backend.store_translations "ru", :first => "Первый"
    I18n.backend.store_translations "ru", :second => "Второй"
    I18n.backend.store_translations "en", :first => "First key"
    I18n.backend.store_translations "en", :second => "Second key"
  end

  describe "#backend" do
    it "finds backend" do
      RedisTranslate.backend.should == Redis_backend
    end
  end

  describe "#find" do
    it "finds by id" do
      RedisTranslate.find('ru.first').value.should == "Первый"
    end

    it "finds all translates" do
      RedisTranslate.find(:all).map(&:value).should include("Первый", "Второй", "First key", "Second key")
    end

    it "finds first translate in set" do
      set = RedisTranslate.find(:all)
      RedisTranslate.find(:first).should == set.first
    end

    it "finds last translate in set" do
      set = RedisTranslate.find(:all)
      RedisTranslate.find(:last).should == set.last
    end

    it "finds by ids" do
      values = RedisTranslate.find(:all, :id => ['ru.first', 'ru.second']).map(&:value)
      values.should have(2).values
      values.should include("Первый", "Второй")
    end

    it "finds by locale" do
      ru_values = RedisTranslate.find(:all, :locale => :ru).map(&:value)
      ru_values.should have(2).values
      ru_values.should include("Первый", "Второй")
    end

    it "finds matched keys" do
      ru_values = RedisTranslate.find(:all, :key => "sec*").map(&:value)
      ru_values.should have(2).values
      ru_values.should include("Второй", "Second key")
    end

    it "finds matched values by string" do
      ru_values = RedisTranslate.find(:all, :value => "First key").map(&:value)
      ru_values.should have(1).value
      ru_values.should include("First key")
    end

    it "finds matched values by regexp" do
      ru_values = RedisTranslate.find(:all, :value => /key/).map(&:value)
      ru_values.should have(2).values
      ru_values.should include("First key", "Second key")
    end

    context "when nothing not found" do
      it "returns empty array in :all mode" do
        RedisTranslate.find(:all, :locale => :de).should == []
      end

      it "returns nil in :first and :last mode" do
        RedisTranslate.find(:first, :locale => :de).should be_nil
        RedisTranslate.find(:last, :locale => :de).should be_nil
      end
    end

    context "with id and conditions" do
      it "returns matched translate" do
        RedisTranslate.find('ru.first', :locale => :ru).value.should == "Первый"
      end

      it "returns nil when id not matches conditions" do
        RedisTranslate.find('ru.first', :locale => :en).should be_nil
      end
    end
  end

  describe "==" do
    it "compares translates by id" do
      RedisTranslate.find('ru.first').should == RedisTranslate.find('ru.first')
      RedisTranslate.find('ru.first').should_not == RedisTranslate.find('en.first')
    end
  end

  describe "#new" do
    it "initializes new translate by id and set locale and key" do
      translate = RedisTranslate.new :id => "en.third", :value => "Third key"
      translate.id.should == "en.third"
      translate.locale.should == "en"
      translate.key.should == "third"
      translate.value.should == "Third key"
    end

    it "initializes new translate by locale and key and set id" do
      translate = RedisTranslate.new :locale => :en, :key => :third, :value => "Third key"
      translate.id.should == "en.third"
      translate.locale.should == "en"
      translate.key.should == "third"
      translate.value.should == "Third key"
    end
  end

  describe "#update_attributes" do
    it "changes value" do
      RedisTranslate.find('ru.first').update_attributes :value => "test"
      RedisTranslate.find('ru.first').value.should == "test"
    end
  end
end
