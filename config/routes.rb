Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  get '/home' => 'game#home'
  get '/score' => 'game#score'
end
