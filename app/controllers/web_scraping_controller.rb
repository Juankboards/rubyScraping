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
		url = "http://www.sephora.com/search/search.jsp?keyword=#{params[:search]}&mode=all&pageSize=20&currentPage=1"
		# @results = get_search_results(url)
			
		@results = find_element(url)
	end

	# def get_search_results(url)
	# 	array = find_element(url)
	# end

	def find_element(url)		
		session = Capybara.current_session
		session.visit(url)	
		sleep(1)
		brand_array = session.all("div.SkuItem-nameBrand", :wait => 5).map {|element| element.text}
		name_array = session.all("div.SkuItem-nameDisplay").map {|element| element.text}
		price_array = session.all("div.u-fwb span").map {|element| element.text}
		img_array = session.all("img.FlexEmbed-content", :visible => false, :wait => 5).map {|element| element['seph-lazy-src']}
		link_array = session.all("a.SkuItem").map {|element| element['href']}
		scraped_info = {brand: brand_array, name: name_array, price: price_array, img: img_array, link: link_array}
	end
end
