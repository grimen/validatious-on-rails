# encoding: utf-8

ActionController::Routing::Routes.draw do |map|

  map.validates '/validates', :controller => 'validates', :conditions => {:method => :get}

end