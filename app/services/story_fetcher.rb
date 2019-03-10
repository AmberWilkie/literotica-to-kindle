class StoryFetcher
  require 'open-uri'

  GENRE_LINKS = %w[
    https://www.literotica.com/c/erotic-couplings
    https://www.literotica.com/c/gay-sex-stories
    https://www.literotica.com/c/mind-control
    https://www.literotica.com/c/masturbation-stories
    https://www.literotica.com/c/non-consent-stories
  ].freeze

  def initialize; end

  def call
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
    @titles ||= parsed_titles
  end

  def parsed_titles
    titles = []
    GENRE_LINKS.each do |link|
      titles << HTTParty.get("#{link}/rss")['rss']['channel']['item']
                        .select { |item| published_today?(item) }
                        .map { |item| item['title'] }
    end
    titles.flatten.compact
  end

  def links
    @links ||= parsed_links
  end

  def parsed_links
    links = []
    GENRE_LINKS.each do |link|
      url = Nokogiri::HTML(open(link)).css('h3').xpath('a')
      links << url
    end
    links.flatten.compact
  end

  def valid_links
    @valid_links ||= links.select { |link| titles.include?(link_title(link)) }
                          .map { |link| link.attributes['href'].value }
                          .reject { |link| continuing_chapter?(link) }
  end

  def write_to_file(title, text)
    file = File.open("#{Dir.pwd}/tmp/#{title}.txt", 'wb')
    file.puts(text)
    file.close
  end

  def link_title(link)
    link.children.first.text
  end

  def published_today?(item)
    Date.parse(item['pubDate']) == Date.today
  end

  def continuing_chapter?(link)
    link.last.match(/[2-9]/)
  end
end
