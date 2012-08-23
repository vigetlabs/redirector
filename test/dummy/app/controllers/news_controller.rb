class NewsController < ApplicationController
  def index
    render :text => "INDEX"
  end
  
  def show
    render :text => "SHOW"
  end
end
