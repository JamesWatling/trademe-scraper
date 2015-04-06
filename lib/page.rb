require 'nokogiri'
require 'byebug'
require 'open-uri'
require './lib/product'
require './lib/laptop'
require './lib/drawing'


class Page

  attr_accessor :category_url, :category_pages, :links

  USER_AGENT = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_7_0) AppleWebKit/535.2 (KHTML, like Gecko) Chrome/15.0.854.0 Safari/535.2"
  BASE_URL = "http://www.trademe.co.nz"

	def initialize(url)
    # url = BASE_URL + url unless url.include? "trademe.co.nz"
    self.category_url = url
    self.category_pages = []
    self.category_pages << url.dup
    self.links = []
    get_pages(url)
    get_page_category_pages
    puts "\nGathered #{links.count} links"
    create_products
  end

  def get_page_category_pages
    category_pages.each_with_index do |page,index|
      html = Nokogiri(open(page, 'User-Agent' => USER_AGENT))
      supergrid_overlord(html, index+1)
      list_view_list(html, index+1)
    end
    links.reject! { |link| !link.include? "/" }
  end

  def get_pages(url)
    html = Nokogiri(open("#{BASE_URL}#{url}", 'User-Agent' => USER_AGENT))
    while !html.css('[@rel="next"]').empty?
      link = category_pages.last.prepend(BASE_URL)
      html = Nokogiri(open(link, 'User-Agent' => USER_AGENT))
      category_pages << html.css('[@rel="next"]').first.values[0] unless html.css('[@rel="next"]').first.nil?
      print "\rProcessing page #{category_pages.count}"
    end
    puts "\nDone getting index pages"
  end

  def list_view_list(html_node, index)
    listings = html_node.css('.listingCard')
    print "\rProcessing links on page ##{index}"
    listings.each do |listing|
      links << listings.first.css('a').first.values[1]
    end
  end

  def supergrid_overlord(html_node, index)
    listings = html_node.css('.supergrid-listing')
    print "\rProcessing links on page ##{index}"
    listings.each do |listing|
      links << listing.parent.first[1] unless listing.parent.nil?
    end
  end

  def create_products
    links.each do |product|
    if !Product.find_by_link(product)
        print "\r Processing #{product}"
        html = Nokogiri(open("#{BASE_URL}#{product}", 'User-Agent' => USER_AGENT))
        type = html.css(".breadCrumbs").css('a').map(&:text)[0..-2].join("/")
        create_product(product, html)
      end
    end
  end

  def create_product(link, html)
    listing_type = html.css(".breadCrumbs").css('a').map(&:text)[0..-2].join("/")
    product = update_product_score(listing_type).new
    product.listing_type = listing_type
    product.link = link
    product.title = html.css('#ListingTitle_title').text.strip
    product.trademe_id = html.css('#ListingTitle_noStatusListingNumberContainer').text.strip.match(/[0-9]+/)[0]
    product.buynow_price = html.css("#QuickBid_buyNowText").text.match(/[0-9.]+/)[0] unless html.css("#QuickBid_buyNowText").empty?
    product.start_price = html.css('#ListingTitle_auctionTitleBids').text.strip.match(/[0-9.]+/)[0]
    product.description = html.css('#ListingDescription_ListingDescription').text.strip
    product.closing_time = DateTime.parse(html.css("#ListingTitle_titleTime").text.match(/[0-9].+[am,pm,hours,minutes, seconds]/)[0]) rescue Time.now + 1.hours
    product.get_score
    product.save!
  end

  def update_product_score(product)
    case product
    when "Home/Computers/Laptops/Laptops"
      Laptop #.get_score(product)
    else
      Drawing #.get_score(product)
    end 

  end

end
