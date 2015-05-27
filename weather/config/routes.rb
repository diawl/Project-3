Rails.application.routes.draw do

  root 'location#locations'
  get 'weather/locations' => 'location#locations'
  get 'weather/prediction/:post_code/:period' => 'prediction#post', post_code: /3[0-9]{3}/, period: /[136][028][0]?/
  get 'weather/prediction/:lat/:lon/:period' => 'prediction#location', lat: /-?\d+\.\d+/, lon:/-?\d+\.\d+/, period: /[136][028][0]?/
  get 'weather/data/:location_id/:date', to: 'data#show_by_location_id' , constraints: {location_id: /[A-Za-z\s]+/ , date: /(\d{2})-(\d{2})-(\d{4})/ }
  get 'weather/data/:postcode_id/:date', to: 'data#show_by_postcode_id' , constraints: {postcode_id: /3\d{3}/ , date: /(\d{2})-(\d{2})-(\d{4})/  }  
  get 'data/show_by_location_id' => 'data#show_by_location_id'
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
