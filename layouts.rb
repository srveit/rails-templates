run "mkdir -p app/views/layouts"
file "app/views/layouts/application.html.haml", <<-END
= xml_declaration
= xhtml_doctype

%html{:xmlns => "http://www.w3.org/1999/xhtml", :"xml:lang" => "en"}
  %head
    %title= yield(:title) || (controller.class.to_s.sub(/Controller$/, '') + ': ' + controller.action_name)
    = head_meta_tags(yield(:description), yield(:keywords))
    = stylesheet_link_tag 'application'
    = javascript_include_tag :defaults
  %body
    .header
    %h1= yield(:title)
    %p.notice= flash[:notice]
    = yield
END

file "app/helpers/application_helper.rb", <<-END
module ApplicationHelper
  def xml_declaration
    '<?xml version="1.0" encoding="iso-8859-1"?>'
  end

  def xhtml_doctype
    '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN" ' +
      '"http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">'
  end

  def head_meta_tags(description = '', keywords = '')
    "<meta http-equiv=\"Content-Type\" content=\"text/html; charset=iso-8859-1\" />\n" +
      "<meta http-equiv=\"Content-Language\" content=\"en-us\" />\n" +
      "<meta name=\"description\" content=\"#{quote_escape(description)}\" />\n" +
      "<meta name=\"keywords\" content=\"#{quote_escape(keywords)}\" />"
  end

  def quote_escape(string)
    string ? string.gsub('"', '\\"').strip : ''
  end

  def non_breaking(string)
    string && h(string).gsub(' ', '&nbsp;')
  end
end
END
