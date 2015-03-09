class StaticPagesController < ApplicationController
  
  def credits
    add_breadcrumb "Credits", :credits_path
  end
  
end