require 'rubygems'
require 'test/unit'
require 'active_support' # I18n in vendor/i18n
require 'active_support/test_case'
require 'i18n'

require 'action_view/helpers'
require 'action_view/helpers/asset_tag_helper'

require 'fileutils'

silence_warnings do
  public_dir = File.expand_path('public')
  ActionView::Helpers::AssetTagHelper.const_set(:ASSETS_DIR, public_dir)
  js_dir = "#{public_dir}/javascripts"
  ActionView::Helpers::AssetTagHelper.const_set(:JAVASCRIPTS_DIR, js_dir)
  css_dir = "#{public_dir}/stylesheets"
  ActionView::Helpers::AssetTagHelper.const_set(:STYLESHEETS_DIR, css_dir)
  img_dir = "#{public_dir}/images"

  at_exit { FileUtils.rm_r public_dir } unless File.exist?(public_dir)
  FileUtils.mkdir_p [ js_dir, css_dir, img_dir ]
end

require File.join(File.dirname(__FILE__), '../lib/asset_translate')
