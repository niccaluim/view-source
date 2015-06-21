require 'rack/utils'

TAG_RE = %r{
  <
    \s* (/?)                    # closing tag?
    \s* ([[:alnum:]-]+)         # tag name
    (
      \s+ [[:alnum:]-]+ \s* =   # attribute name
      \s* ( ("[^"]+")           # "attribute value"
          | ('[^']+')           # 'attribute value'
          | ([^\s>]+) )         # attribute value (bare)
    )*
    \s* (/?)                    # self-closing?
    \s*
  >
}x

# Tags with content that should not be scanned for other tags.
DATA_TAGS = ['script', 'style']

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

    tagged_html << Rack::Utils.escape_html(html[pos...m_start])
    tagged_html << "<span class='tag tag-#{tag_name}'>"
    tagged_html << Rack::Utils.escape_html(match[0])
    tagged_html << "</span>"

    if is_open && DATA_TAGS.include?(tag_name)
      close_idx = html.index(%r{<\s*/\s*#{Regexp.quote(tag_name)}\s*>}x, m_end)
      pos = close_idx || html.length
      tagged_html << Rack::Utils.escape_html(html[m_end...pos])
    else
      pos = m_end
    end
  end
  tagged_html << Rack::Utils.escape_html(html[pos, html.size])

  [summary, tagged_html]
end
