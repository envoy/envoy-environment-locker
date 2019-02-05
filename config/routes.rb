Rails.application.routes.draw do
  post '/', to: 'queue#action'
end
