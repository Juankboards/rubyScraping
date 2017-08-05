Rails.application.routes.draw do
  root 'web_scraping#index'
  get 'search', to: 'web_scraping#search'
end
