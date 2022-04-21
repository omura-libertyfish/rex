Rails.application.routes.draw do
  root 'landing#index'
  get  'auth/:provider/callback', to: 'sessions#callback'
  get  '/signout', to: 'sessions#destroy'

  resources :exam_histories, only: %w(index show create edit update) do
    member do
      post 'retry'
    end
    resources :user_answers, only: %w(edit update show), param: :uuid
  end

  resources :marathon, only: %w(create) do
    resources :marathon_answers, only: %w(edit update), param: :uuid
  end
end
