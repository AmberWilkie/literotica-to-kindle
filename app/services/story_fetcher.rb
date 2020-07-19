class StoryFetcher
  require 'open-uri'

  DAYS_AGO_TO_EXAMINE = 20
  RATING_THRESHOLD = 4.75

  def initialize;
  end

  def call
    valid_links.each do |link|
      story_text = ''
      meta = ''
      (1..100).each do |num|
        page = Nokogiri::HTML(open("#{link}?page=#{num}"))
        meta = build_meta(page) if meta.empty?
        story_text += page.css('div.b-story-body-x').text
        break unless page.css('a.b-pager-next').any?
      end

      send_to_kindle(link, story_text, meta)
    end
  end

  private

  def genre_links
    ENV['GENRE_LINKS'].split('|')
      .map { |link| "https://www.literotica.com/top/#{link}/last-30-days/?mode=publishes" }
  end

  def valid_links
    @valid_links ||= nodes.select { |link| published_twenty_days_ago?(link) && highly_rated?(link) }
                       .map { |link| link.attributes['href'].value }
                       .reject { |link| continuing_chapter?(link) }
  end

  def write_to_file(title, text, meta)
    file = File.open("#{Dir.pwd}/tmp/#{title}.txt", 'wb')
    file.puts(meta)
    file.puts(text)
    file.close
    file
  end

  def published_twenty_days_ago?(item)
    Date.strptime(item.parent.text[/\(.*?\)/].delete('(').delete(')').to_s, '%m/%d/%y') ==
      Date.today - DAYS_AGO_TO_EXAMINE.days
  rescue StandardError => e
    warn e, e.backtrace
    false
  end

  def highly_rated?(item)
    item.parent.parent.css('td.ratecount').text.split(' ').first.to_f > RATING_THRESHOLD
  rescue StandardError => e
    warn e, e.backtrace
    false
  end

  def continuing_chapter?(link)
    link.match(/[2-9]/) && (link.match(/-ch-/i) || link.match(/-pt-/i))
  end

  def build_meta(page)
    keywords = page.at("meta[name='keywords']")&['content']
    description = page.at("meta[name='description']")&['content']
    author = page.css('span.b-story-user-y').children.last&.text

    "#{keywords}\n\n#{description}\n\n#{author}\n\n\n\n"
  end

  def send_to_kindle(link, story_text, meta)
    file = write_to_file(link.split('/').last, story_text, meta)
    title = link.gsub('.txt', '').split('/').last.titleize

    ApplicationMailer.send_document(title, file.path).deliver
  end

  def nodes
    @nodes ||= parsed_nodes
  end

  def parsed_nodes
    genre_links.map { |link| parse_node(link) }.flatten.compact
  end

  def parse_node(link)
    Nokogiri::HTML(open(link)).css('a.title')
  end
end
