require 'test_helper'

# load Globalize fallback support :
require 'globalize/locale/fallbacks'

class AssetTranslateFallbackTest < ActiveSupport::TestCase

  ASSETS_PUBLIC = ActionView::Helpers::AssetTagHelper::ASSETS_DIR
  FileUtils.mkdir(ASSETS_PUBLIC) unless File.exists?(ASSETS_PUBLIC)

  IMAGES_LOCALES_DIR = "#{ASSETS_PUBLIC}/images/locales"

  setup :mk_asset_dirs
  def mk_asset_dirs
    FileUtils.mkdir_p "#{IMAGES_LOCALES_DIR}/en"
    FileUtils.mkdir_p "#{IMAGES_LOCALES_DIR}/cs"
    FileUtils.mkdir_p "#{ASSETS_PUBLIC}/locales/de"

    FileUtils.touch "#{IMAGES_LOCALES_DIR}/en/test1.png"
    FileUtils.touch "#{IMAGES_LOCALES_DIR}/cs/test1.png"

    FileUtils.touch "#{ASSETS_PUBLIC}/images/test2.gif"
    FileUtils.touch "#{IMAGES_LOCALES_DIR}/cs/test2.gif" # sk => cs fallback
    
    FileUtils.touch "#{ASSETS_PUBLIC}/_test1.html"
    FileUtils.touch "#{ASSETS_PUBLIC}/locales/de/_test1.html"
  end

  teardown :rm_asset_dirs
  def rm_asset_dirs
    FileUtils.rm_r "#{IMAGES_LOCALES_DIR}/en"
    FileUtils.rm_r "#{IMAGES_LOCALES_DIR}/cs"
    FileUtils.rm_r "#{ASSETS_PUBLIC}/locales/de"
  end

  setup :set_asset_tag_helper_rails_asset_id
  def set_asset_tag_helper_rails_asset_id
    ENV["RAILS_ASSET_ID"] = '42'
  end

  teardown :unset_asset_tag_helper_rails_asset_id
  def unset_asset_tag_helper_rails_asset_id
    ENV.delete("RAILS_ASSET_ID")
  end

  setup :map_locale_fallbacks
  def map_locale_fallbacks
    I18n.fallbacks.map :sk => :cs
    I18n.fallbacks.map :de => :en
  end

  teardown :unmap_locale_fallbacks
  def unmap_locale_fallbacks
    I18n.fallbacks.delete(:sk)
    I18n.fallbacks.delete(:de)
  end

  test 'asset_translate_1' do
    assert_equal "/images/locales/en/test1.png?42", I18n.asset_translate('test1.png')
    assert_equal "/images/locales/cs/test1.png?42", I18n.asset_translate('test1.png', :locale => :cs)
    assert_equal "/images/locales/en/test1.png?42", I18n.asset_translate('test1.png', :locale => :de)
    #
    assert_equal "/images/locales/en/test1.png?42", I18n.asset_translate('images/test1.png')
    assert_equal "/images/locales/cs/test1.png?42", I18n.asset_translate('images/test1.png', :locale => :cs)
    assert_equal "/images/locales/en/test1.png?42", I18n.asset_translate('images/test1.png', :locale => :de)
    #
    assert_equal "/images/locales/en/test1.png?42", I18n.asset_t('public/images/test1.png')
    assert_equal "/images/locales/cs/test1.png?42", I18n.asset_t('public/images/test1.png', :locale => :cs)
    assert_equal "/images/locales/en/test1.png?42", I18n.asset_t('public/images/test1.png', :locale => :de)
  end

  test 'asset_translate_2' do
    assert_equal "/images/test2.gif?42", I18n.asset_translate('test2.gif')
    assert_equal "/images/locales/cs/test2.gif?42", I18n.asset_translate('test2.gif', :locale => :cs)
    assert_equal "/images/locales/cs/test2.gif?42", I18n.asset_translate('test2.gif', :locale => :sk)
    assert_equal "/images/test2.gif?42", I18n.asset_translate('test2.gif', :locale => :de)
    #
    assert_equal "/images/test2.gif?42", I18n.asset_translate('images/test2.gif')
    assert_equal "/images/locales/cs/test2.gif?42", I18n.asset_translate('images/test2.gif', :locale => :cs)
    assert_equal "/images/locales/cs/test2.gif?42", I18n.asset_translate('images/test2.gif', :locale => :sk)
    assert_equal "/images/test2.gif?42", I18n.asset_translate('images/test2.gif', :locale => :de)
  end

  test 'asset_translate_3' do
    assert_equal "/_test1.html?42", I18n.asset_translate('_test1.html')
    assert_equal "/locales/de/_test1.html?42", I18n.asset_translate('_test1.html', :locale => :de)
    assert_equal "/locales/de/_test1.html?42", I18n.asset_translate('_test1.html', :locale => :'de-DE')
    assert_equal "/_test1.html?42", I18n.asset_translate('_test1.html', :locale => :cs)
  end

end
