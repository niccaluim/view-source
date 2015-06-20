require 'rack/utils'

TAG_RE = /<\s*(\/?)\s*([[:alnum:]-]+)(\s+[[:alnum:]-]+\s*=\s*"[^"]+")*\s*(\/?)\s*>/

def summarize_and_tag(html)
  summary = {}
  tagged_html = ''
  pos = 0

  while match = html.match(TAG_RE, pos)
    tag_name = match[2].downcase
    is_open = match[1].empty?

    if is_open
      summary[tag_name] ||= 0
      summary[tag_name] += 1
    end

    m_start, m_end = match.offset(0)

    tagged_html << Rack::Utils.escape_html(html[pos...m_start]).gsub(' ', '&nbsp;')
    tagged_html << "<span class='tag tag-#{tag_name}'>"
    tagged_html << Rack::Utils.escape_html(match[0])
    tagged_html << "</span>"

    pos = m_end
  end
  tagged_html << Rack::Utils.escape_html(html[pos, html.size])
  tagged_html.gsub!("\n", "<br/>")

  return [summary, tagged_html]
end
