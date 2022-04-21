require 'redcarpet'
require 'rouge'
require 'rouge/plugins/redcarpet'

module ApplicationHelper
  class GithubMarkdownRenderer < Redcarpet::Render::HTML
    include Rouge::Plugins::Redcarpet
  end

  def markdown(text)
    render_options = {
      filter_html: true,
      hard_wrap: true
    }
    renderer = GithubMarkdownRenderer.new(render_options)

    extensions = {
      autolink: true,
      fenced_code_blocks: true,
      lax_spacing: true,
      no_intra_emphasis: true,
      strikethrough: true,
      superscript: true,
      tables: true,
    }

    Redcarpet::Markdown.new(renderer, extensions).render(text).html_safe
  end
end
