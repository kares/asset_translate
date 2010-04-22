require 'active_support/core_ext/class/attribute_accessors'
require 'action_view/helpers/asset_tag_helper' if defined? Rails

# I18n support for "translating" assets e.g. images/css files etc.
# with Globalize2's fallback support.
module I18n

  module AssetTranslate

    if defined? ActionView::Helpers::AssetTagHelper
      @@assets_dir = ActionView::Helpers::AssetTagHelper::ASSETS_DIR
    end
    mattr_reader :assets_dir

    def self.assets_dir=(assets_dir)
      @@assets_dir = File.expand_path(assets_dir)
    end

    def assets_dir=(assets_dir)
      I18n::AssetTranslate.assets_dir=(assets_dir)
    end

    @@locales_dirname = 'locales'
    mattr_accessor :locales_dirname

    if defined? ActionView::Helpers::AssetTagHelper
      @@ext_mappings = {
        '.js' => ActionView::Helpers::AssetTagHelper::JAVASCRIPTS_DIR,
        '.css' => ActionView::Helpers::AssetTagHelper::STYLESHEETS_DIR
      }
      images_dir = ActionView::Helpers::AssetTagHelper::ASSETS_DIR + '/images'
      %w{ .gif .jpg .jpeg .png .bmp }.each { |img| @@ext_mappings[img] = images_dir }
    else
      @@ext_mappings = {}
    end
    mattr_accessor :ext_mappings

    protected

    # resolve a localized asset - file for the given locale
    # (looking for a given filename in a locale subdirectory)
    def resolve_asset(locale, filename, raise = true)
      file, dir = File.basename(filename), File.dirname(filename)
      locales_dir = if ! dir.blank? || locales_dirname
        loc_dir = File.join(dir, locales_dirname || '')
        loc_dir[-1,1] == '/' ? loc_dir[0...-1] : loc_dir
      else nil; end

      locale_asset = nil
      if File.exist?(locales_dir) && File.directory?(locales_dir)
        # use globalize2's fallbacks if present :
        locales = I18n.fallbacks[locale] if I18n.respond_to?(:fallbacks)
        locales = [ locale ] unless locales
        locales.each do |l| # locate the asset in locale 'specific' subdir
          l_file = locales_dir ? "#{locales_dir}/#{l}/#{file}" : "#{l}/#{file}"
          (locale_asset = l_file and break) if File.exist?(l_file)
        end
      end

      return locale_asset if locale_asset # localized version
      return filename if File.exist?(filename) # base version
      return nil unless raise # nothing
      raise I18n::ArgumentError, "could not resolve file '#{filename}' " +
                                 "(no locales directory in #{dir})"
    end

    def scan_asset_dir(asset)
      # 3 asset cases to handle :
      # image.jpg
      # images/image.jpg
      # /public/images/image.jpg

      return asset if asset.starts_with?('/')

      asset_dir = File.dirname(asset)
      asset_dir = '' if asset_dir == '.'

      if File.exist?(asset_dir) # e.g. public/...
        return asset # RAILS_ROOT relative
      else
        scan_dir = ext_mappings[File.extname(asset)]
        #subdir = case File.extname(asset).downcase
        #  when '.js' then 'javascripts'
        #  when '.css' then 'stylesheets'
        #  when *IMAGE_EXTS then 'images'
        #  else nil
        #end
        if scan_dir && File.exist?(File.join(scan_dir, asset_dir))
          return File.join(scan_dir, asset)
        end
        # if not found still look in bare Rails.public :
        if File.exist?(File.join(assets_dir, asset_dir)) # && asset_dir != ''
          return File.join(assets_dir, asset)
        end
        asset
      end
    end

    if defined? ActionView::Helpers::AssetTagHelper
      include ActionView::Helpers::AssetTagHelper

      def asset_path(asset)
        asset_path = asset.sub(assets_dir, '')
        if assets_dir == ActionView::Helpers::AssetTagHelper::ASSETS_DIR
          #rewrite_asset_path = ActionView::Helpers::AssetTagHelper.instance_method(:rewrite_asset_path)
          #asset_path = rewrite_asset_path.bind(self).call(asset_t)
          asset_path = rewrite_asset_path(asset_path)
        end
        asset_path
      end

    else

      def asset_path(asset)
        asset.sub(assets_dir, '')
      end

    end

  end

  extend AssetTranslate

  class << self

    def asset_translate(asset, options = {})
      locale = options[:locale] || I18n.locale
      silent = options[:silent]
      asset_t = resolve_asset(locale, scan_asset_dir(asset), ! silent)
      return nil unless asset_t # this might only happen if silent == true
      # make the path 'public' :
      asset_t = File.expand_path(asset_t)
      if options.has_key?(:public_path) ? options[:public_path] : true
        asset_path(asset_t)
      else
        asset_t
      end
    end

    alias_method :asset_t, :asset_translate

  end

end
