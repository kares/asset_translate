AssetTranslate
==============

An I18n extension for translating - "localizing" assets (e.g. images, css).
Supports locale fallback thru I18n.fallbacks (aka Globalize2) if available.


Install
=======

as a (plain-old) rails plugin :

    ruby script/plugin install git://github.com/kares/asset_translate.git


Example
=======

    I18n.asset_translate('images/test.gif')
    # "/images/test.gif"
    # assuming the file exists and default locale (e.g. :en)
    # if there existed a "/images/locales/en/test.gif" file
    # than it would be preffered over the "/images/test.gif"

    I18n.locale = :hu
    ...
    I18n.asset_translate('images/test.gif')
    # "/images/locales/hu/test.gif"
    # assuming the file exists

    I18n.asset_translate('images/test.gif', :locale => :hu)
    # "/images/locales/hu/test.gif"
    # assuming the file exists (regardless of the I18n.locale)


Configuration
=============

Assets directory (points to Your rails public folder by default).

    I18n::AssetTranslate.assets_dir = './myAssets'

The subdirectory name with locale specific assets, 'locales' by default.
Example dir layout: 'myAssets/flag.png', 'myAssets/locales/hu/flag.png', ...

    I18n::AssetTranslate.locales_dirname = '_localized'

Assets directory mapping by extension. By default (in a rails env) setup as :

    ext_map = { '.css' => "public/stylesheets", '.js' => "public/javascripts" }
    %w{.gif .jpg .jpeg .png .bmp}.each { |ext| ext_map[ext] = "public/images" }
    
    I18n::AssetTranslate.ext_mappings = ext_map
    