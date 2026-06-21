# _plugins/fig_eq_crossref.rb

module Jekyll
  # Container block that sequentially increments a figure counter
  class FigureBlock < Liquid::Block
    def initialize(tag_name, id, tokens)
      super
      @id = id.strip
    end

    def render(context)
      # Initialize the local state dictionary for the current document
      context.environments.first['page']['figure_registry'] ||= {}
      registry = context.environments.first['page']['figure_registry']

      # Assign an increasing integer based on execution sequence
      registry[@id] ||= registry.size + 1

      # Inject the current integer into the rendering context for caption access
      context.environments.first['page']['current_figure_number'] = registry[@id]

      # Render the internal block nodes
      content = super(context)

      # Output the HTML string
      "<div id=\"#{@id}\" class=\"figure\">\n#{content}\n</div>"
    end
  end

  # Resolves the identifier to its corresponding integer for in-text referencing
  class ReferenceTag < Liquid::Tag
    def initialize(tag_name, id, tokens)
      super
      @id = id.strip
    end

    def render(context)
      registry = context.environments.first['page']['figure_registry'] || {}

      # Extract the integer; output an error character if referenced prior to declaration
      number = registry[@id] || "?"
      # Extract the lang parameter
      lang = context.environments.first['page']['lang'] || 'en'

      # Assign the localized prefix
      prefix = case lang
               when 'gl'
                 'Figura'
               else
                 'Figure'
               end
      "<a href=\"##{@id}\">#{prefix} #{number}</a>"
    end
  end

  # Construct for automatic equation numeration
  class EquationBlock < Liquid::Block
    def initialize(tag_name, id, tokens)
      super
      @id = id.strip
    end

    def render(context)
      # Parse internal block context
      content = super(context)
      if @id.empty?
        # Unnumbered equation
          raw_string = "<div class=\"equation\">\n{% katexmm %}\n$$#{content}$$\n{% endkatexmm %}\n</div>"
      else
          # Numbered equation
          context.environments.first['page']['equation_registry'] ||= {}
          registry = context.environments.first['page']['equation_registry']

          # Assign identifier and retrieve sequential integer
          registry[@id] ||= registry.size + 1
          number = registry[@id]

          # Injects the integer into the KaTeX \tag{} command and sets the HTML id
          raw_string = "<div id=\"#{@id}\" class=\"equation\">\n{% katexmm %}\n$$#{content} \\tag{#{number}}$$\n{% endkatexmm %}\n</div>"
      end

      # Re-parse the string to execute the Liquid katexmm block
      Liquid::Template.parse(raw_string).render(context)
    end
  end

  # Inline tag construct for resolving references
  class EquationReferenceTag < Liquid::Tag
    def initialize(tag_name, id, tokens)
      super
      @id = id.strip
    end

    def render(context)
      # Access the specific registry established by the EquationBlock
      registry = context.environments.first['page']['equation_registry'] || {}

      # Retrieve the integer or output ? if undefined
      number = registry[@id] || "?"
      # Extract the lang parameter
      lang = context.environments.first['page']['lang'] || 'en'

      # Assign the localized prefix
      prefix = case lang
               when 'gl'
                 'Ecuación'
               else
                 'Equation'
               end
      "<a href=\"##{@id}\">#{prefix} #{number}</a>"
    end
  end
end

Liquid::Template.register_tag('figure', Jekyll::FigureBlock)
Liquid::Template.register_tag('ref', Jekyll::ReferenceTag)
Liquid::Template.register_tag('equation', Jekyll::EquationBlock)
Liquid::Template.register_tag('eqref', Jekyll::EquationReferenceTag)
