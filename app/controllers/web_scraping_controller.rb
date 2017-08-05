class WebScrapingController < ApplicationController

	require 'capybara'
	require 'capybara/poltergeist'

	Capybara.default_driver = :poltergeist
	Capybara.register_driver :poltergeist do |app|
	  Capybara::Poltergeist::Driver.new(app, js_errors: false)
	end

	def index
	end

	def search()
		search_without_spaces = params[:search].strip.gsub(/\s+/, "%20")
		capybara_params = get_website_scraping_structure(params[:website], search_without_spaces)		
		@results = scrap_website(capybara_params)
	end

	def get_website_scraping_structure(website, search)
		case website
		when "sephora"
			url = "http://www.sephora.com/search/search.jsp?keyword=#{search}&mode=all&pageSize=20&currentPage=1"
			css_selector = ["img.FlexEmbed-content", "a.SkuItem", "div.u-fwb span", "div.SkuItem-nameBrand", "div.SkuItem-nameBrand"]
			capybara_methods = ["[]", "[]", "text", "text", "text"]
			capybara_parameters = ["seph-lazy-src", "href", "", "", ""]
			hash_keys = [:img, :link, :price, :name, :brand]
		when "asos"
			url = "http://us.asos.com/search/#{search}?q=#{search}&pgesize=20"
			css_selector = ["img.product-img", "a.product-link", "span.price", "span.name"]
			capybara_methods = ["[]", "[]", "text", "text"]
			capybara_parameters = ["src", "href", "", ""]
			hash_keys = [:img, :link, :price, :name]
		when "ulta"
			url = "http://www.ulta.com/ulta/a/_/Ntt-#{search}?Nrpp=20&ciSelector=searchResults"
			css_selector = ["a.product img", "a.product", "span.regPrice", "p.prod-desc a", "h4.prod-title a"]
			capybara_methods = ["[]", "[]", "text", "text", "text"]
			capybara_parameters = ["src", "href", "", "", ""]
			hash_keys = [:img, :link, :price, :name, :brand]
		when "frends"
			url = "http://www.frendsbeauty.com/catalogsearch/result/index/?limit=24&q=#{search}"
			css_selector = ["a.product-image img", "a.product-image", "span.price", "h2.product-name"]
			capybara_methods = ["[]", "[]", "text", "text"]
			capybara_parameters = ["src", "href", "", ""]
			hash_keys = [:img, :link, :price, :name]
		end
		{url: url, css_selector: css_selector, method: capybara_methods, parameters: capybara_parameters, keys: hash_keys}
	end

	def scrap_website(capybara_params)		
		scraped_info = Hash.new
		session = Capybara.current_session
		session.visit(capybara_params[:url])	
		sleep(1)

		capybara_params[:keys].each_with_index do |key, index|
			scraped_info[key] = session.all(capybara_params[:css_selector][index], :visible => false, :wait => 5).map {|element| element.method(capybara_params[:method][index]).call(capybara_params[:parameters][index])}
		end

		scraped_info
	end
end
