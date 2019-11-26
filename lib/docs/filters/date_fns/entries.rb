module Docs
  class DateFns
    class EntriesFilter < Docs::EntriesFilter
      def get_type
        'date-fns'
      end

      def additional_entries
        entries = []

        css('.doc-finder h3').each do |heading|
          type = heading.content.split.first

          heading.parent.css('a').each do |link|
            name = link.at_css('h4')
            entries << [name, link['href'], type]
          end
        end

        entries
      end
    end
  end
end
