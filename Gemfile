source 'https://rubygems.org'

ruby '2.7.6'

gem 'bootstrap-sass'                
gem 'bootstrap-will_paginate'       # ページネーション
gem 'bcrypt'                        # 暗号化 "Use ActiveModel has_secure_password"
gem 'coffee-rails', '~> 4.2'
gem 'faker'
gem 'jbuilder', '~> 2.5'
gem 'jquery-rails'
gem 'puma', '~> 3.7'
gem 'rails', '~> 5.1.6'
gem 'rails-i18n'                    # 日本語化
gem 'roo'                           # csvファイル読込用（Excel, CSV, OpenOffice, GoogleSpreadSheetを開くことが可能）
gem 'rounding'                      # 時間だけでなく、数値全般を扱える
gem 'sass-rails', '~> 5.0'          # SCSS(Syntactically Awesome StyleSheet：効率的にCSSが書ける言語)
gem 'turbolinks', '~> 5'
gem 'uglifier', '>= 1.3.0'
gem 'will_paginate'                 # ページネーション

group :development, :test do
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  gem 'sqlite3'
end

group :development do
  gem 'listen', '>= 3.0.5', '< 3.2'
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
  gem 'web-console', '>= 3.3.0'
end

group :production do
  gem 'pg', '~> 1.4', '>= 1.4.2'
end

# Windows環境のため実装
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]