# encoding: utf-8

::ActionController::Routing::Routes.draw do |map|
  map.connect '/validates/:action', :controller => 'validates', :conditions => {:method => :get}
end