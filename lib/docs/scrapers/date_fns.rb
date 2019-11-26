module Docs
  class DateFns < UrlScraper
    self.name = 'date-fns'
    self.slug = 'date_fns'
    self.links = {
      home: 'https://date_fns.com/',
      code: 'https://github.com/date-fns/date-fns'
    }

    html_filters.push 'date_fns/entries', 'date_fns/clean_html', 'title'

    options[:title] = 'date-fns'

    options[:attribution] = <<-HTML
      &copy; 2019 Sasha Koss<br>
      Licensed under the MIT License.
    HTML

    version do
      self.release = '2.8.1'
      self.base_url = "https://date-fns.org/v#{release}/"
      self.root_path = 'docs/Getting-Started/'

      stub '' do
        capybara = load_capybara_selenium
        capybara.app_host = self.base_url.origin
        capybara.visit("#{self.base_url}#{self.root_path}")
        capybara.execute_script('return document.body.innerHTML')
      end
    end


    def get_latest_version(opts)
      get_npm_version('date-fns', opts)
    end
  end
end
