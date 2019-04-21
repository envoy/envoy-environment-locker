Rails.application.routes.draw do
  post "/", to: "queue#perform_action"
  post "/buttons", to: "queue#extend"
end
