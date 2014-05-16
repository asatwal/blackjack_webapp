require 'rubygems'
require 'sinatra'

set :sessions, true


get '/render_text' do
  "Hello I'm rendering text"
end

get '/render_template' do
  erb :render_template
end

get '/render_nested_template' do
  erb :'nested/render_nested_template'
end

get '/redirection' do
	redirect '/render_text'
end

