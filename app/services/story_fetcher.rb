class StoryFetcher
  require 'open-uri'

  def initialize; end

  def call
    puts valid_links
    valid_links.each do |link|
      story_text = ''
      meta = ''
      (1..100).each do |num|
        page = Nokogiri::HTML(open("#{link}?page=#{num}"))
        break unless num == 1 || page.css('a.b-pager-next').any?

        keywords = page.at("meta[name='keywords']")['content']
        description = page.at("meta[name='description']")['content']
        author = page.css('span.b-story-user-y').children.last.text
        meta = "#{keywords}\n#{description}\n#{author}\n\n" if meta.empty?
        story_text += page.css('div.b-story-body-x').text
      end

      write_to_file(link.split('/').last, story_text, meta)
      # send story text to Kindle, bundled nice so it will be readable and whatnot.
    end
  end

  private

  def genre_links
    ENV['GENRE_LINKS'].split('|')
                      .map { |link| "https://www.literotica.com/top/#{link}/last-30-days/?mode=publishes" }
  end

  def links
    @links ||= parsed_links
  end

  def parsed_links
    links = []
    genre_links.each do |link|
      url = Nokogiri::HTML(open(link)).css('a.title')
      links << url
    end
    links.flatten.compact
  end

  def valid_links
    @valid_links ||= links.select { |link| published_twenty_days_ago?(link) }
                          .map { |link| link.attributes['href'].value }
                          .reject { |link| continuing_chapter?(link) }
  end

  def write_to_file(title, text, meta)
    file = File.open("#{Dir.pwd}/tmp/#{title}.txt", 'wb')
    file.puts(meta)
    file.puts(text)
    file.close
  end

  def published_twenty_days_ago?(item)
    Date.strptime(item.parent.text[/\(.*?\)/].delete('(').delete(')').to_s, '%m/%d/%y') == Date.today - 20.days
  rescue StandardError
    false
  end

  def continuing_chapter?(link)
    link.match(/[2-9]/) && (link.match(/-ch-/i) || link.match(/-pt-/i))
  end
end
