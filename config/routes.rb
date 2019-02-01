Rails.application.routes.draw do
  post '/', to: 'queue#perform_action'
end
