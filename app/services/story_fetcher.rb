class StoryFetcher
  require 'open-uri'

  GENRE_LINKS = %w[
    https://www.literotica.com/c/non-consent-stories
  ].freeze

  def initialize; end

  def call
    puts valid_links
    valid_links.each do |link|
      story_text = ''
      (1..100).each do |num|
        page = Nokogiri::HTML(open("#{link}?page=#{num}"))
        break unless page.css('a.b-pager-next').any?

        story_text += page.css('div.b-story-body-x').text
      end
      write_to_file(link.split('/').last, story_text)
      # send story text to Kindle, bundled nice so it will be readable and whatnot.
    end
  end

  private

  def titles
    @titles ||= HTTParty.get("#{GENRE_LINKS.first}/rss")['rss']['channel']['item']
                        .select { |item| Date.parse(item['pubDate']) == Date.today } # exclude old stories
                        .map { |item| item['title'] }
  end

  def links
    @links ||= Nokogiri::HTML(open(GENRE_LINKS.first)).css('h3').xpath('a')
  end

  def valid_links
    @valid_links ||= links.select { |link| titles.include?(link.children.first.text) }
                          .map { |link| link.attributes['href'].value }
                          .reject { |link| link.last.match(/[2-9]/) } # exclude continuing chapters
  end

  def write_to_file(title, text)
    file = File.open("#{Dir.pwd}/tmp/#{title}.txt", 'wb')
    file.puts(text)
    file.close
  end
end
