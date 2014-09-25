# -*- encoding : utf-8 -*-

require 'rails/generators'

def yes_with_banner?(message, banner = "*" * 80)
  yes?("\n#{banner}\n\n#{message}\n#{banner}\nType y(es) to confirm:")
end

class PagedMediaGenerator < Rails::Generators::Base
end

